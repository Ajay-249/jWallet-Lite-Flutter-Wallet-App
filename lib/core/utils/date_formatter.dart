import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime dateTime) {
    return DateFormat('d MMMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatShort(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0 && now.day == dateTime.day) {
      return 'Today, ${DateFormat('hh:mm a').format(dateTime)}';
    } else if (difference.inDays <= 1 && now.day - dateTime.day == 1) {
      return 'Yesterday, ${DateFormat('hh:mm a').format(dateTime)}';
    } else {
      return DateFormat('d MMM, hh:mm a').format(dateTime);
    }
  }

  static String formatDateHeader(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }
}
