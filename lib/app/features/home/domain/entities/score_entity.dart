import 'dart:convert';

class ScoreEntity {
  ScoreEntity({
    required this.id,
    required this.nickname,
    required this.platform,
    required this.viewers,
    required this.followers,
    required this.subscribers,
    required this.donations,
    required this.score,
    required this.rank,
    required this.trend,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScoreEntity.fromMap(Map<String, dynamic> map) {
    return ScoreEntity(
      id: map['id']?.toInt() ?? 0,
      nickname: map['nickname'] ?? '',
      platform: map['platform'] ?? '',
      viewers: map['viewers']?.toInt() ?? 0,
      followers: map['followers']?.toInt() ?? 0,
      subscribers: map['subscribers']?.toInt() ?? 0,
      donations: map['donations']?.toInt() ?? 0,
      score: map['score']?.toInt() ?? 0,
      rank: map['rank']?.toInt() ?? 0,
      trend: map['trend'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  factory ScoreEntity.fromJson(String source) =>
      ScoreEntity.fromMap(json.decode(source));

  final int id;
  final String nickname;
  final String platform;
  final int viewers;
  final int followers;
  final int subscribers;
  final int donations;
  final int score;
  final int rank;
  final String trend;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'platform': platform,
      'viewers': viewers,
      'followers': followers,
      'subscribers': subscribers,
      'donations': donations,
      'score': score,
      'rank': rank,
      'trend': trend,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  ScoreEntity copyWith({
    int? id,
    String? nickname,
    String? platform,
    int? viewers,
    int? followers,
    int? subscribers,
    int? donations,
    int? score,
    int? rank,
    String? trend,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScoreEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      platform: platform ?? this.platform,
      viewers: viewers ?? this.viewers,
      followers: followers ?? this.followers,
      subscribers: subscribers ?? this.subscribers,
      donations: donations ?? this.donations,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      trend: trend ?? this.trend,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
