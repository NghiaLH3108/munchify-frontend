import '../../../../core/network/DioClient.dart';
import '../../../../core/constants/ApiEndpoints.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerModel> searchByPhone(String phone);
  Future<CustomerModel> createCustomer(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getAllCustomers(int pageIndex, int pageSize, String? searchKeyword);
  Future<Map<String, dynamic>> getCustomerHistory(int customerId, int pageIndex, int pageSize);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final DioClient dioClient;

  CustomerRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<CustomerModel> searchByPhone(String phone) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.customers}/search',
      queryParameters: {'phone': phone},
    );

    // Backend wraps response in ApiResponse<T>
    if (response.data['success'] == true) {
      return CustomerModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Không tìm thấy khách hàng');
    }
  }

  @override
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.customers,
      data: data,
    );

    if (response.data['success'] == true) {
      return CustomerModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Không thể tạo khách hàng');
    }
  }

  @override
  Future<Map<String, dynamic>> getAllCustomers(int pageIndex, int pageSize, String? searchKeyword) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.customers,
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        if (searchKeyword != null && searchKeyword.isNotEmpty) 'searchKeyword': searchKeyword,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Lỗi khi tải danh sách khách hàng');
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerHistory(int customerId, int pageIndex, int pageSize) async {
    final response = await dioClient.dio.get(
      '${ApiEndpoints.customers}/$customerId/history',
      queryParameters: {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      },
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? 'Lỗi khi tải lịch sử điểm');
    }
  }
}
