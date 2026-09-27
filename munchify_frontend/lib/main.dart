import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di; // di = dependency injection
import 'features/inventory/presentation/bloc/stock_import_bloc.dart';
import 'features/inventory/presentation/screens/inventory_screen.dart';

void main() async {
  // Cần thêm dòng này vì chúng ta dùng async trong main()
  WidgetsFlutterBinding.ensureInitialized();
  
  // Gọi 1 dòng duy nhất để khởi tạo toàn bộ BLoC, UseCase, Repository, Dio...
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StockImportBloc>(
          // Lấy StockImportBloc ra từ Service Locator (sl) thay vì tự new bằng tay
          create: (_) => di.sl<StockImportBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Munchify POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE65100)),
          useMaterial3: true,
        ),
        home: const InventoryScreen(),
      ),
    );
  }
}

