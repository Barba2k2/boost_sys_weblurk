import 'dart:convert';

class ScheduleModel {
  ScheduleModel({
    this.id,
    required this.streamerUrl,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id']?.toInt(),
      streamerUrl: map['streamer_url'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      startTime: map['start_time'] ?? '',
      endTime: map['end_time'] ?? '',
    );
  }

  factory ScheduleModel.fromJson(String source) =>
      ScheduleModel.fromMap(json.decode(source));

  final int? id;
  final String streamerUrl;
  final DateTime date;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'streamer_url': streamerUrl,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ScheduleModel(id: $id, streamerUrl: $streamerUrl, date: $date, startTime: $startTime, endTime: $endTime)';
}
