import 'package:json_annotation/json_annotation.dart';
import 'staff_model.dart';

part 'paged_staff_result.g.dart';

@JsonSerializable()
class PagedStaffResult {
  final List<StaffModel> items;
  final int totalCount;

  @JsonKey(readValue: _readPageNumber)
  final int page;
  final int pageSize;
  final int totalPages;

  static Object? _readPageNumber(Map json, String key) {
    return json['pageNumber'] ?? json['page'] ?? 1;
  }

  const PagedStaffResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedStaffResult.fromJson(Map<String, dynamic> json) => _$PagedStaffResultFromJson(json);

  Map<String, dynamic> toJson() => _$PagedStaffResultToJson(this);
}
