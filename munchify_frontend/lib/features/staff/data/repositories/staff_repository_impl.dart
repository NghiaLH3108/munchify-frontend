import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/Failures.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';
import '../models/paged_staff_result.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PagedStaffResult>> getStaffList({String? role, bool? isActive, int page = 1, int pageSize = 10}) async {
    try {
      final result = await remoteDataSource.getStaffList(role: role, isActive: isActive, page: page, pageSize: pageSize);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> createStaff(Map<String, dynamic> staffData) async {
    try {
      final result = await remoteDataSource.createStaff(staffData);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(int id, Map<String, dynamic> staffData) async {
    try {
      final result = await remoteDataSource.updateStaff(id, staffData);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleStaffStatus(int id) async {
    try {
      final result = await remoteDataSource.toggleStaffStatus(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.response?.data['message']?.toString() ?? e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
