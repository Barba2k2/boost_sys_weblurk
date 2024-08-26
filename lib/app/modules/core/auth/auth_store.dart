import 'dart:convert';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../core/helpers/constants.dart';
import '../../../core/local_storage/local_storage.dart';
import '../../../core/logger/app_logger.dart';
import '../../../models/user_model.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  final LocalStorage _localStorage;
  final _logger = Modular.get<AppLogger>();

  @readonly
  UserModel? _userLogged;

  AuthStoreBase({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;

  @action
  Future<void> loadUserLogged() async {
    final userModelJson = await _localStorage.read<String>(
      Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
    );

    if (userModelJson != null) {
      _userLogged = UserModel.fromJson(json.decode(userModelJson));
      if (_userLogged?.id == null || _userLogged!.id == 0) {
        _logger.warning('Streamer ID is missing in the loaded user data.');
      }
    } else {
      _userLogged = UserModel.empty();
      await logout();
    }
  }

  @action
  Future<void> updateUserStatus(String status) async {
    if (_userLogged != null) {
      _userLogged = _userLogged!.copyWith(status: status);
      _logger.info('User logged: ${_userLogged!.toJson()}');
      await _localStorage.write(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        json.encode(_userLogged!.toJson()),
      );
    }
  }

  @action
  Future<void> logout() async {
    await _localStorage.clear();
    _userLogged = UserModel.empty();
    Modular.to.navigate('/auth/login/');
  }
}
