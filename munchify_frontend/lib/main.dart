import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/AppTheme.dart';
import 'features/main/presentation/screens/main_app_screen.dart';

// BLoCs
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_bloc.dart';
import 'features/pos/presentation/bloc/pos_catalog_event.dart';
import 'features/inventory/presentation/bloc/stock_movement_bloc.dart';
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';
import 'features/units/presentation/bloc/unit_bloc.dart';

import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/customers/presentation/bloc/admin_customer_bloc.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(create: (_) => di.sl<CategoryBloc>()),
        BlocProvider<StaffBloc>(create: (_) => di.sl<StaffBloc>()),
        BlocProvider<PosCatalogBloc>(
          create: (_) => di.sl<PosCatalogBloc>()..add(LoadCatalogEvent()),
        ),
        BlocProvider<StockMovementBloc>(create: (_) => di.sl<StockMovementBloc>()),
        BlocProvider<StockImportBloc>(create: (_) => di.sl<StockImportBloc>()),
        BlocProvider<UnitBloc>(create: (_) => di.sl<UnitBloc>()),
        BlocProvider<CustomerBloc>(create: (_) => di.sl<CustomerBloc>()),
        BlocProvider<AdminCustomerBloc>(create: (_) => di.sl<AdminCustomerBloc>()),
      ],
      child: MaterialApp(
        title: 'Munchify POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainAppScreen(), // Đổi sang màn hình chính có bottom navigation
      ),
    );
  }
}
