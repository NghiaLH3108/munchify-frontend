import 'package:equatable/equatable.dart';
import '../../../domain/entities/forecast_item_entity.dart';

abstract class LowStockEvent extends Equatable {
  const LowStockEvent();

  @override
  List<Object?> get props => [];
}

class FetchLowStockWarningEvent extends LowStockEvent {
  final int daysHistory;
  const FetchLowStockWarningEvent({this.daysHistory = 30});

  @override
  List<Object?> get props => [daysHistory];
}

class GenerateDraftImportsEvent extends LowStockEvent {
  final List<ForecastItemEntity> items;
  const GenerateDraftImportsEvent(this.items);

  @override
  List<Object?> get props => [items];
}
