import 'package:intl/intl.dart';

/// Date and time formatting utilities for Munchify POS.
///
/// All display formats follow Vietnamese locale conventions.
/// API communication uses ISO 8601 (UTC).
///
/// Usage:
/// ```dart
/// DateFormatter.toDisplayDate(DateTime.now()); // → '21/09/2026'
/// DateFormatter.fromIso8601('2026-09-21T03:00:00Z'); // → DateTime (local)
/// ```
class DateFormatter {
  DateFormatter._();

  // ─── Private Formatters ───────────────────────────────────────────────────

  static final DateFormat _displayDate =
      DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat _displayDateTime =
      DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
  static final DateFormat _displayTime = DateFormat('HH:mm', 'vi_VN');
  static final DateFormat _fullDateTime =
      DateFormat('dd/MM/yyyy HH:mm:ss', 'vi_VN');
  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthYear = DateFormat('MM/yyyy', 'vi_VN');

  // ─── Display Formatters ───────────────────────────────────────────────────

  /// `21/09/2026`
  static String toDisplayDate(DateTime date) => _displayDate.format(date);

  /// `21/09/2026 10:05`
  static String toDisplayDateTime(DateTime date) =>
      _displayDateTime.format(date);

  /// `10:05`
  static String toDisplayTime(DateTime date) => _displayTime.format(date);

  /// `21/09/2026 10:05:14`
  static String toFullDateTime(DateTime date) => _fullDateTime.format(date);

  /// `09/2026`  — useful for monthly reports.
  static String toMonthYear(DateTime date) => _monthYear.format(date);

  // ─── API Formatters ───────────────────────────────────────────────────────

  /// `2026-09-21` — for query parameters that accept a date string.
  static String toApiDate(DateTime date) => _apiDate.format(date);

  // ─── Parsers ──────────────────────────────────────────────────────────────

  /// Parse an ISO 8601 string from the API and convert to local time.
  ///
  /// Returns `null` if [isoString] is null, empty, or malformed.
  static DateTime? fromIso8601(String? isoString) {
    if (isoString == null || isoString.isEmpty) return null;
    try {
      return DateTime.parse(isoString).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ─── Relative Time ────────────────────────────────────────────────────────

  /// Human-friendly relative label shown in order history / activity feeds.
  ///
  /// Examples:
  /// - `'Vừa xong'`        (< 1 min ago)
  /// - `'5 phút trước'`    (< 1 hour ago)
  /// - `'2 giờ trước'`     (< 24 hours ago)
  /// - `'21/09/2026'`      (older)
  static String toRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    return toDisplayDate(date);
  }

  // ─── Shift Helpers ────────────────────────────────────────────────────────

  /// Returns a greeting string based on the current hour.
  static String getShiftGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }
}
