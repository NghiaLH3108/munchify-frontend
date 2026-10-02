// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_staff_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagedStaffResult _$PagedStaffResultFromJson(Map<String, dynamic> json) =>
    PagedStaffResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (PagedStaffResult._readPageNumber(json, 'page') as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PagedStaffResultToJson(PagedStaffResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
    };
