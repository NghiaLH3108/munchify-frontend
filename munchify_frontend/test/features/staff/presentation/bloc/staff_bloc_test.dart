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
import 'package:munchify_frontend/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:munchify_frontend/features/staff/presentation/bloc/staff_event.dart';
import 'package:munchify_frontend/features/staff/presentation/bloc/staff_state.dart';

class MockStaffRepoForBloc implements StaffRepository {
  Either<Failure, PagedStaffResult>? pagedResult;
  Either<Failure, StaffEntity>? staffResult;
  Either<Failure, bool>? toggleResult;

  @override
  Future<Either<Failure, PagedStaffResult>> getStaffList({
    String? role,
    bool? isActive,
    String? searchKeyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    return pagedResult ?? const Left(ServerFailure(message: 'Error'));
  }

  @override
  Future<Either<Failure, StaffEntity>> createStaff(Map<String, dynamic> staffData) async {
    return staffResult ?? const Left(ServerFailure(message: 'Error'));
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(int id, Map<String, dynamic> staffData) async {
    return staffResult ?? const Left(ServerFailure(message: 'Error'));
  }

  @override
  Future<Either<Failure, bool>> toggleStaffStatus(int id) async {
    return toggleResult ?? const Left(ServerFailure(message: 'Error'));
  }
}

void main() {
  late StaffBloc staffBloc;
  late MockStaffRepoForBloc mockRepo;
  late GetStaffListUseCase getStaffList;
  late CreateStaffUseCase createStaff;
  late UpdateStaffUseCase updateStaff;
  late ToggleStaffStatusUseCase toggleStaffStatus;

  setUp(() {
    mockRepo = MockStaffRepoForBloc();
    getStaffList = GetStaffListUseCase(mockRepo);
    createStaff = CreateStaffUseCase(mockRepo);
    updateStaff = UpdateStaffUseCase(mockRepo);
    toggleStaffStatus = ToggleStaffStatusUseCase(mockRepo);

    staffBloc = StaffBloc(
      getStaffList: getStaffList,
      createStaff: createStaff,
      updateStaff: updateStaff,
      toggleStaffStatus: toggleStaffStatus,
    );
  });

  tearDown(() {
    staffBloc.close();
  });

  final tStaff = StaffEntity(
    userId: 1,
    username: 'barista_01',
    fullName: 'Lê Văn B',
    phone: '0901234567',
    email: 'barista@munchify.com',
    role: 'STAFF',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final tPagedResult = PagedStaffResult(
    items: [
      StaffModel(
        userId: tStaff.userId,
        username: tStaff.username,
        fullName: tStaff.fullName,
        phone: tStaff.phone,
        email: tStaff.email,
        role: tStaff.role,
        isActive: tStaff.isActive,
        createdAt: tStaff.createdAt,
        updatedAt: tStaff.updatedAt,
      )
    ],
    totalCount: 1,
    page: 1,
    pageSize: 10,
    totalPages: 1,
  );

  test('initial state should be StaffInitial', () {
    expect(staffBloc.state, equals(StaffInitial()));
  });

  group('LoadStaffList', () {
    test('emits [StaffLoading, StaffListLoaded] on success', () async {
      mockRepo.pagedResult = Right(tPagedResult);

      final expected = [
        StaffLoading(),
        StaffListLoaded(tPagedResult),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const LoadStaffList(page: 1, pageSize: 10));
    });

    test('emits [StaffLoading, StaffError] on failure', () async {
      mockRepo.pagedResult = const Left(ServerFailure(message: 'Lỗi tải danh sách'));

      final expected = [
        StaffLoading(),
        const StaffError('Lỗi tải danh sách'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const LoadStaffList(page: 1, pageSize: 10));
    });
  });

  group('CreateStaffEvent', () {
    test('emits [StaffLoading, StaffActionSuccess] on success', () async {
      mockRepo.staffResult = Right(tStaff);

      final expected = [
        StaffLoading(),
        const StaffActionSuccess('Tạo tài khoản thành công'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const CreateStaffEvent({'username': 'new_staff'}));
    });

    test('emits [StaffLoading, StaffError] on failure', () async {
      mockRepo.staffResult = const Left(ServerFailure(message: 'Tên đăng nhập đã tồn tại'));

      final expected = [
        StaffLoading(),
        const StaffError('Tên đăng nhập đã tồn tại'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const CreateStaffEvent({'username': 'existing_user'}));
    });
  });

  group('UpdateStaffEvent', () {
    test('emits [StaffLoading, StaffActionSuccess] on success', () async {
      mockRepo.staffResult = Right(tStaff);

      final expected = [
        StaffLoading(),
        const StaffActionSuccess('Cập nhật thành công'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const UpdateStaffEvent(1, {'fullName': 'Tên mới'}));
    });

    test('emits [StaffLoading, StaffError] on failure', () async {
      mockRepo.staffResult = const Left(ServerFailure(message: 'Không tìm thấy tài khoản'));

      final expected = [
        StaffLoading(),
        const StaffError('Không tìm thấy tài khoản'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const UpdateStaffEvent(999, {'fullName': 'Tên mới'}));
    });
  });

  group('ToggleStaffStatusEvent', () {
    test('emits [StaffLoading, StaffActionSuccess] on success', () async {
      mockRepo.toggleResult = const Right(true);

      final expected = [
        StaffLoading(),
        const StaffActionSuccess('Thay đổi trạng thái thành công'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const ToggleStaffStatusEvent(1));
    });

    test('emits [StaffLoading, StaffError] on failure', () async {
      mockRepo.toggleResult = const Left(ServerFailure(message: 'Không thể khóa tài khoản chính mình'));

      final expected = [
        StaffLoading(),
        const StaffError('Không thể khóa tài khoản chính mình'),
      ];

      expectLater(staffBloc.stream, emitsInOrder(expected));
      staffBloc.add(const ToggleStaffStatusEvent(1));
    });
  });
}
