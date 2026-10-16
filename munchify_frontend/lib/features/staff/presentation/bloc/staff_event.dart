import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffList extends StaffEvent {
  final int page;
  final int pageSize;
  final String? role;
  final bool? isActive;
  final String? searchKeyword;

  const LoadStaffList({this.page = 1, this.pageSize = 10, this.role, this.isActive, this.searchKeyword});

  @override
  List<Object?> get props => [page, pageSize, role, isActive, searchKeyword];
}

class CreateStaffEvent extends StaffEvent {
  final Map<String, dynamic> staffData;

  const CreateStaffEvent(this.staffData);

  @override
  List<Object?> get props => [staffData];
}

class UpdateStaffEvent extends StaffEvent {
  final int id;
  final Map<String, dynamic> staffData;

  const UpdateStaffEvent(this.id, this.staffData);

  @override
  List<Object?> get props => [id, staffData];
}

class ToggleStaffStatusEvent extends StaffEvent {
  final int id;

  const ToggleStaffStatusEvent(this.id);

  @override
  List<Object?> get props => [id];
}
