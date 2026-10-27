import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../repositories/staff_repository.dart';
import '../../data/models/paged_staff_result.dart';

class GetStaffListUseCase {
  final StaffRepository repository;

  GetStaffListUseCase(this.repository);

  Future<Either<Failure, PagedStaffResult>> call({String? role, bool? isActive, String? searchKeyword, int page = 1, int pageSize = 10}) {
    return repository.getStaffList(role: role, isActive: isActive, searchKeyword: searchKeyword, page: page, pageSize: pageSize);
  }
}
