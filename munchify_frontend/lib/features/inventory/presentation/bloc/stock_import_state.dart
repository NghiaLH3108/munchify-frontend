import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_import_entity.dart';

abstract class StockImportState extends Equatable {
  const StockImportState();

  @override
  List<Object?> get props => [];
}

class StockImportInitial extends StockImportState {}

class StockImportLoading extends StockImportState {}

class StockImportsLoaded extends StockImportState {
  final List<StockImportEntity> imports;

  const StockImportsLoaded(this.imports);

  @override
  List<Object?> get props => [imports];
}

class StockImportActionSuccess extends StockImportState {
  final String message;

  const StockImportActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StockImportError extends StockImportState {
  final String message;

  const StockImportError(this.message);

  @override
  List<Object?> get props => [message];
}
