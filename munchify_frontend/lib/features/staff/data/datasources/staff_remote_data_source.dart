import '../../../../core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/staff_model.dart';
import '../models/paged_staff_result.dart';

abstract class StaffRemoteDataSource {
  Future<PagedStaffResult> getStaffList({String? role, bool? isActive, int page = 1, int pageSize = 10});
  Future<StaffModel> createStaff(Map<String, dynamic> staffData);
  Future<StaffModel> updateStaff(int id, Map<String, dynamic> staffData);
  Future<bool> toggleStaffStatus(int id);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final DioClient dioClient;

  StaffRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PagedStaffResult> getStaffList({String? role, bool? isActive, int page = 1, int pageSize = 10}) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (role != null && role.isNotEmpty) queryParameters['role'] = role;
    if (isActive != null) queryParameters['isActive'] = isActive;

    final response = await dioClient.dio.get(ApiEndpoints.users, queryParameters: queryParameters);
    
    // Backend wraps response in ApiResponse<T>
    if (response.data['success'] == true) {
      return PagedStaffResult.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to load staff list');
    }
  }

  @override
  Future<StaffModel> createStaff(Map<String, dynamic> staffData) async {
    final response = await dioClient.dio.post(ApiEndpoints.users, data: staffData);
    if (response.data['success'] == true) {
      return StaffModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create staff');
    }
  }

  @override
  Future<StaffModel> updateStaff(int id, Map<String, dynamic> staffData) async {
    final response = await dioClient.dio.put('${ApiEndpoints.users}/$id', data: staffData);
    if (response.data['success'] == true) {
      return StaffModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to update staff');
    }
  }

  @override
  Future<bool> toggleStaffStatus(int id) async {
    final response = await dioClient.dio.patch('${ApiEndpoints.users}/$id/status');
    if (response.data['success'] == true) {
      return response.data['data'] as bool;
    } else {
      throw Exception(response.data['message'] ?? 'Failed to toggle staff status');
    }
  }
}
