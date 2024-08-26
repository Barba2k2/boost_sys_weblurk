import 'dart:convert';

import 'package:flutter/widgets.dart';

class UserModel {
  final int id;
  final String nickname;
  final String? password;
  final String role;
  final String? streamerId;
  final String status;

  UserModel({
    required this.id,
    required this.nickname,
    this.password,
    required this.role,
    this.streamerId,
    required this.status,
  });

  UserModel.empty()
      : id = 0,
        nickname = '',
        password = '',
        role = '',
        streamerId = '',
        status = 'OFF';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'password': password,
      'role': role,
      'streamerId': streamerId,
      'status': status,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
      password: map['password'],
      role: map['role'] ?? '',
      streamerId: map['streamerId'] ?? '',
      status: map['status'] ?? 'OFF'
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }

  UserModel copyWith({
    int? id,
    String? nickname,
    ValueGetter<String?>? password,
    String? role,
    ValueGetter<String?>? streamerId,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      password: password != null ? password() : this.password,
      role: role ?? this.role,
      streamerId: streamerId != null ? streamerId() : this.streamerId,
      status: status ?? this.status,
    );
  }
}
