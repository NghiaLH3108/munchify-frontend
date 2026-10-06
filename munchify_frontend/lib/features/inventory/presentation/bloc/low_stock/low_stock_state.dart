import 'package:equatable/equatable.dart';
import '../../../domain/entities/forecast_item_entity.dart';

abstract class LowStockState extends Equatable {
  const LowStockState();

  @override
  List<Object?> get props => [];
}

class LowStockInitial extends LowStockState {}

class LowStockLoading extends LowStockState {}

class LowStockLoaded extends LowStockState {
  final List<ForecastItemEntity> forecastItems;

  const LowStockLoaded(this.forecastItems);

  @override
  List<Object?> get props => [forecastItems];
}

class LowStockError extends LowStockState {
  final String message;
  const LowStockError(this.message);

  @override
  List<Object?> get props => [message];
}

class DraftImportGenerating extends LowStockState {}

class DraftImportGeneratedSuccess extends LowStockState {}

class DraftImportGeneratedError extends LowStockState {
  final String message;
  const DraftImportGeneratedError(this.message);

  @override
  List<Object?> get props => [message];
}
