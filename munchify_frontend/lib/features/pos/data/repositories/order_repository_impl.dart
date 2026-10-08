import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    int? customerId,
    String? promotionCode,
    required String paymentMethod,
    int pointsToRedeem = 0,
    required List<Map<String, int>> items,
  }) async {
    try {
      final result = await remoteDataSource.createOrder(
        customerId: customerId,
        promotionCode: promotionCode,
        paymentMethod: paymentMethod,
        pointsToRedeem: pointsToRedeem,
        items: items,
      );
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ??
          e.message ??
          'Lỗi kết nối máy chủ';
      return Left(ServerFailure(message: msg));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result =
          await remoteDataSource.getOrders(page: page, pageSize: pageSize);
      return Right(result);
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ??
          e.message ??
          'Lỗi kết nối máy chủ';
      return Left(ServerFailure(message: msg));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
