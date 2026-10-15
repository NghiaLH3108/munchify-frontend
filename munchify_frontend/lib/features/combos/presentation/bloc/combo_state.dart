import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_entity.dart';

abstract class ComboState extends Equatable {
  const ComboState();

  @override
  List<Object?> get props => [];
}

class ComboInitial extends ComboState {}

class ComboLoading extends ComboState {}

class ComboLoaded extends ComboState {
  final List<ComboEntity> combos;
  final int totalCount;
  final int page;
  final int pageSize;
  final String? successMessage;
  final String? errorMessage;

  /// Forces re-emission when the same message repeats.
  final int stamp;

  const ComboLoaded({
    required this.combos,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    this.successMessage,
    this.errorMessage,
    this.stamp = 0,
  });

  int get totalPages => pageSize > 0 ? (totalCount / pageSize).ceil() : 0;

  @override
  List<Object?> get props => [
        combos,
        totalCount,
        page,
        pageSize,
        successMessage,
        errorMessage,
        stamp,
      ];
}

class ComboError extends ComboState {
  final String message;

  const ComboError(this.message);

  @override
  List<Object?> get props => [message];
}
