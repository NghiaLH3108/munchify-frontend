import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitsEvent extends UnitEvent {
  final String searchTerm;
  final bool? isActive;
  final int page;
  final int pageSize;

  const LoadUnitsEvent({
    this.searchTerm = '',
    this.isActive,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [searchTerm, isActive, page, pageSize];
}

class CreateUnitEvent extends UnitEvent {
  final String unitName;
  final String? description;
  final bool isActive;

  const CreateUnitEvent({
    required this.unitName,
    this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [unitName, description, isActive];
}

class UpdateUnitEvent extends UnitEvent {
  final int id;
  final String unitName;
  final String? description;
  final bool isActive;

  const UpdateUnitEvent({
    required this.id,
    required this.unitName,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, unitName, description, isActive];
}

class DeleteUnitEvent extends UnitEvent {
  final int id;

  const DeleteUnitEvent(this.id);

  @override
  List<Object?> get props => [id];
}
