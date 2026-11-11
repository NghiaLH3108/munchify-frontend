import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/search_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_state.dart';
import 'package:munchify_frontend/features/customers/presentation/widgets/customer_loyalty_card.dart';

import '../../domain/usecases/customer_usecases_test.dart';

void main() {
  late CustomerBloc customerBloc;
  late MockCustomerRepository mockRepo;

  setUp(() {
    mockRepo = MockCustomerRepository();
    customerBloc = CustomerBloc(
      searchCustomer: SearchCustomerUseCase(mockRepo),
      createCustomer: CreateCustomerUseCase(mockRepo),
    );
  });

  tearDown(() {
    customerBloc.close();
  });

  final tCustomer = CustomerEntity(
    customerId: 1,
    customerName: 'Nguyễn Văn A',
    phone: '0987654321',
    loyaltyPoints: 50,
    createdAt: DateTime.now(),
  );

  testWidgets(
      'CustomerLoyaltyCard renders when CustomerSelected and rebuilds to SizedBox.shrink when CustomerInitial is emitted',
      (tester) async {
    customerBloc.emit(CustomerSelected(customer: tCustomer));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: customerBloc,
            child: const CustomerLoyaltyCard(),
          ),
        ),
      ),
    );

    // Card should be rendered with customer details
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('0987654321'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);

    // Emit CustomerInitial (simulating ClearSelectedCustomerEvent)
    customerBloc.emit(CustomerInitial());
    await tester.pump();

    // Verifying fix: The widget rebuilds on CustomerInitial and hides content
    expect(find.text('Nguyễn Văn A'), findsNothing);
    expect(find.text('0987654321'), findsNothing);
  });
}
