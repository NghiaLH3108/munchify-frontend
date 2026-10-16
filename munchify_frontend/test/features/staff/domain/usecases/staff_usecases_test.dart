import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/staff/data/models/paged_staff_result.dart';
import 'package:munchify_frontend/features/staff/data/models/staff_model.dart';
import 'package:munchify_frontend/features/staff/domain/entities/staff_entity.dart';
import 'package:munchify_frontend/features/staff/domain/repositories/staff_repository.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/create_staff_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/get_staff_list_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/toggle_staff_status_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/update_staff_usecase.dart';

class MockStaffRepository implements StaffRepository {
  final StaffEntity dummyStaff = StaffEntity(
    userId: 1,
    username: 'test_user',
    fullName: 'Test User',
    phone: '0912345678',
    email: 'test@munchify.com',
    role: 'STAFF',
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  bool shouldFail = false;

  @override
  Future<Either<Failure, PagedStaffResult>> getStaffList({
    String? role,
    bool? isActive,
    String? searchKeyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Lỗi máy chủ'));
    }
    return Right(PagedStaffResult(
      items: [
        StaffModel(
          userId: dummyStaff.userId,
          username: dummyStaff.username,
          fullName: dummyStaff.fullName,
          phone: dummyStaff.phone,
          email: dummyStaff.email,
          role: dummyStaff.role,
          isActive: dummyStaff.isActive,
          createdAt: dummyStaff.createdAt,
          updatedAt: dummyStaff.updatedAt,
        )
      ],
      totalCount: 1,
      page: page,
      pageSize: pageSize,
      totalPages: 1,
    ));
  }

  @override
  Future<Either<Failure, StaffEntity>> createStaff(Map<String, dynamic> staffData) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Tên đăng nhập đã tồn tại'));
    }
    return Right(dummyStaff);
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(int id, Map<String, dynamic> staffData) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Không tìm thấy nhân viên'));
    }
    return Right(dummyStaff);
  }

  @override
  Future<Either<Failure, bool>> toggleStaffStatus(int id) async {
    if (shouldFail) {
      return const Left(ServerFailure(message: 'Không thể khóa tài khoản'));
    }
    return const Right(true);
  }
}

void main() {
  late MockStaffRepository repository;
  late GetStaffListUseCase getStaffListUseCase;
  late CreateStaffUseCase createStaffUseCase;
  late UpdateStaffUseCase updateStaffUseCase;
  late ToggleStaffStatusUseCase toggleStaffStatusUseCase;

  setUp(() {
    repository = MockStaffRepository();
    getStaffListUseCase = GetStaffListUseCase(repository);
    createStaffUseCase = CreateStaffUseCase(repository);
    updateStaffUseCase = UpdateStaffUseCase(repository);
    toggleStaffStatusUseCase = ToggleStaffStatusUseCase(repository);
  });

  group('Staff UseCases', () {
    test('GetStaffListUseCase returns PagedStaffResult on success', () async {
      final result = await getStaffListUseCase(page: 1, pageSize: 10);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (paged) {
          expect(paged.items.length, 1);
          expect(paged.items.first.username, 'test_user');
        },
      );
    });

    test('GetStaffListUseCase returns Failure on error', () async {
      repository.shouldFail = true;
      final result = await getStaffListUseCase(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Lỗi máy chủ'),
        (_) => fail('Should be left'),
      );
    });

    test('CreateStaffUseCase returns StaffEntity on success', () async {
      final result = await createStaffUseCase({'username': 'test_user'});

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (staff) => expect(staff.username, 'test_user'),
      );
    });

    test('UpdateStaffUseCase returns updated StaffEntity on success', () async {
      final result = await updateStaffUseCase(1, {'fullName': 'New Name'});

      expect(result.isRight(), isTrue);
    });

    test('ToggleStaffStatusUseCase returns true on success', () async {
      final result = await toggleStaffStatusUseCase(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should be right'),
        (success) => expect(success, isTrue),
      );
    });
  });
}
