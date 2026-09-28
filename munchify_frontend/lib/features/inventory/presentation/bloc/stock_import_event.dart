import 'package:equatable/equatable.dart';

abstract class StockImportEvent extends Equatable {
  const StockImportEvent();

  @override
  List<Object?> get props => [];
}

class FetchStockImportsEvent extends StockImportEvent {}

class CreateDraftImportEvent extends StockImportEvent {
  final int supplierId;
  final String? notes;
  final List<Map<String, dynamic>> items;

  const CreateDraftImportEvent({
    required this.supplierId,
    this.notes,
    required this.items,
  });

  @override
  List<Object?> get props => [supplierId, notes, items];
}

class CompleteImportEvent extends StockImportEvent {
  final int id;

  const CompleteImportEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class CancelImportEvent extends StockImportEvent {
  final int id;

  const CancelImportEvent(this.id);

  @override
  List<Object?> get props => [id];
}
