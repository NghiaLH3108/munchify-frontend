import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/staff/data/datasources/staff_remote_data_source.dart';
import 'package:munchify_frontend/features/staff/data/models/paged_staff_result.dart';
import 'package:munchify_frontend/features/staff/data/models/staff_model.dart';
import 'package:munchify_frontend/features/staff/data/repositories/staff_repository_impl.dart';

class MockStaffRemoteDataSource implements StaffRemoteDataSource {
  Exception? exceptionToThrow;
  PagedStaffResult? mockPagedStaffResult;
  StaffModel? mockStaffModel;
  bool mockToggleResult = true;

  @override
  Future<PagedStaffResult> getStaffList({
    String? role,
    bool? isActive,
    String? searchKeyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockPagedStaffResult ??
        const PagedStaffResult(
          items: [],
          totalCount: 0,
          page: 1,
          pageSize: 10,
          totalPages: 1,
        );
  }

  @override
  Future<StaffModel> createStaff(Map<String, dynamic> staffData) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockStaffModel ??
        StaffModel(
          userId: 1,
          username: 'created',
          fullName: 'Created Staff',
          phone: '0123456789',
          email: 'created@munchify.com',
          role: 'STAFF',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<StaffModel> updateStaff(int id, Map<String, dynamic> staffData) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockStaffModel ??
        StaffModel(
          userId: id,
          username: 'updated',
          fullName: 'Updated Staff',
          phone: '0123456789',
          email: 'updated@munchify.com',
          role: 'STAFF',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<bool> toggleStaffStatus(int id) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockToggleResult;
  }
}

void main() {
  late MockStaffRemoteDataSource mockDataSource;
  late StaffRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockStaffRemoteDataSource();
    repository = StaffRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('StaffRepositoryImpl Fallback Error Handling Tests', () {
    const expectedFallbackMessage =
        'Không thể kết nối đến máy chủ Backend. Vui lòng kiểm tra lại dịch vụ.';

    test('getStaffList returns friendly Vietnamese fallback on DioException without response/message', () async {
      mockDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users'),
      );

      final result = await repository.getStaffList();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, expectedFallbackMessage);
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('getStaffList forwards backend error message when present in response data', () async {
      mockDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/users'),
          data: {'message': 'Tài khoản không đủ quyền hạn.'},
        ),
      );

      final result = await repository.getStaffList();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Tài khoản không đủ quyền hạn.');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('createStaff returns fallback error message on DioException without response/message', () async {
      mockDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users'),
      );

      final result = await repository.createStaff({'username': 'staff1'});

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, expectedFallbackMessage);
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('updateStaff returns fallback error message on DioException without response/message', () async {
      mockDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users/1'),
      );

      final result = await repository.updateStaff(1, {'fullName': 'Staff Name'});

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, expectedFallbackMessage);
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('toggleStaffStatus returns fallback error message on DioException without response/message', () async {
      mockDataSource.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/users/1/toggle-status'),
      );

      final result = await repository.toggleStaffStatus(1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, expectedFallbackMessage);
        },
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
