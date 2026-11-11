import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../datasources/admin_order_remote_datasource.dart';
import '../models/admin_order_filter_params.dart';
import '../../domain/entities/admin_order_detail_entity.dart';
import '../../domain/entities/paged_orders_result.dart';
import '../../domain/repositories/admin_order_repository.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  final AdminOrderRemoteDataSource remoteDataSource;

  AdminOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedOrdersResult>> getOrders(AdminOrderFilterParams params) async {
    try {
      final result = await remoteDataSource.getOrders(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminOrderDetailEntity>> getOrderDetail(int orderId) async {
    try {
      final result = await remoteDataSource.getOrderDetail(orderId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Lỗi kết nối máy chủ',
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
