import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';
import 'package:munchify_frontend/features/customers/domain/repositories/customer_repository.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/search_customer_usecase.dart';
import 'package:munchify_frontend/core/utils/PagedResult.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_point_history_entity.dart';

class MockCustomerRepository implements CustomerRepository {
  Either<Failure, CustomerEntity>? searchResult;
  Either<Failure, CustomerEntity>? createResult;

  @override
  Future<Either<Failure, CustomerEntity>> searchByPhone(String phone) async {
    return searchResult!;
  }

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer({
    required String customerName,
    required String phone,
  }) async {
    return createResult!;
  }

  @override
  Future<Either<Failure, PagedResult<CustomerEntity>>> getAllCustomers(int pageIndex, int pageSize, String? searchKeyword) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, PagedResult<CustomerPointHistoryEntity>>> getCustomerHistory(int customerId, int pageIndex, int pageSize) async {
    throw UnimplementedError();
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
    customerName: 'Test',
    phone: '0912345678',
    loyaltyPoints: 0,
    createdAt: DateTime.now(),
  );

  group('SearchCustomerUseCase', () {
    test('should return CustomerEntity when search is successful', () async {
      // arrange
      mockRepository.searchResult = Right(tCustomer);
      // act
      final result = await searchUseCase('0912345678');
      // assert
      expect(result, Right(tCustomer));
    });

    test('should return Failure when search fails', () async {
      // arrange
      mockRepository.searchResult = const Left(NotFoundFailure());
      // act
      final result = await searchUseCase('0999999999');
      // assert
      expect(result, const Left(NotFoundFailure()));
    });
  });

  group('CreateCustomerUseCase', () {
    test('should return CustomerEntity when create is successful', () async {
      // arrange
      mockRepository.createResult = Right(tCustomer);
      // act
      final result = await createUseCase(customerName: 'Test', phone: '0912345678');
      // assert
      expect(result, Right(tCustomer));
    });

    test('should return Failure when create fails', () async {
      // arrange
      mockRepository.createResult = const Left(ServerFailure(message: 'Error'));
      // act
      final result = await createUseCase(customerName: 'Test', phone: '0912345678');
      // assert
      expect(result, const Left(ServerFailure(message: 'Error')));
    });
  });
}
