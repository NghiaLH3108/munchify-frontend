import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_event.dart';
import 'staff_state.dart';
import '../../domain/usecases/get_staff_list_usecase.dart';
import '../../domain/usecases/create_staff_usecase.dart';
import '../../domain/usecases/update_staff_usecase.dart';
import '../../domain/usecases/toggle_staff_status_usecase.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetStaffListUseCase getStaffList;
  final CreateStaffUseCase createStaff;
  final UpdateStaffUseCase updateStaff;
  final ToggleStaffStatusUseCase toggleStaffStatus;

  StaffBloc({
    required this.getStaffList,
    required this.createStaff,
    required this.updateStaff,
    required this.toggleStaffStatus,
  }) : super(StaffInitial()) {
    on<LoadStaffList>((event, emit) async {
      emit(StaffLoading());
      final result = await getStaffList(
        page: event.page,
        pageSize: event.pageSize,
        role: event.role,
        isActive: event.isActive,
      );
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (pagedResult) => emit(StaffListLoaded(pagedResult)),
      );
    });

    on<CreateStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await createStaff(event.staffData);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (staff) => emit(const StaffActionSuccess('Tạo tài khoản thành công')),
      );
    });

    on<UpdateStaffEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await updateStaff(event.id, event.staffData);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (staff) => emit(const StaffActionSuccess('Cập nhật thành công')),
      );
    });

    on<ToggleStaffStatusEvent>((event, emit) async {
      emit(StaffLoading());
      final result = await toggleStaffStatus(event.id);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (success) => emit(const StaffActionSuccess('Thay đổi trạng thái thành công')),
      );
    });
  }
}
