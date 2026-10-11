import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/combo_form_options_entity.dart';
import '../../domain/usecases/manage_combo_usecases.dart';

abstract class ComboFormOptionsState extends Equatable {
  const ComboFormOptionsState();

  @override
  List<Object?> get props => [];
}

class ComboFormOptionsInitial extends ComboFormOptionsState {}

class ComboFormOptionsLoading extends ComboFormOptionsState {}

class ComboFormOptionsLoaded extends ComboFormOptionsState {
  final ComboFormOptionsEntity options;

  const ComboFormOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

class ComboFormOptionsError extends ComboFormOptionsState {
  final String message;

  const ComboFormOptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Loads categories, units and single products used by the combo form.
class ComboFormOptionsCubit extends Cubit<ComboFormOptionsState> {
  final GetComboFormOptionsUseCase getFormOptions;

  ComboFormOptionsCubit({required this.getFormOptions})
      : super(ComboFormOptionsInitial());

  Future<void> load() async {
    emit(ComboFormOptionsLoading());
    final result = await getFormOptions();
    result.fold(
      (failure) => emit(ComboFormOptionsError(failure.message)),
      (options) => emit(ComboFormOptionsLoaded(options)),
    );
  }
}
