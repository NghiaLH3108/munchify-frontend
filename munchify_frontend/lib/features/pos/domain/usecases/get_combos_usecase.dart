import 'package:dartz/dartz.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/product_entity.dart';
import '../repositories/pos_repository.dart';

/// Use case: Lấy toàn bộ combo kèm danh sách thành phần (components)
/// cho Staff POS — dùng để hiển thị section Combo và tính SavingAmount.
class GetCombosUseCase {
  final PosRepository repository;

  GetCombosUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute() async {
    return await repository.getCombos();
  }
}
