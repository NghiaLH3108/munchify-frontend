import 'package:equatable/equatable.dart';
import '../../../domain/entities/damaged_expired_record_entity.dart';
import '../../../domain/entities/ai_expiry_summary_entity.dart';

abstract class AiExpiryState extends Equatable {
  const AiExpiryState();

  @override
  List<Object> get props => [];
}

class AiExpiryInitial extends AiExpiryState {}

class AiExpiryLoading extends AiExpiryState {}

class AiExpiryLoaded extends AiExpiryState {
  final List<DamagedExpiredRecordEntity> records;
  final AiExpirySummaryEntity summary;

  const AiExpiryLoaded({required this.records, required this.summary});

  @override
  List<Object> get props => [records, summary];
}

class AiExpiryError extends AiExpiryState {
  final String message;

  const AiExpiryError({required this.message});

  @override
  List<Object> get props => [message];
}

class AiExpiryApproveSuccess extends AiExpiryState {}

class AiExpiryReportSubmitting extends AiExpiryState {}

class AiExpiryReportSuccess extends AiExpiryState {
  final String message;
  const AiExpiryReportSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
