import 'dart:convert';

class ScheduleEntity {
  ScheduleEntity({
    required this.id,
    required this.nickname,
    required this.status,
    required this.date,
    required this.time,
    required this.duration,
    required this.title,
    required this.description,
    required this.category,
    required this.platform,
    required this.url,
    required this.thumbnail,
    required this.viewers,
    required this.followers,
    required this.subscribers,
    required this.donations,
    required this.score,
    required this.rank,
    required this.trend,
    required this.notes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleEntity.fromMap(Map<String, dynamic> map) {
    return ScheduleEntity(
      id: map['id']?.toInt() ?? 0,
      nickname: map['nickname'] ?? '',
      status: map['status'] ?? '',
      date: DateTime.parse(map['date']),
      time: map['time'] ?? '',
      duration: map['duration'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      platform: map['platform'] ?? '',
      url: map['url'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      viewers: map['viewers']?.toInt() ?? 0,
      followers: map['followers']?.toInt() ?? 0,
      subscribers: map['subscribers']?.toInt() ?? 0,
      donations: map['donations']?.toInt() ?? 0,
      score: map['score']?.toInt() ?? 0,
      rank: map['rank']?.toInt() ?? 0,
      trend: map['trend'] ?? '',
      notes: map['notes'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory ScheduleEntity.fromJson(String source) =>
      ScheduleEntity.fromMap(json.decode(source));

  final int id;
  final String nickname;
  final String status;
  final DateTime date;
  final String time;
  final String duration;
  final String title;
  final String description;
  final String category;
  final String platform;
  final String url;
  final String thumbnail;
  final int viewers;
  final int followers;
  final int subscribers;
  final int donations;
  final int score;
  final int rank;
  final String trend;
  final String notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'status': status,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'title': title,
      'description': description,
      'category': category,
      'platform': platform,
      'url': url,
      'thumbnail': thumbnail,
      'viewers': viewers,
      'followers': followers,
      'subscribers': subscribers,
      'donations': donations,
      'score': score,
      'rank': rank,
      'trend': trend,
      'notes': notes,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  ScheduleEntity copyWith({
    int? id,
    String? nickname,
    String? status,
    DateTime? date,
    String? time,
    String? duration,
    String? title,
    String? description,
    String? category,
    String? platform,
    String? url,
    String? thumbnail,
    int? viewers,
    int? followers,
    int? subscribers,
    int? donations,
    int? score,
    int? rank,
    String? trend,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      status: status ?? this.status,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      viewers: viewers ?? this.viewers,
      followers: followers ?? this.followers,
      subscribers: subscribers ?? this.subscribers,
      donations: donations ?? this.donations,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      trend: trend ?? this.trend,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
