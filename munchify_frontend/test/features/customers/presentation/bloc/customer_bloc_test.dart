import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/core/constants/AppConstants.dart';
import 'package:munchify_frontend/core/errors/Failures.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_event.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_state.dart';

import '../../domain/usecases/customer_usecases_test.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/search_customer_usecase.dart';

void main() {
  late CustomerBloc bloc;
  late MockCustomerRepository mockRepository;
  late SearchCustomerUseCase searchUseCase;
  late CreateCustomerUseCase createUseCase;

  setUp(() {
    mockRepository = MockCustomerRepository();
    searchUseCase = SearchCustomerUseCase(mockRepository);
    createUseCase = CreateCustomerUseCase(mockRepository);
    bloc = CustomerBloc(
      searchCustomer: searchUseCase,
      createCustomer: createUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tCustomer = CustomerEntity(
    customerId: 1,
    customerName: 'Test',
    phone: '0912345678',
    loyaltyPoints: 10,
    createdAt: DateTime.now(),
  );

  test('initial state should be CustomerInitial', () {
    expect(bloc.state, CustomerInitial());
  });

  group('SearchCustomerByPhoneEvent', () {
    test('emits [CustomerSearching, CustomerFound] when successful', () async {
      mockRepository.searchResult = Right(tCustomer);

      final expected = [
        CustomerSearching(),
        CustomerFound(tCustomer),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchCustomerByPhoneEvent('0912345678'));
    });

    test('emits [CustomerSearching, CustomerNotFound] when failure occurs', () async {
      mockRepository.searchResult = const Left(NotFoundFailure());

      final expected = [
        CustomerSearching(),
        const CustomerNotFound('0999999999'),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const SearchCustomerByPhoneEvent('0999999999'));
    });
  });

  group('CreateCustomerEvent', () {
    test('emits [CustomerSearching, CustomerCreated, CustomerSelected] when successful', () async {
      mockRepository.createResult = Right(tCustomer);

      final expected = [
        CustomerSearching(),
        CustomerCreated(tCustomer),
        CustomerSelected(customer: tCustomer),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CreateCustomerEvent(customerName: 'Test', phone: '0912345678'));
    });
  });

  group('Loyalty Points Redemption', () {
    test('ToggleRedeemPointsEvent should update state correctly', () {
      bloc.emit(CustomerSelected(customer: tCustomer));

      final expected = CustomerSelected(
        customer: tCustomer,
        isRedeeming: true,
        pointsToRedeem: 10,
        discountFromPoints: 10 * AppConstants.pointsToVndRate,
      );

      expectLater(bloc.stream, emits(expected));
      bloc.add(const ToggleRedeemPointsEvent(true));
    });

    test('UpdateRedeemPointsEvent should clamp points within bounds', () {
      bloc.emit(CustomerSelected(
        customer: tCustomer,
        isRedeeming: true,
        pointsToRedeem: 10,
      ));

      // Trying to redeem more than loyaltyPoints (10) should clamp to 10
      final expected = CustomerSelected(
        customer: tCustomer,
        isRedeeming: true,
        pointsToRedeem: 10,
        discountFromPoints: 10 * AppConstants.pointsToVndRate,
      );

      expectLater(bloc.stream, emits(expected));
      bloc.add(const UpdateRedeemPointsEvent(20));
    });
  });
}
