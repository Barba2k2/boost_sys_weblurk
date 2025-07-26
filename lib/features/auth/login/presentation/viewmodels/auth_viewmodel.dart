import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../../../core/helpers/constants.dart';
import '../../../../../core/local_storage/local_storage.dart';
import '../../../../../core/logger/app_logger.dart';
import '../../../../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required LocalStorage localStorage,
    required AppLogger logger,
  })  : _localStorage = localStorage,
        _logger = logger {
    _loadUserLogged();
  }

  final LocalStorage _localStorage;
  final AppLogger _logger;

  static bool _hasInitialized = false;

  UserModel? _userLogged;
  UserModel? get userLogged => _userLogged;

  Future<void> _loadUserLogged() async {
    try {
      // Garante que o logout seja feito apenas na primeira inicialização
      if (!_hasInitialized) {
        _hasInitialized = true;
        await logout();
        return;
      }

      _logger.info('Carregando dados do usuário...');

      final userModelJson = await _localStorage.read<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
      );

      if (userModelJson != null) {
        final token = await _localStorage.read<String>(
          Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY,
        );

        if (token != null && token.isNotEmpty) {
          _userLogged = UserModel.fromJson(
            json.decode(userModelJson),
          );
          notifyListeners();
        } else {
          _logger.warning('Token não encontrado');
          await logout();
        }
      } else {
        _logger.info('Nenhum usuário encontrado no storage');
        await logout();
      }
    } catch (e, s) {
      _logger.error('Erro ao carregar dados do usuário', e, s);
      await logout();
    }
  }

  Future<void> updateUserStatus(String status) async {
    if (_userLogged != null) {
      _userLogged = _userLogged!.copyWith(status: status);
      await _localStorage.write(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        json.encode(_userLogged!.toJson()),
      );
      notifyListeners();
    }
  }

  Future<void> reloadUserData() async {
    await _loadUserLogged();
  }

  Future<void> logout() async {
    try {
      await _localStorage.remove(Constants.LOCAL_STORAGE_ACCESS_TOKEN_KEY);
      await _localStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY);
      await _localStorage.remove(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_STATUS_KEY,
      );
      _userLogged = null;
      notifyListeners();
    } catch (e, s) {
      _logger.error('Erro ao realizar logout', e, s);
    }
  }
}
