import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/create_staff_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/get_staff_list_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/toggle_staff_status_usecase.dart';
import 'package:munchify_frontend/features/staff/domain/usecases/update_staff_usecase.dart';
import 'package:munchify_frontend/features/staff/presentation/bloc/staff_bloc.dart';
import 'package:munchify_frontend/features/staff/presentation/pages/staff_management_screen.dart';

import 'features/staff/domain/usecases/staff_usecases_test.dart';

void main() {
  testWidgets('StaffManagementScreen renders properly and displays staff data', (WidgetTester tester) async {
    final mockRepo = MockStaffRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => StaffBloc(
            getStaffList: GetStaffListUseCase(mockRepo),
            createStaff: CreateStaffUseCase(mockRepo),
            updateStaff: UpdateStaffUseCase(mockRepo),
            toggleStaffStatus: ToggleStaffStatusUseCase(mockRepo),
          ),
          child: const StaffManagementScreen(),
        ),
      ),
    );

    // Process asynchronous Bloc state update
    await tester.pumpAndSettle();

    // Verify header and staff data from repository is displayed
    expect(find.text('Quản lý Nhân sự & Phân quyền'), findsOneWidget);
    expect(find.text('+ Thêm Nhân Viên'), findsOneWidget);
    expect(find.text('@test_user'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('STAFF'), findsWidgets);
  });
}
