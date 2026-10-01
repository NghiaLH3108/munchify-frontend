import 'package:equatable/equatable.dart';

class UnitEntity extends Equatable {
  final int id;
  final String unitName;
  final String? description;
  final bool isActive;

  const UnitEntity({
    required this.id,
    required this.unitName,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, unitName, description, isActive];
}
