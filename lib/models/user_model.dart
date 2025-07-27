import 'dart:convert';

import 'package:flutter/widgets.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.nickname,
    this.password,
    required this.role,
    required this.status,
  });

  UserModel.empty()
      : id = 0,
        nickname = '',
        password = '',
        role = '',
        status = 'OFF';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
      password: map['password'],
      role: map['role'] ?? '',
      status: map['status'] ?? 'OFF',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
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
      status: status ?? this.status,
    );
  }
}
