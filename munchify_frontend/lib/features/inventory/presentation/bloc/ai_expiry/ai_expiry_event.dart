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

class SubmitStaffReportEvent extends AiExpiryEvent {
  final int productId;
  final int quantity;
  final String reportType;
  final String reason;

  const SubmitStaffReportEvent({
    required this.productId,
    required this.quantity,
    required this.reportType,
    required this.reason,
  });

  @override
  List<Object> get props => [productId, quantity, reportType, reason];
}
