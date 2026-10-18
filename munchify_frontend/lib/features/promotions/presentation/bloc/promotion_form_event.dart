import 'package:equatable/equatable.dart';

abstract class PromotionFormEvent extends Equatable {
  const PromotionFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadPromotionProducts extends PromotionFormEvent {
  const LoadPromotionProducts();
}

class SubmitPromotionForm extends PromotionFormEvent {
  final String? id; // if null, create. if not null, update
  final Map<String, dynamic> data;

  const SubmitPromotionForm({this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class ValidatePromotionForm extends PromotionFormEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const ValidatePromotionForm({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
