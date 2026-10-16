import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/network/NetworkInfo.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_remote_data_source.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SupplierRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({
    String? search,
    bool? isActive,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'Không có kết nối mạng.'));
    }
    try {
      final models = await remoteDataSource.getSuppliers(search: search, isActive: isActive);
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Lỗi tải danh sách nhà cung cấp'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> getSupplierById(int id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'Không có kết nối mạng.'));
    }
    try {
      final model = await remoteDataSource.getSupplierById(id);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Lỗi tải thông tin nhà cung cấp'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> createSupplier({
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'Không có kết nối mạng.'));
    }
    try {
      final data = {
        'supplierName': supplierName,
        'contactName': contactName,
        'phone': phone,
        'address': address,
        'isActive': isActive ?? true,
        'categoryIds': categoryIds,
      };
      final model = await remoteDataSource.createSupplier(data);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Lỗi tạo nhà cung cấp'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SupplierEntity>> updateSupplier({
    required int id,
    required String supplierName,
    String? contactName,
    String? phone,
    String? address,
    bool? isActive,
    List<int>? categoryIds,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'Không có kết nối mạng.'));
    }
    try {
      final data = {
        'supplierName': supplierName,
        'contactName': contactName,
        'phone': phone,
        'address': address,
        if (isActive != null) 'isActive': isActive,
        'categoryIds': categoryIds,
      };
      final model = await remoteDataSource.updateSupplier(id, data);
      return Right(model);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Lỗi cập nhật nhà cung cấp'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSupplier(int id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'Không có kết nối mạng.'));
    }
    try {
      final result = await remoteDataSource.deleteSupplier(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data?['message'] ?? e.message ?? 'Lỗi xóa/ngừng hợp tác nhà cung cấp'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
