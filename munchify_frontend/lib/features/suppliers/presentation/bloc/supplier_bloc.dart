import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/manage_supplier_usecases.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final GetSuppliersUseCase getSuppliersUseCase;
  final CreateSupplierUseCase createSupplierUseCase;
  final UpdateSupplierUseCase updateSupplierUseCase;
  final DeleteSupplierUseCase deleteSupplierUseCase;

  SupplierBloc({
    required this.getSuppliersUseCase,
    required this.createSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
  }) : super(SupplierInitial()) {
    on<LoadSuppliersEvent>(_onLoadSuppliers);
    on<CreateSupplierEvent>(_onCreateSupplier);
    on<UpdateSupplierEvent>(_onUpdateSupplier);
    on<DeleteSupplierEvent>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliersEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    final result = await getSuppliersUseCase(
      search: event.search,
      isActive: event.isActive,
    );

    result.fold(
      (failure) => emit(SupplierError(failure.message)),
      (suppliers) => emit(SupplierLoaded(suppliers: suppliers)),
    );
  }

  Future<void> _onCreateSupplier(
    CreateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    final result = await createSupplierUseCase(
      supplierName: event.supplierName,
      contactName: event.contactName,
      phone: event.phone,
      address: event.address,
      isActive: event.isActive,
      categoryIds: event.categoryIds,
    );

    await result.fold(
      (failure) async => emit(SupplierError(failure.message)),
      (_) async {
        emit(const SupplierActionSuccess('Thêm nhà cung cấp mới thành công!'));
        add(const LoadSuppliersEvent());
      },
    );
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    final result = await updateSupplierUseCase(
      id: event.id,
      supplierName: event.supplierName,
      contactName: event.contactName,
      phone: event.phone,
      address: event.address,
      isActive: event.isActive,
      categoryIds: event.categoryIds,
    );

    await result.fold(
      (failure) async => emit(SupplierError(failure.message)),
      (_) async {
        emit(const SupplierActionSuccess('Cập nhật thông tin nhà cung cấp thành công!'));
        add(const LoadSuppliersEvent());
      },
    );
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    final result = await deleteSupplierUseCase(event.id);

    await result.fold(
      (failure) async => emit(SupplierError(failure.message)),
      (_) async {
        emit(const SupplierActionSuccess('Đã ngừng hợp tác nhà cung cấp thành công!'));
        add(const LoadSuppliersEvent());
      },
    );
  }
}
