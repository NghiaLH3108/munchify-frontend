import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/DioClient.dart';
import 'features/admin/presentation/pages/admin_shell_screen.dart';
import 'features/staff/data/datasources/staff_remote_data_source.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/usecases/create_staff_usecase.dart';
import 'features/staff/domain/usecases/get_staff_list_usecase.dart';
import 'features/staff/domain/usecases/toggle_staff_status_usecase.dart';
import 'features/staff/domain/usecases/update_staff_usecase.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';

import 'core/theme/AppTheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Munchify POS - Admin Executive Analytics Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) {
          final dioClient = DioClient(secureStorage: const FlutterSecureStorage());
          dioClient.dio.options.baseUrl = 'http://localhost:5194'; // For testing / local dev

          final remoteDataSource = StaffRemoteDataSourceImpl(dioClient: dioClient);
          final repository = StaffRepositoryImpl(remoteDataSource: remoteDataSource);

          return BlocProvider(
            create: (_) => StaffBloc(
              getStaffList: GetStaffListUseCase(repository),
              createStaff: CreateStaffUseCase(repository),
              updateStaff: UpdateStaffUseCase(repository),
              toggleStaffStatus: ToggleStaffStatusUseCase(repository),
            ),
            child: const AdminShellScreen(initialTab: 'staff'),
          );
        },
      ),
    );
  }
}
