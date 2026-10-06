import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../../../core/utils/PagedResult.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_point_history_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_model.dart';
import '../models/customer_point_history_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerEntity>> searchByPhone(String phone) async {
    try {
      final result = await remoteDataSource.searchByPhone(phone);
      return Right(result);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return Left(NotFoundFailure(
          message: e.response?.data['message']?.toString() ??
              'Không tìm thấy khách hàng',
        ));
      }
      return Left(ServerFailure(
        message: e.response?.data['message']?.toString() ??
            e.message ??
            'Lỗi server',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String customerName,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.createCustomer({
        'customerName': customerName,
        'phone': phone,
      });
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data['message']?.toString() ??
            e.message ??
            'Lỗi server',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedResult<CustomerEntity>>> getAllCustomers(int pageIndex, int pageSize, String? searchKeyword) async {
    try {
      final result = await remoteDataSource.getAllCustomers(pageIndex, pageSize, searchKeyword);
      final items = (result['items'] as List)
          .map<CustomerEntity>((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(PagedResult<CustomerEntity>(
        items: items,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
        pageSize: result['pageSize'] as int,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PagedResult<CustomerPointHistoryEntity>>> getCustomerHistory(int customerId, int pageIndex, int pageSize) async {
    try {
      final result = await remoteDataSource.getCustomerHistory(customerId, pageIndex, pageSize);
      final items = (result['items'] as List)
          .map<CustomerPointHistoryEntity>((e) => CustomerPointHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(PagedResult<CustomerPointHistoryEntity>(
        items: items,
        totalCount: result['totalCount'] as int,
        pageNumber: result['pageNumber'] as int,
        pageSize: result['pageSize'] as int,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Lỗi server'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
