import 'dart:async';

import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_input.dart';

abstract class ComboEvent extends Equatable {
  const ComboEvent();

  @override
  List<Object?> get props => [];
}

class LoadCombosEvent extends ComboEvent {
  final String searchTerm;
  final bool? isActive;
  final int page;
  final int pageSize;

  const LoadCombosEvent({
    this.searchTerm = '',
    this.isActive,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [searchTerm, isActive, page, pageSize];
}

/// [completer] resolves to `null` on success or an error message on failure,
/// so the form dialog can stay open and show the server validation error.
class CreateComboEvent extends ComboEvent {
  final ComboInput input;
  final Completer<String?> completer;

  const CreateComboEvent({required this.input, required this.completer});

  @override
  List<Object?> get props => [input, completer];
}

class UpdateComboEvent extends ComboEvent {
  final int id;
  final ComboInput input;
  final Completer<String?> completer;

  const UpdateComboEvent({
    required this.id,
    required this.input,
    required this.completer,
  });

  @override
  List<Object?> get props => [id, input, completer];
}

class DeleteComboEvent extends ComboEvent {
  final int id;

  const DeleteComboEvent(this.id);

  @override
  List<Object?> get props => [id];
}
