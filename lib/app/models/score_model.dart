import 'dart:convert';

import 'package:intl/intl.dart';

class ScoreModel {
  ScoreModel({
    required this.streamerId,
    required this.date,
    required this.hour,
    required this.minute,
    required this.points,
  });

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      streamerId: map['streamerId']?.toInt() ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      hour: map['hour']?.toInt() ?? 0,
      minute: map['minute']?.toInt() ?? 0,
      points: map['points']?.toInt() ?? 0,
    );
  }

  factory ScoreModel.fromJson(String source) => ScoreModel.fromMap(
        json.decode(source),
      );

  final int streamerId;
  final DateTime date;
  final int hour;
  final int minute;
  final int points;

  Map<String, dynamic> toMap() {
    return {
      'streamerId': streamerId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'hour': hour,
      'minute': minute,
      'points': points,
    };
  }

  String toJson() => json.encode(toMap());
}
