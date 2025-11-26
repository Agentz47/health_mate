import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat databaseFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');

  static String formatForDisplay(DateTime date) {
    return displayFormat.format(date);
  }

  static String formatForDatabase(DateTime date) {
    return databaseFormat.format(date);
  }

  static DateTime parseFromDatabase(String dateString) {
    return databaseFormat.parse(dateString);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
