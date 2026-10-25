import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_event.dart';
import 'staff_state.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/usecases/get_staff_list_usecase.dart';
import '../../domain/usecases/create_staff_usecase.dart';
import '../../domain/usecases/update_staff_usecase.dart';
import '../../domain/usecases/toggle_staff_status_usecase.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetStaffListUseCase getStaffList;
  final CreateStaffUseCase createStaff;
  final UpdateStaffUseCase updateStaff;
  final ToggleStaffStatusUseCase toggleStaffStatus;

  StaffListLoaded? _lastLoadedState;

  StaffBloc({
    required this.getStaffList,
    required this.createStaff,
    required this.updateStaff,
    required this.toggleStaffStatus,
  }) : super(StaffInitial()) {
    on<LoadStaffList>((event, emit) async {
      if (_lastLoadedState != null) {
        emit(_lastLoadedState!.copyWith(isRefreshing: true));
      } else {
        emit(StaffLoading());
      }
      final result = await getStaffList(
        page: event.page,
        pageSize: event.pageSize,
        role: event.role,
        isActive: event.isActive,
        searchKeyword: event.searchKeyword,
      );
      result.fold(
        (failure) {
          emit(StaffError(failure.message));
          if (_lastLoadedState != null) {
            emit(_lastLoadedState!.copyWith(isRefreshing: false));
          }
        },
        (pagedResult) {
          final isUnfiltered = event.role == null &&
              event.isActive == null &&
              (event.searchKeyword == null ||
                  event.searchKeyword!.trim().isEmpty) &&
              event.page == 1;
          final kpiItems = isUnfiltered
              ? pagedResult.items
              : (_lastLoadedState?.kpiItems ?? pagedResult.items);
          final nextState = StaffListLoaded(
            pagedResult,
            kpiStaffList: kpiItems,
            isRefreshing: false,
          );
          _lastLoadedState = nextState;
          emit(nextState);
        },
      );
    });

    on<CreateStaffEvent>((event, emit) async {
      final result = await createStaff(event.staffData);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (staff) {
          if (_lastLoadedState != null) {
            _lastLoadedState = _lastLoadedState!.copyWith(
              kpiStaffList: [staff, ..._lastLoadedState!.kpiItems],
            );
          }
          emit(const StaffActionSuccess('Tạo tài khoản thành công'));
        },
      );
    });

    on<UpdateStaffEvent>((event, emit) async {
      final result = await updateStaff(event.id, event.staffData);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (staff) {
          if (_lastLoadedState != null) {
            _lastLoadedState = _lastLoadedState!.copyWith(
              kpiStaffList: _lastLoadedState!.kpiItems
                  .map((s) => s.userId == staff.userId ? staff : s)
                  .toList(),
            );
          }
          emit(const StaffActionSuccess('Cập nhật thành công'));
        },
      );
    });

    on<ToggleStaffStatusEvent>((event, emit) async {
      final result = await toggleStaffStatus(event.id);
      result.fold(
        (failure) => emit(StaffError(failure.message)),
        (success) {
          if (_lastLoadedState != null) {
            _lastLoadedState = _lastLoadedState!.copyWith(
              kpiStaffList: _lastLoadedState!.kpiItems
                  .map((s) => s.userId == event.id
                      ? StaffEntity(
                          userId: s.userId,
                          username: s.username,
                          fullName: s.fullName,
                          phone: s.phone,
                          email: s.email,
                          role: s.role,
                          isActive: !s.isActive,
                          createdAt: s.createdAt,
                          updatedAt: s.updatedAt,
                        )
                      : s)
                  .toList(),
            );
          }
          emit(const StaffActionSuccess('Thay đổi trạng thái thành công'));
        },
      );
    });
  }
}
