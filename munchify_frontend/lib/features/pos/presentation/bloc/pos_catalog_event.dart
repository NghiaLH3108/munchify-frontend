import 'package:equatable/equatable.dart';

abstract class PosCatalogEvent extends Equatable {
  const PosCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends PosCatalogEvent {}

class SearchProductEvent extends PosCatalogEvent {
  final String query;

  const SearchProductEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCategoryEvent extends PosCatalogEvent {
  final int? categoryId;

  const FilterByCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FilterByUnitEvent extends PosCatalogEvent {
  final String? unitName;

  const FilterByUnitEvent(this.unitName);

  @override
  List<Object?> get props => [unitName];
}
