import 'package:equatable/equatable.dart';

abstract class AiExpiryEvent extends Equatable {
  const AiExpiryEvent();

  @override
  List<Object> get props => [];
}

class FetchPendingRecordsEvent extends AiExpiryEvent {}

class ApproveRecordEvent extends AiExpiryEvent {
  final int recordId;

  const ApproveRecordEvent(this.recordId);

  @override
  List<Object> get props => [recordId];
}
