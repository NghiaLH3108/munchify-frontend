import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/staff_repository.dart';
import '../entities/staff_entity.dart';

class CreateStaffUseCase {
  final StaffRepository repository;

  CreateStaffUseCase(this.repository);

  Future<Either<Failure, StaffEntity>> call(Map<String, dynamic> staffData) {
    return repository.createStaff(staffData);
  }
}
