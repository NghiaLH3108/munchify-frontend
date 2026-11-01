import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/AppTheme.dart';
import 'features/main/presentation/screens/main_app_screen.dart';

// BLoCs
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/suppliers/presentation/bloc/supplier_bloc.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_event.dart';
import 'features/pos/presentation/bloc/cart_cubit.dart';
import 'features/pos/presentation/bloc/order_bloc.dart';

import 'features/inventory/presentation/bloc/stock_movement_bloc.dart';
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';
import 'features/units/presentation/bloc/unit_bloc.dart';
import 'features/combos/presentation/bloc/combo_bloc.dart';
import 'features/products/presentation/bloc/product_admin_bloc.dart';
import 'features/products/presentation/bloc/product_form_bloc.dart';
import 'features/inventory/presentation/bloc/ai_expiry/ai_expiry_bloc.dart';
import 'features/inventory/presentation/bloc/low_stock/low_stock_bloc.dart';

import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/admin_customer_bloc.dart';
import 'features/orders/presentation/bloc/admin_order_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/admin/presentation/pages/admin_shell_screen.dart';
import 'core/theme/ColorPalette.dart';

import 'core/services/signalr_service.dart';
import 'core/network/session_events.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/utils/platform_helper.dart';
import 'core/widgets/role_guard.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('vi_VN', null);
  await di.init();

  // SignalR được khởi tạo sau khi đăng nhập (hub yêu cầu JWT) – xem AuthGate.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<CategoryBloc>(create: (_) => di.sl<CategoryBloc>()),
        BlocProvider<SupplierBloc>(create: (_) => di.sl<SupplierBloc>()),
        BlocProvider<StaffBloc>(create: (_) => di.sl<StaffBloc>()),
        // Catalog chỉ được tải sau khi đăng nhập (xem AuthGate) để tránh gọi API khi chưa có token
        BlocProvider<PosCatalogBloc>(
          create: (_) => di.sl<PosCatalogBloc>(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => di.sl<CartCubit>(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => di.sl<OrderBloc>(),
        ),
        BlocProvider<AdminOrderBloc>(
          create: (_) => di.sl<AdminOrderBloc>(),
        ),
        BlocProvider<StockMovementBloc>(create: (_) => di.sl<StockMovementBloc>()),
        BlocProvider<StockImportBloc>(create: (_) => di.sl<StockImportBloc>()),
        BlocProvider<UnitBloc>(create: (_) => di.sl<UnitBloc>()),
        BlocProvider<ComboBloc>(create: (_) => di.sl<ComboBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => di.sl<CustomerBloc>()),
        BlocProvider<AdminCustomerBloc>(create: (_) => di.sl<AdminCustomerBloc>()),
        BlocProvider<ProductAdminBloc>(create: (_) => di.sl<ProductAdminBloc>()),
        BlocProvider<ProductFormBloc>(create: (_) => di.sl<ProductFormBloc>()),
        BlocProvider<AiExpiryBloc>(create: (_) => di.sl<AiExpiryBloc>()),
        BlocProvider<LowStockBloc>(create: (_) => di.sl<LowStockBloc>()),
      ],
      child: MaterialApp(
        title: 'Munchify POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<void>? _unauthorizedSub;
  StreamSubscription<void>? _forbiddenSub;

  @override
  void initState() {
    super.initState();
    // 401 từ server (token hết hạn/không hợp lệ) -> đăng xuất về Login
    _unauthorizedSub = SessionEvents.onUnauthorized.listen((_) {
      if (!mounted) return;
      final bloc = context.read<AuthBloc>();
      if (bloc.state is Authenticated) {
        bloc.add(const LogoutRequestedEvent());
      }
    });
    // 403: đã đăng nhập nhưng không đủ quyền
    _forbiddenSub = SessionEvents.onForbidden.listen((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Bạn không có quyền thực hiện chức năng này.'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    _forbiddenSub?.cancel();
    super.dispose();
  }

  void _onAuthChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      context.read<PosCatalogBloc>().add(LoadCatalogEvent());
      signalRService.init(token: state.token);
    } else if (state is Unauthenticated) {
      signalRService.stop();
      context.read<CartCubit>().clearCart();
      // Đóng mọi màn hình đang push trên nền để quay về Login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is Authenticated ||
          curr is Unauthenticated ||
          curr is AuthFailureState,
      listener: _onAuthChanged,
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) =>
            curr is AuthLoading ||
            curr is Authenticated ||
            curr is Unauthenticated ||
            curr is AuthFailureState,
        builder: (context, state) {
          if (state is Authenticated) {
            // App mobile: giao diện Staff (ADMIN cũng được phép vì có toàn quyền).
            if (PlatformHelper.isStaffPlatform) {
              return const MainAppScreen();
            }
            // Web/Windows: chỉ ADMIN được vào giao diện quản trị.
            return const RoleGuard(
              allowedRoles: ['ADMIN'],
              fallback: LoginScreen(),
              child: AdminShellScreen(initialTab: 'reports'),
            );
          }

          if (state is AuthLoading) {
            return const Scaffold(
              backgroundColor: ColorPalette.background,
              body: Center(
                child: CircularProgressIndicator(
                  color: ColorPalette.appetizingOrange,
                ),
              ),
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
