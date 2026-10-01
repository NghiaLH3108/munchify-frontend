import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/unit_entity.dart';

abstract class UnitRepository {
  Future<Either<Failure, List<UnitEntity>>> getUnits({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, UnitEntity>> getUnitById(int id);

  Future<Either<Failure, UnitEntity>> createUnit({
    required String unitName,
    String? description,
    bool isActive = true,
  });

  Future<Either<Failure, UnitEntity>> updateUnit({
    required int id,
    required String unitName,
    String? description,
    required bool isActive,
  });

  Future<Either<Failure, bool>> deleteUnit(int id);
}
