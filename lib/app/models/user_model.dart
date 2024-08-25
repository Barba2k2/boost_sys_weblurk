import 'dart:convert';

class UserModel {
  final int id;
  final String nickname;
  final String? password;
  final String role;
  final String? streamerId;

  UserModel({
    required this.id,
    required this.nickname,
    this.password,
    required this.role,
    this.streamerId,
  });

  UserModel.empty()
      : id = 0,
        nickname = '',
        password = '',
        role = '',
        streamerId = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'password': password,
      'role': role,
      'streamerId': streamerId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      nickname: map['nickname'] ?? '',
      password: map['password'],
      role: map['role'] ?? '',
      streamerId: map['streamerId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }
}
