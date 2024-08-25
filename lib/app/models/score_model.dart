import 'dart:convert';


class ScoreModel {
  final int id;
  final int streamerId;
  final DateTime date;
  final int hour;
  final int points;
  
  ScoreModel({
    required this.id,
    required this.streamerId,
    required this.date,
    required this.hour,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'streamerId': streamerId,
      'date': date.millisecondsSinceEpoch,
      'hour': hour,
      'points': points,
    };
  }

  factory ScoreModel.fromMap(Map<String, dynamic> map) {
    return ScoreModel(
      id: map['id']?.toInt() ?? 0,
      streamerId: map['streamerId']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      hour: map['hour']?.toInt() ?? 0,
      points: map['points']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScoreModel.fromJson(String source) => ScoreModel.fromMap(json.decode(source));
}
