// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_import_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockImportModel _$StockImportModelFromJson(Map<String, dynamic> json) =>
    StockImportModel(
      importId: (json['importId'] as num).toInt(),
      importCode: json['importCode'] as String,
      supplierId: (json['supplierId'] as num).toInt(),
      supplierName: json['supplierName'] as String,
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      importDate: DateTime.parse(json['importDate'] as String),
      notes: json['notes'] as String?,
      details: (json['details'] as List<dynamic>)
          .map((e) => ImportDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StockImportModelToJson(StockImportModel instance) =>
    <String, dynamic>{
      'importId': instance.importId,
      'importCode': instance.importCode,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'userId': instance.userId,
      'userName': instance.userName,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'importDate': instance.importDate.toIso8601String(),
      'notes': instance.notes,
      'details': instance.details.map((e) => e.toJson()).toList(),
    };

ImportDetailModel _$ImportDetailModelFromJson(Map<String, dynamic> json) =>
    ImportDetailModel(
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      unitName: json['unitName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      importPrice: (json['importPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );

Map<String, dynamic> _$ImportDetailModelToJson(ImportDetailModel instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'unitName': instance.unitName,
      'quantity': instance.quantity,
      'importPrice': instance.importPrice,
      'totalAmount': instance.totalAmount,
    };
