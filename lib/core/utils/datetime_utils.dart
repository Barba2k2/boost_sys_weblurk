import '../services/timezone_service.dart';

/// Utility class for DateTime operations with timezone support
class DateTimeUtils {
  /// Convert a DateTime from the selected timezone to Brazil time
  static Future<DateTime> convertFromSelectedTimezoneToBrazil(
    DateTime dateTime,
    TimezoneService timezoneService,
  ) async {
    return await timezoneService.convertFromSelectedTimezoneToBrazil(dateTime);
  }

  /// Format time for display
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date for display
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Check if a time is within a schedule range
  static bool isTimeInRange(
    DateTime currentTime,
    String startTimeStr,
    String endTimeStr,
  ) {
    try {
      final startTime = _parseTimeString(startTimeStr, currentTime);
      final endTime = _parseTimeString(endTimeStr, currentTime);

      return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
    } catch (e) {
      return false;
    }
  }

  /// Parse time string to DateTime
  static DateTime _parseTimeString(String timeStr, DateTime baseDate) {
    final cleanTime = timeStr.replaceAll('Time(', '').replaceAll(')', '');

    if (cleanTime.isEmpty) {
      throw Exception('Time string is empty');
    }

    final timeParts = cleanTime.split(':');
    if (timeParts.length < 2) {
      throw Exception('Invalid time format');
    }

    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
      second,
    );
  }

  /// Get time difference in minutes
  static int getTimeDifferenceInMinutes(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  /// Check if current time is during a schedule
  /// This converts the schedule times from selected timezone to Brazil time before checking
  static Future<bool> isCurrentTimeInSchedule(
    String startTimeStr,
    String endTimeStr,
    TimezoneService timezoneService,
  ) async {
    try {
      // Convert schedule times from selected timezone to Brazil time
      final convertedTimes = await timezoneService.convertScheduleTimes(
        startTimeStr,
        endTimeStr,
      );

      // Use current time in Brazil (no conversion needed for comparison)
      final currentTime = DateTime.now();
      return isTimeInRange(
        currentTime,
        convertedTimes['startTime']!,
        convertedTimes['endTime']!,
      );
    } catch (e) {
      return false;
    }
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Get relative time string (e.g., "2 hours ago", "in 30 minutes")
  static String getRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      final pastDifference = now.difference(dateTime);

      if (pastDifference.inDays > 0) {
        return '${pastDifference.inDays} dias atrás';
      } else if (pastDifference.inHours > 0) {
        return '${pastDifference.inHours} horas atrás';
      } else if (pastDifference.inMinutes > 0) {
        return '${pastDifference.inMinutes} minutos atrás';
      } else {
        return 'Agora mesmo';
      }
    } else {
      if (difference.inDays > 0) {
        return 'Em ${difference.inDays} dias';
      } else if (difference.inHours > 0) {
        return 'Em ${difference.inHours} horas';
      } else if (difference.inMinutes > 0) {
        return 'Em ${difference.inMinutes} minutos';
      } else {
        return 'Agora';
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Get start of day
  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day
  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(
        dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }
}
