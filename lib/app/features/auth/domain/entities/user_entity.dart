import 'dart:convert';

import 'package:flutter/widgets.dart';

class UserEntity {
  UserEntity({
    required this.id,
    required this.nickname,
    this.password,
    required this.role,
    required this.status,
  });

  UserEntity.empty()
      : id = 0,
        nickname = '',
        password = '',
        role = '',
        status = 'OFF';

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
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
  final String? password;
  final String role;
  final String status;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'password': password,
      'role': role,
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());

  UserEntity copyWith({
    int? id,
    String? nickname,
    ValueGetter<String?>? password,
    String? role,
    ValueGetter<String?>? streamerId,
    String? status,
  }) {
    return UserEntity(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      password: password != null ? password() : this.password,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
