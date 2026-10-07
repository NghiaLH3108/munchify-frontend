import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/combo_entity.dart';
import '../entities/combo_form_options_entity.dart';
import '../entities/combo_input.dart';

abstract class ComboRepository {
  Future<Either<Failure, ComboPageEntity>> getCombos({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  });

  Future<Either<Failure, ComboEntity>> createCombo(ComboInput input);

  Future<Either<Failure, ComboEntity>> updateCombo(int id, ComboInput input);

  /// Returns the server message (soft vs hard delete wording).
  Future<Either<Failure, String>> deleteCombo(int id);

  Future<Either<Failure, ComboFormOptionsEntity>> getFormOptions();
}
