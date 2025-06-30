import 'dart:convert';

class ScheduleListModel {
  ScheduleListModel({
    required this.listName,
    required this.schedules,
  });

  factory ScheduleListModel.fromMap(Map<String, dynamic> map) {
    return ScheduleListModel(
      listName: map['list_name'] ?? '',
      schedules: List<Map<String, dynamic>>.from(map['schedules'] ?? []),
    );
  }

  factory ScheduleListModel.fromJson(String source) =>
      ScheduleListModel.fromMap(json.decode(source));

  final String listName;
  final List<Map<String, dynamic>> schedules;

  Map<String, dynamic> toMap() {
    return {
      'list_name': listName,
      'schedules': schedules,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ScheduleListModel(listName: $listName, schedules: $schedules)';
}
