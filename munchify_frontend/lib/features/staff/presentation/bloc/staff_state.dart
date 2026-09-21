import 'package:equatable/equatable.dart';
import '../../data/models/paged_staff_result.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffListLoaded extends StaffState {
  final PagedStaffResult result;

  const StaffListLoaded(this.result);

  @override
  List<Object?> get props => [result];
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
