import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:boost_sys_weblurk/models/user_model.dart';

void main() {
  group(
    'UserModel',
    () {
      test(
        'should create a UserModel from a map',
        () {
          final map = {
            'id': 1,
            'nickname': 'testuser',
            'password': 'password123',
            'role': 'user',
            'status': 'ON'
          };

          final userModel = UserModel.fromMap(map);

          expect(userModel.id, 1);
          expect(userModel.nickname, 'testuser');
          expect(userModel.password, 'password123');
          expect(userModel.role, 'user');
          expect(userModel.status, 'ON');
        },
      );

      test(
        'should create an empty UserModel',
        () {
          final userModel = UserModel.empty();

          expect(userModel.id, 0);
          expect(userModel.nickname, '');
          expect(userModel.password, '');
          expect(userModel.role, '');
          expect(userModel.status, 'OFF');
        },
      );

      test(
        'should convert UserModel to a map',
        () {
          final userModel = UserModel(
            id: 1,
            nickname: 'testuser',
            password: 'password123',
            role: 'user',
            status: 'ON',
          );

          final map = userModel.toMap();

          expect(map['id'], 1);
          expect(map['nickname'], 'testuser');
          expect(map['password'], 'password123');
          expect(map['role'], 'user');
          expect(map['status'], 'ON');
        },
      );

      test(
        'should convert UserModel to json',
        () {
          final userModel = UserModel(
            id: 1,
            nickname: 'testuser',
            password: 'password123',
            role: 'user',
            status: 'ON',
          );

          final jsonString = userModel.toJson();
          final decodedJson = json.decode(jsonString);

          expect(decodedJson['id'], 1);
          expect(decodedJson['nickname'], 'testuser');
          expect(decodedJson['password'], 'password123');
          expect(decodedJson['role'], 'user');
          expect(decodedJson['status'], 'ON');
        },
      );

      test(
        'copyWith should update only specified fields',
        () {
          final userModel = UserModel(
            id: 1,
            nickname: 'testuser',
            password: 'password123',
            role: 'user',
            status: 'OFF',
          );

          final updatedModel = userModel.copyWith(
            status: 'ON',
          );

          expect(updatedModel.id, 1);
          expect(updatedModel.nickname, 'testuser');
          expect(updatedModel.password, 'password123');
          expect(updatedModel.role, 'user');
          expect(updatedModel.status, 'ON');
        },
      );
    },
  );
}
