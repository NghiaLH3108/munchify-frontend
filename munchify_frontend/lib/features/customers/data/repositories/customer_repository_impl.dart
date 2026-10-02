import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';

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
}
