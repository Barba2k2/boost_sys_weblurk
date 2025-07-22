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
  AuthStoreBase({
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;

  final LocalStorage _localStorage;
  final _logger = Modular.get<AppLogger>();

  static bool _hasInitialized = false;

  @readonly
  UserModel? _userLogged;

  @action
  Future<void> loadUserLogged() async {
    try {
      // Garante que o logout seja feito apenas na primeira inicialização
      if (!_hasInitialized) {
        _hasInitialized = true;
        await logout();
        return;
      }

      final userModelJson = await _localStorage.read<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
      );

      if (userModelJson != null) {
        final token = await _localStorage.read<String>(
          Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
        );

        if (token != null && token.isNotEmpty) {
          _userLogged = UserModel.fromJson(json.decode(userModelJson));
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e, s) {
      _logger.error('Erro ao carregar dados do usuário', e, s);
      await logout();
    }
  }

  @action
  Future<void> updateUserStatus(String status) async {
    if (_userLogged != null) {
      _userLogged = _userLogged!.copyWith(status: status);
      await _localStorage.write(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        json.encode(_userLogged!.toJson()),
      );
    }
  }

  @action
  Future<void> logout() async {
    try {
      await _localStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
      await _localStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY);
      await _localStorage.remove(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY,
      );
      _userLogged = null;
    } catch (e, s) {
      _logger.error('Erro ao realizar logout', e, s);
    }
  }
}
