import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/unit_entity.dart';
import '../repositories/unit_repository.dart';

class GetUnitsUseCase {
  final UnitRepository repository;

  GetUnitsUseCase(this.repository);

  Future<Either<Failure, List<UnitEntity>>> call({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await repository.getUnits(
      searchTerm: searchTerm,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
  }
}

class CreateUnitUseCase {
  final UnitRepository repository;

  CreateUnitUseCase(this.repository);

  Future<Either<Failure, UnitEntity>> call({
    required String unitName,
    String? description,
    bool isActive = true,
  }) async {
    return await repository.createUnit(
      unitName: unitName,
      description: description,
      isActive: isActive,
    );
  }
}

class UpdateUnitUseCase {
  final UnitRepository repository;

  UpdateUnitUseCase(this.repository);

  Future<Either<Failure, UnitEntity>> call({
    required int id,
    required String unitName,
    String? description,
    required bool isActive,
  }) async {
    return await repository.updateUnit(
      id: id,
      unitName: unitName,
      description: description,
      isActive: isActive,
    );
  }
}

class DeleteUnitUseCase {
  final UnitRepository repository;

  DeleteUnitUseCase(this.repository);

  Future<Either<Failure, bool>> call(int id) async {
    return await repository.deleteUnit(id);
  }
}
