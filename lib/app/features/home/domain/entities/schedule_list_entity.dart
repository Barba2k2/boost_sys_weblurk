import 'dart:convert';

class ScheduleListEntity {
  ScheduleListEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.schedules,
    required this.totalSchedules,
    required this.activeSchedules,
    required this.completedSchedules,
    required this.cancelledSchedules,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleListEntity.fromMap(Map<String, dynamic> map) {
    return ScheduleListEntity(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      schedules: List<Map<String, dynamic>>.from(map['schedules'] ?? []),
      totalSchedules: map['total_schedules']?.toInt() ?? 0,
      activeSchedules: map['active_schedules']?.toInt() ?? 0,
      completedSchedules: map['completed_schedules']?.toInt() ?? 0,
      cancelledSchedules: map['cancelled_schedules']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory ScheduleListEntity.fromJson(String source) =>
      ScheduleListEntity.fromMap(json.decode(source));

  final int id;
  final String name;
  final String description;
  final DateTime date;
  final List<Map<String, dynamic>> schedules;
  final int totalSchedules;
  final int activeSchedules;
  final int completedSchedules;
  final int cancelledSchedules;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'schedules': schedules,
      'total_schedules': totalSchedules,
      'active_schedules': activeSchedules,
      'completed_schedules': completedSchedules,
      'cancelled_schedules': cancelledSchedules,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  ScheduleListEntity copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? date,
    List<Map<String, dynamic>>? schedules,
    int? totalSchedules,
    int? activeSchedules,
    int? completedSchedules,
    int? cancelledSchedules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      schedules: schedules ?? this.schedules,
      totalSchedules: totalSchedules ?? this.totalSchedules,
      activeSchedules: activeSchedules ?? this.activeSchedules,
      completedSchedules: completedSchedules ?? this.completedSchedules,
      cancelledSchedules: cancelledSchedules ?? this.cancelledSchedules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
