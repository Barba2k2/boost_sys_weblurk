import 'dart:convert';
import 'schedule_model.dart';

class ScheduleListModel {
  ScheduleListModel({
    required this.listName,
    required this.schedules,
  });

  factory ScheduleListModel.fromMap(Map<String, dynamic> map) {
    return ScheduleListModel(
      listName: map['list_name'] ?? '',
      schedules: List<ScheduleModel>.from(
        (map['schedules'] ?? []).map((x) => ScheduleModel.fromMap(x)),
      ),
    );
  }

  factory ScheduleListModel.fromJson(String source) =>
      ScheduleListModel.fromMap(json.decode(source));

  final String listName;
  final List<ScheduleModel> schedules;

  Map<String, dynamic> toMap() {
    return {
      'list_name': listName,
      'schedules': schedules.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ScheduleListModel(listName: $listName, schedules: $schedules)';
}
