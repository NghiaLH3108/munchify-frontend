import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/staff_repository.dart';
import '../entities/staff_entity.dart';

class UpdateStaffUseCase {
  final StaffRepository repository;

  UpdateStaffUseCase(this.repository);

  Future<Either<Failure, StaffEntity>> call(int id, Map<String, dynamic> staffData) {
    return repository.updateStaff(id, staffData);
  }
}
