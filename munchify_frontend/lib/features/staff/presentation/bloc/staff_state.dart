import 'package:equatable/equatable.dart';
import '../../data/models/paged_staff_result.dart';
import '../../domain/entities/staff_entity.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffListLoaded extends StaffState {
  final PagedStaffResult result;
  final List<StaffEntity>? kpiStaffList;
  final bool isRefreshing;

  const StaffListLoaded(
    this.result, {
    this.kpiStaffList,
    this.isRefreshing = false,
  });

  List<StaffEntity> get kpiItems => kpiStaffList ?? result.items;

  StaffListLoaded copyWith({
    PagedStaffResult? result,
    List<StaffEntity>? kpiStaffList,
    bool? isRefreshing,
  }) {
    return StaffListLoaded(
      result ?? this.result,
      kpiStaffList: kpiStaffList ?? this.kpiStaffList,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [result, kpiStaffList, isRefreshing];
}

class StaffActionSuccess extends StaffState {
  final String message;

  const StaffActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}
