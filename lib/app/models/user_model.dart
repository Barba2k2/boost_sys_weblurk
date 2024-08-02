import 'dart:convert';

class UserModel {
  final int id;
  final String nickname;
  final String? password;
  final String role;

  UserModel({
    required this.id,
    required this.nickname,
    this.password,
    required this.role,
  });

  UserModel.empty()
      : id = 0,
        nickname = '',
        password = '',
        role = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'password': password,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
      password: map['password'],
      role: map['role'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }
}
