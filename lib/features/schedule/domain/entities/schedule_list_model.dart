import 'dart:convert';

class ScheduleListModel {
  ScheduleListModel({
    required this.id,
    required this.name,
    required this.schedules,
  });

  final int id;
  final String name;
  final List<dynamic> schedules;

  factory ScheduleListModel.fromMap(Map<String, dynamic> map) {
    return ScheduleListModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      schedules: map['schedules'] ?? [],
    );
  }

  factory ScheduleListModel.fromJson(String source) =>
      ScheduleListModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'schedules': schedules,
    };
  }

  String toJson() => json.encode(toMap());
}
