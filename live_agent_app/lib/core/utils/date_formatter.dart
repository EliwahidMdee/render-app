import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats DateTime to local timezone before displaying
  static DateTime _toLocal(DateTime dateTime) {
    // If the DateTime is in UTC, convert to local
    if (dateTime.isUtc) {
      return dateTime.toLocal();
    }
    return dateTime;
  }

  static String formatDateTime(DateTime dateTime) {
    final localTime = _toLocal(dateTime);
    return DateFormat('MMM dd, yyyy hh:mm a').format(localTime);
  }

  static String formatDate(DateTime dateTime) {
    final localTime = _toLocal(dateTime);
    return DateFormat('MMM dd, yyyy').format(localTime);
  }

  static String formatTime(DateTime dateTime) {
    final localTime = _toLocal(dateTime);
    return DateFormat('hh:mm a').format(localTime);
  }

  static String formatRelative(DateTime dateTime) {
    final localTime = _toLocal(dateTime);
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inDays > 7) {
      return formatDate(localTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
