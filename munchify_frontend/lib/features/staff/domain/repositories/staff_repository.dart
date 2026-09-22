import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/staff_entity.dart';
import '../../data/models/paged_staff_result.dart';

abstract class StaffRepository {
  Future<Either<Failure, PagedStaffResult>> getStaffList({String? role, bool? isActive, int page = 1, int pageSize = 10});
  Future<Either<Failure, StaffEntity>> createStaff(Map<String, dynamic> staffData);
  Future<Either<Failure, StaffEntity>> updateStaff(int id, Map<String, dynamic> staffData);
  Future<Either<Failure, bool>> toggleStaffStatus(int id);
}
