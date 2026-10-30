import 'package:equatable/equatable.dart';

/// period: day | month | year
class ReportFilter extends Equatable {
  final String period;
  final DateTime date;

  const ReportFilter({required this.period, required this.date});

  factory ReportFilter.today() =>
      ReportFilter(period: 'day', date: DateTime.now());

  ReportFilter copyWith({String? period, DateTime? date}) =>
      ReportFilter(period: period ?? this.period, date: date ?? this.date);

  /// Query parameters matching the backend contract.
  Map<String, dynamic> toQuery() {
    switch (period) {
      case 'month':
        return {'period': 'month', 'year': date.year, 'month': date.month};
      case 'year':
        return {'period': 'year', 'year': date.year};
      default:
        final m = date.month.toString().padLeft(2, '0');
        final d = date.day.toString().padLeft(2, '0');
        return {'period': 'day', 'date': '${date.year}-$m-$d'};
    }
  }

  @override
  List<Object?> get props => [period, date.year, date.month, date.day];
}
