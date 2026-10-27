import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_point_history_entity.dart';
import 'package:munchify_frontend/features/customers/domain/repositories/customer_repository.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/search_customer_usecase.dart';

class MockCustomerRepository implements CustomerRepository {
  Either<Failure, CustomerEntity>? searchResult;
  Either<Failure, CustomerEntity>? createResult;
  CustomerEntity? defaultCustomer;

  @override
  Future<Either<Failure, CustomerEntity>> searchByPhone(String phone) async {
    if (searchResult != null) return searchResult!;
    return Right(defaultCustomer ?? CustomerEntity(
      customerId: 1,
      customerName: 'Nguyễn Văn A',
      phone: phone,
      loyaltyPoints: 50,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String customerName,
    required String phone,
  }) async {
    if (createResult != null) return createResult!;
    return Right(CustomerEntity(
      customerId: 2,
      customerName: customerName,
      phone: phone,
      loyaltyPoints: 0,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, PagedResult<CustomerEntity>>> getAllCustomers(
      int pageIndex, int pageSize, String? searchKeyword) async {
    return Right(PagedResult<CustomerEntity>(
      items: defaultCustomer != null ? [defaultCustomer!] : [],
      totalCount: defaultCustomer != null ? 1 : 0,
      pageNumber: pageIndex,
      pageSize: pageSize,
    ));
  }

  @override
  Future<Either<Failure, PagedResult<CustomerPointHistoryEntity>>> getCustomerHistory(
      int customerId, int pageIndex, int pageSize) async {
    return Right(PagedResult<CustomerPointHistoryEntity>(
      items: [],
      totalCount: 0,
      pageNumber: pageIndex,
      pageSize: pageSize,
    ));
  }
}

void main() {
  late SearchCustomerUseCase searchUseCase;
  late CreateCustomerUseCase createUseCase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    searchUseCase = SearchCustomerUseCase(mockRepository);
    createUseCase = CreateCustomerUseCase(mockRepository);
  });

  final tCustomer = CustomerEntity(
    customerId: 1,
    customerName: 'Test Customer',
    phone: '0912345678',
    loyaltyPoints: 0,
    createdAt: DateTime.now(),
  );

  group('SearchCustomerUseCase', () {
    test('should return CustomerEntity when search is successful', () async {
      mockRepository.searchResult = Right(tCustomer);
      final result = await searchUseCase('0912345678');
      expect(result, Right(tCustomer));
    });

    test('should return Failure when search fails', () async {
      mockRepository.searchResult = const Left(NotFoundFailure());
      final result = await searchUseCase('0999999999');
      expect(result, const Left(NotFoundFailure()));
    });
  });

  group('CreateCustomerUseCase', () {
    test('should return CustomerEntity when create is successful', () async {
      mockRepository.createResult = Right(tCustomer);
      final result = await createUseCase(customerName: 'Test Customer', phone: '0912345678');
      expect(result, Right(tCustomer));
    });

    test('should return Failure when create fails', () async {
      mockRepository.createResult = const Left(ServerFailure(message: 'Error'));
      final result = await createUseCase(customerName: 'Test Customer', phone: '0912345678');
      expect(result, const Left(ServerFailure(message: 'Error')));
    });
  });
}
