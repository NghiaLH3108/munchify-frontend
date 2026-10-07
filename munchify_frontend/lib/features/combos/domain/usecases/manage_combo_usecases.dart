import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/Failures.dart';
import '../entities/combo_entity.dart';
import '../entities/combo_form_options_entity.dart';
import '../entities/combo_input.dart';
import '../repositories/combo_repository.dart';

class GetCombosUseCase {
  final ComboRepository repository;

  GetCombosUseCase(this.repository);

  Future<Either<Failure, ComboPageEntity>> call({
    String searchTerm = '',
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.getCombos(
      searchTerm: searchTerm,
      isActive: isActive,
      page: page,
      pageSize: pageSize,
    );
  }
}

class CreateComboUseCase {
  final ComboRepository repository;

  CreateComboUseCase(this.repository);

  Future<Either<Failure, ComboEntity>> call(ComboInput input) {
    return repository.createCombo(input);
  }
}

class UpdateComboUseCase {
  final ComboRepository repository;

  UpdateComboUseCase(this.repository);

  Future<Either<Failure, ComboEntity>> call(int id, ComboInput input) {
    return repository.updateCombo(id, input);
  }
}

class DeleteComboUseCase {
  final ComboRepository repository;

  DeleteComboUseCase(this.repository);

  Future<Either<Failure, String>> call(int id) {
    return repository.deleteCombo(id);
  }
}

class GetComboFormOptionsUseCase {
  final ComboRepository repository;

  GetComboFormOptionsUseCase(this.repository);

  Future<Either<Failure, ComboFormOptionsEntity>> call() {
    return repository.getFormOptions();
  }
}
