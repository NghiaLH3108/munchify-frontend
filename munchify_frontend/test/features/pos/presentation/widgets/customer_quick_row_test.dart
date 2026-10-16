import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/customers/domain/entities/customer_entity.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/create_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/domain/usecases/search_customer_usecase.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:munchify_frontend/features/customers/presentation/bloc/customer_state.dart';
import 'package:munchify_frontend/features/customers/presentation/widgets/add_customer_bottom_sheet.dart';
import 'package:munchify_frontend/features/customers/presentation/widgets/customer_loyalty_card.dart';
import 'package:munchify_frontend/features/pos/presentation/widgets/customer_quick_row.dart';

import '../../../customers/domain/usecases/customer_usecases_test.dart';

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
      'CustomerQuickRow renders phone search bar and add customer button when no customer selected',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: customerBloc,
            child: const CustomerQuickRow(),
          ),
        ),
      ),
    );

    expect(find.text('Nhập SĐT khách (Tích điểm)...'), findsOneWidget);
    expect(find.text('Thêm khách'), findsOneWidget);
    expect(find.byIcon(Icons.person_add), findsOneWidget);
    expect(find.byType(CustomerLoyaltyCard), findsNothing);
  });

  testWidgets(
      'CustomerQuickRow switches to CustomerLoyaltyCard when CustomerSelected is emitted',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: customerBloc,
            child: const CustomerQuickRow(),
          ),
        ),
      ),
    );

    // Initial check
    expect(find.text('Thêm khách'), findsOneWidget);

    // Emit CustomerSelected
    customerBloc.emit(CustomerSelected(customer: tCustomer));
    await tester.pump();

    // Now CustomerLoyaltyCard should be visible and quick row hidden
    expect(find.byType(CustomerLoyaltyCard), findsOneWidget);
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Thêm khách'), findsNothing);
  });

  testWidgets(
      'CustomerQuickRow opens AddCustomerBottomSheet when Thêm khách button is tapped',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: customerBloc,
            child: const CustomerQuickRow(),
          ),
        ),
      ),
    );

    final addCustomerButton = find.text('Thêm khách');
    expect(addCustomerButton, findsOneWidget);

    await tester.tap(addCustomerButton);
    await tester.pumpAndSettle();

    // AddCustomerBottomSheet should be opened
    expect(find.byType(AddCustomerBottomSheet), findsOneWidget);
    expect(find.text('Thêm khách hàng mới'), findsOneWidget);
  });
}
