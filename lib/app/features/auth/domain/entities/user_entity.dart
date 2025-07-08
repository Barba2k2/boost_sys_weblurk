import 'dart:convert';

import 'package:flutter/widgets.dart';

class UserEntity {
  UserEntity({
    required this.id,
    required this.nickname,
    required this.username,
    this.password,
    required this.role,
    required this.status,
  });

  UserEntity.empty()
      : id = 0,
        nickname = '',
        username = '',
        password = '',
        role = '',
        status = 'OFF';

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
      username: map['username'] ?? map['nickname'] ?? '',
      password: map['password'],
      role: map['role'] ?? '',
      status: map['status'] ?? 'OFF',
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> map) {
    return UserEntity.fromMap(map);
  }

  final int id;
  final String nickname;
  final String username;
  final String? password;
  final String role;
  final String status;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'username': username,
      'password': password,
      'role': role,
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());

  UserEntity copyWith({
    int? id,
    String? nickname,
    String? username,
    ValueGetter<String?>? password,
    String? role,
    ValueGetter<String?>? streamerId,
    String? status,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      password: password != null ? password() : this.password,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
