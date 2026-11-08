import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:munchify_frontend/features/admin/presentation/pages/admin_shell_screen.dart';
import 'package:munchify_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:munchify_frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:munchify_frontend/features/pos/presentation/widgets/pos_app_bar.dart';

class MockAuthBloc extends Bloc<AuthEvent, AuthState> implements AuthBloc {
  MockAuthBloc(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const adminUser = UserEntity(
    userId: 1,
    username: 'admin',
    fullName: 'Hoàng Minh',
    email: 'admin@munchify.vn',
    phone: '0901234567',
    role: 'ADMIN',
    isActive: true,
  );

  const staffUser = UserEntity(
    userId: 2,
    username: 'staff_thu_ngan',
    fullName: 'Nguyễn Văn Thu Ngân',
    email: 'staff@munchify.vn',
    phone: '0909888777',
    role: 'STAFF',
    isActive: true,
  );

  Widget createPosAppBarTestWidget({required AuthState authState}) {
    final mockBloc = MockAuthBloc(authState);
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockBloc,
        child: const Scaffold(
          appBar: PosAppBar(),
          body: Center(child: Text('POS Body')),
        ),
      ),
    );
  }

  void ignoreRenderFlexOverflows(WidgetTester tester) {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final bool isOverflow = details.exceptionAsString().contains('overflowed by');
      if (!isOverflow) {
        originalOnError?.call(details);
      }
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });
  }

  group('PosAppBar Role-Based Admin Console Access Tests', () {
    testWidgets('displays "Trang Quản trị Admin" menu item when authenticated user is Admin on desktop platform', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      ignoreRenderFlexOverflows(tester);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        debugDefaultTargetPlatformOverride = null;
      });

      await tester.pumpWidget(createPosAppBarTestWidget(
        authState: const Authenticated(user: adminUser, token: 'mock_token'),
      ));
      await tester.pumpAndSettle();

      // Open profile popup menu
      final popupMenuFinder = find.byType(PopupMenuButton<String>);
      expect(popupMenuFinder, findsOneWidget);

      await tester.tap(popupMenuFinder);
      await tester.pumpAndSettle();

      // Verify Admin Console navigation option is visible on desktop
      expect(find.text('Trang Quản trị Admin'), findsOneWidget);
      expect(find.text('Đăng xuất ca làm'), findsOneWidget);
      expect(find.text('Hoàng Minh'), findsNWidgets(2)); // avatar button + popup item
      expect(find.text('Quản trị viên'), findsOneWidget);
    });

    testWidgets('hides "Trang Quản trị Admin" menu item when authenticated user is Admin on Android', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      ignoreRenderFlexOverflows(tester);
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        debugDefaultTargetPlatformOverride = null;
      });

      await tester.pumpWidget(createPosAppBarTestWidget(
        authState: const Authenticated(user: adminUser, token: 'mock_token'),
      ));
      await tester.pumpAndSettle();

      final popupMenuFinder = find.byType(PopupMenuButton<String>);
      expect(popupMenuFinder, findsOneWidget);

      await tester.tap(popupMenuFinder);
      await tester.pumpAndSettle();

      // Admin Console navigation must be blocked on Android
      expect(find.text('Trang Quản trị Admin'), findsNothing);
      expect(find.text('Đăng xuất ca làm'), findsOneWidget);
    });

    testWidgets('hides "Trang Quản trị Admin" menu item when authenticated user is Staff', (tester) async {
      ignoreRenderFlexOverflows(tester);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createPosAppBarTestWidget(
        authState: const Authenticated(user: staffUser, token: 'mock_token'),
      ));
      await tester.pumpAndSettle();

      final popupMenuFinder = find.byType(PopupMenuButton<String>);
      expect(popupMenuFinder, findsOneWidget);

      await tester.tap(popupMenuFinder);
      await tester.pumpAndSettle();

      // Menu must be hidden for standard Staff
      expect(find.text('Trang Quản trị Admin'), findsNothing);
      expect(find.text('Đăng xuất ca làm'), findsOneWidget);
      expect(find.text('Nguyễn Văn Thu Ngân'), findsNWidgets(2));
      expect(find.text('Thu ngân'), findsOneWidget);
    });

    testWidgets('hides "Trang Quản trị Admin" menu item when state is Unauthenticated', (tester) async {
      ignoreRenderFlexOverflows(tester);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createPosAppBarTestWidget(
        authState: const Unauthenticated(),
      ));
      await tester.pumpAndSettle();

      final popupMenuFinder = find.byType(PopupMenuButton<String>);
      expect(popupMenuFinder, findsOneWidget);

      await tester.tap(popupMenuFinder);
      await tester.pumpAndSettle();

      expect(find.text('Trang Quản trị Admin'), findsNothing);
      expect(find.text('Đăng xuất ca làm'), findsOneWidget);
    });
  });

  group('AdminShellScreen Navigation & Quick Access CTA Tests', () {
    testWidgets('renders "+ Tạo đơn POS" button and placeholder navigation buttons', (tester) async {
      ignoreRenderFlexOverflows(tester);
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminShellScreen(initialTab: 'cashbook'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the CTA button on Desktop sidebar exists
      expect(find.text('+ Tạo đơn POS'), findsOneWidget);

      // Verify the placeholder screen navigation buttons exist
      expect(find.text('Quay lại Báo cáo & Thống kê'), findsOneWidget);
      expect(find.text('Đến Quầy bán hàng (POS)'), findsOneWidget);
    });
  });
}
