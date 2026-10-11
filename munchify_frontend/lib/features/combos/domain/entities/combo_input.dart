import 'package:equatable/equatable.dart';

class ComboItemInput extends Equatable {
  final int componentProductId;
  final int quantity;

  const ComboItemInput({
    required this.componentProductId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [componentProductId, quantity];
}

/// Payload to create or update a combo.
class ComboInput extends Equatable {
  final String? code;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final List<ComboItemInput> items;

  const ComboInput({
    this.code,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isActive,
    required this.items,
  });

  @override
  List<Object?> get props => [
        code,
        name,
        description,
        price,
        imageUrl,
        isActive,
        items,
      ];
}
