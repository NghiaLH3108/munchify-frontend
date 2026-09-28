import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/stock_import_entity.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/stock_remote_data_source.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource remoteDataSource;

  StockRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StockImportEntity>>> getStockImports() async {
    try {
      final imports = await remoteDataSource.getStockImports();
      return Right(imports);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockImportEntity>> getStockImportById(int id) async {
    try {
      final importDetail = await remoteDataSource.getStockImportById(id);
      return Right(importDetail);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createDraftImport(int supplierId, String? notes, List<Map<String, dynamic>> items) async {
    try {
      final id = await remoteDataSource.createDraftImport(supplierId, notes, items);
      return Right(id);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> completeImport(int id) async {
    try {
      final success = await remoteDataSource.completeImport(id);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelImport(int id) async {
    try {
      final success = await remoteDataSource.cancelImport(id);
      return Right(success);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
