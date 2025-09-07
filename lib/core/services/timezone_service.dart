import 'dart:io';
import '../local_storage/local_storage.dart';
import '../logger/app_logger.dart';

/// Service for managing timezone settings and conversions
///
/// IMPORTANT: This service converts FROM the selected timezone TO Brazil time (GMT-3)
///
/// Example:
/// - User in Netherlands selects "GMT+1"
/// - When it's 20:00 in Netherlands (GMT+1), the system converts it to 16:00 Brazil time (GMT-3)
/// - This ensures that Brazilian schedules are shown correctly for international users
///
/// Conversion formula: BrazilTime = SelectedTime + (BrazilOffset - SelectedOffset)
/// Where BrazilOffset = -3 and SelectedOffset is the user's timezone offset
class TimezoneService {
  static const String _timezoneKey = 'selected_timezone';
  static const String _defaultTimezone = 'GMT-3';

  TimezoneService({
    required LocalStorage localStorage,
    required AppLogger logger,
  })  : _localStorage = localStorage,
        _logger = logger;

  final LocalStorage _localStorage;
  final AppLogger _logger;

  /// Available timezones for selection - Complete GMT list
  static const List<Map<String, String>> availableTimezones = [
    {'id': 'GMT-12', 'name': 'GMT-12', 'offset': '-12'},
    {'id': 'GMT-11', 'name': 'GMT-11', 'offset': '-11'},
    {'id': 'GMT-10', 'name': 'GMT-10', 'offset': '-10'},
    {'id': 'GMT-9', 'name': 'GMT-9', 'offset': '-9'},
    {'id': 'GMT-8', 'name': 'GMT-8', 'offset': '-8'},
    {'id': 'GMT-7', 'name': 'GMT-7', 'offset': '-7'},
    {'id': 'GMT-6', 'name': 'GMT-6', 'offset': '-6'},
    {'id': 'GMT-5', 'name': 'GMT-5', 'offset': '-5'},
    {'id': 'GMT-4', 'name': 'GMT-4', 'offset': '-4'},
    {'id': 'GMT-3', 'name': 'GMT-3', 'offset': '-3'},
    {'id': 'GMT-2', 'name': 'GMT-2', 'offset': '-2'},
    {'id': 'GMT-1', 'name': 'GMT-1', 'offset': '-1'},
    {'id': 'GMT+0', 'name': 'GMT+0 (UTC)', 'offset': '+0'},
    {'id': 'GMT+1', 'name': 'GMT+1', 'offset': '+1'},
    {'id': 'GMT+2', 'name': 'GMT+2', 'offset': '+2'},
    {'id': 'GMT+3', 'name': 'GMT+3', 'offset': '+3'},
    {'id': 'GMT+4', 'name': 'GMT+4', 'offset': '+4'},
    {'id': 'GMT+5', 'name': 'GMT+5', 'offset': '+5'},
    {'id': 'GMT+6', 'name': 'GMT+6', 'offset': '+6'},
    {'id': 'GMT+7', 'name': 'GMT+7', 'offset': '+7'},
    {'id': 'GMT+8', 'name': 'GMT+8', 'offset': '+8'},
    {'id': 'GMT+9', 'name': 'GMT+9', 'offset': '+9'},
    {'id': 'GMT+10', 'name': 'GMT+10', 'offset': '+10'},
    {'id': 'GMT+11', 'name': 'GMT+11', 'offset': '+11'},
    {'id': 'GMT+12', 'name': 'GMT+12', 'offset': '+12'},
  ];

  /// Get the currently selected timezone
  Future<String> getSelectedTimezone() async {
    try {
      final timezone = await _localStorage.read<String>(_timezoneKey);
      if (timezone != null) {
        return timezone;
      }

      // If no timezone is set, detect system timezone
      final systemTimezone = getSystemTimezone();
      return systemTimezone;
    } catch (e) {
      _logger.error('Erro ao obter fuso horário selecionado: $e');
      return _defaultTimezone;
    }
  }

  /// Set the selected timezone
  Future<void> setSelectedTimezone(String timezoneId) async {
    try {
      await _localStorage.write<String>(_timezoneKey, timezoneId);
    } catch (e) {
      _logger.error('Erro ao salvar fuso horário: $e');
      throw Exception('Erro ao salvar configuração de fuso horário');
    }
  }

  /// Get current time converted from selected timezone to Brazil time
  Future<DateTime> getCurrentTime() async {
    try {
      return await convertFromSelectedTimezoneToBrazil(DateTime.now());
    } catch (e) {
      _logger.error('Erro ao obter hora atual: $e');
      return DateTime.now();
    }
  }

  /// Convert a DateTime from the selected timezone to Brazil time (GMT-3)
  Future<DateTime> convertFromSelectedTimezoneToBrazil(
      DateTime dateTime) async {
    try {
      final selectedTimezone = await getSelectedTimezone();
      return _convertFromTimezoneToBrazil(dateTime, selectedTimezone);
    } catch (e) {
      _logger.error(
        'Erro ao converter data do fuso selecionado para horário do Brasil: $e',
      );
      return dateTime;
    }
  }

  /// Convert a DateTime from a specific timezone to Brazil time (GMT-3)
  DateTime _convertFromTimezoneToBrazil(
    DateTime dateTime,
    String selectedTimezoneId,
  ) {
    // Get the REAL timezone offset of the machine (not the selected one)
    final machineOffset = dateTime.timeZoneOffset.inHours;
    final brazilOffset = -3; // Brazil is GMT-3

    // To convert FROM machine timezone TO Brazil time:
    // We need to subtract the machine offset and add the Brazil offset
    final totalOffset = brazilOffset - machineOffset;

    final convertedTime = dateTime.add(Duration(hours: totalOffset));

    return convertedTime;
  }

  /// Get timezone name by ID
  String getTimezoneName(String timezoneId) {
    final timezone = availableTimezones.firstWhere(
      (tz) => tz['id'] == timezoneId,
      orElse: () => {'name': 'Desconhecido'},
    );
    return timezone['name'] ?? 'Desconhecido';
  }

  /// Format time for display with timezone
  String formatTimeWithTimezone(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get system timezone (platform-specific)
  String getSystemTimezone() {
    if (Platform.isWindows) {
      // On Windows, detect timezone from system timezone offset
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours;

      // Convert offset to GMT format
      if (offset == 0) return 'GMT+0';
      if (offset > 0) return 'GMT+$offset';
      return 'GMT$offset'; // offset is already negative
    } else {
      // For other platforms, detect from system
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours;

      if (offset == 0) return 'GMT+0';
      if (offset > 0) return 'GMT+$offset';
      return 'GMT$offset';
    }
  }

  /// Check if timezone supports daylight saving time
  bool hasDaylightSavingTime(String timezoneId) {
    // Check if the timezone is in a region that typically uses DST
    final dstTimezones = [
      // North America
      'GMT-10', // Hawaii (no DST, but included for completeness)
      'GMT-9', // Alaska (DST)
      'GMT-8', // Pacific Time (US/Canada) - DST
      'GMT-7', // Mountain Time (US/Canada) - DST
      'GMT-6', // Central Time (US/Canada) - DST
      'GMT-5', // Eastern Time (US/Canada) - DST
      'GMT-4', // Atlantic Time (Canada) - DST
      'GMT-3', // Newfoundland Time (Canada) - DST

      // South America
      'GMT-3', // Brazil (some regions), Argentina, Chile - DST
      'GMT-4', // Brazil (some regions), Bolivia - DST

      // Europe
      'GMT+0', // Western Europe (UK, Ireland, Portugal) - DST
      'GMT+1', // Central Europe (Germany, France, Italy, Spain) - DST
      'GMT+2', // Eastern Europe (Greece, Finland, Romania) - DST
      'GMT+3', // Moscow Time (Russia) - DST

      // Asia
      'GMT+3', // Middle East (Turkey, Israel) - DST
      'GMT+4', // Caucasus (Georgia, Armenia) - DST
      'GMT+5', // Central Asia (Kazakhstan) - DST
      'GMT+6', // Central Asia (Kyrgyzstan) - DST
      'GMT+7', // Southeast Asia (Mongolia) - DST
      'GMT+8', // East Asia (China, Taiwan) - DST
      'GMT+9', // Japan, South Korea - DST
      'GMT+10', // Australia (Eastern) - DST
      'GMT+11', // Australia (Central) - DST
      'GMT+12', // New Zealand - DST

      // Oceania
      'GMT+10', // Australia (Eastern) - DST
      'GMT+11', // Australia (Central) - DST
      'GMT+12', // New Zealand - DST
    ];

    return dstTimezones.contains(timezoneId);
  }

  /// Convert schedule time strings from machine timezone to Brazil time
  /// This is specifically for schedule start/end times
  Future<Map<String, String>> convertScheduleTimes(
    String startTimeStr,
    String endTimeStr,
  ) async {
    try {
      // Schedule times are already in Brazil time (GMT-3), so no conversion needed
      // Just return them as-is
      return {
        'startTime': startTimeStr,
        'endTime': endTimeStr,
      };
    } catch (e) {
      _logger.error('Erro ao converter horários do agendamento: $e');
      return {
        'startTime': startTimeStr,
        'endTime': endTimeStr,
      };
    }
  }
}
