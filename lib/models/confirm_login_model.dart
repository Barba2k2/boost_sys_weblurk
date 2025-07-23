import 'dart:convert';

class ConfirmLoginModel {
  ConfirmLoginModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory ConfirmLoginModel.fromMap(Map<String, dynamic> map) {
    return ConfirmLoginModel(
      accessToken: map['access_token'] ?? '',
      refreshToken: map['refresh_token'] ?? '',
    );
  }

  factory ConfirmLoginModel.fromJson(String source) =>
      ConfirmLoginModel.fromMap(json.decode(source));

  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toMap() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  String toJson() => toMap().toString();
}
