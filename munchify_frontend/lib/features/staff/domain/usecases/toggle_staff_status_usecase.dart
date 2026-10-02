import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/staff_repository.dart';

class ToggleStaffStatusUseCase {
  final StaffRepository repository;

  ToggleStaffStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) {
    return repository.toggleStaffStatus(id);
  }
}
