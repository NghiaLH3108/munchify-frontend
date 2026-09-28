import 'package:equatable/equatable.dart';

class StockImportEntity extends Equatable {
  final int importId;
  final String importCode;
  final int supplierId;
  final String supplierName;
  final int userId;
  final String userName;
  final double totalAmount;
  final String status;
  final DateTime importDate;
  final String? notes;
  final List<ImportDetailEntity> details;

  const StockImportEntity({
    required this.importId,
    required this.importCode,
    required this.supplierId,
    required this.supplierName,
    required this.userId,
    required this.userName,
    required this.totalAmount,
    required this.status,
    required this.importDate,
    this.notes,
    required this.details,
  });

  @override
  List<Object?> get props => [
        importId,
        importCode,
        supplierId,
        supplierName,
        userId,
        userName,
        totalAmount,
        status,
        importDate,
        notes,
        details,
      ];
}

class ImportDetailEntity extends Equatable {
  final int productId;
  final String productName;
  final String unitName;
  final int quantity;
  final double importPrice;
  final double totalAmount;

  const ImportDetailEntity({
    required this.productId,
    required this.productName,
    required this.unitName,
    required this.quantity,
    required this.importPrice,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        unitName,
        quantity,
        importPrice,
        totalAmount,
      ];
}
