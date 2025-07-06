import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/logger/app_logger.dart';
import 'user_entity.dart';

class AuthStore extends ChangeNotifier {
  final LocalStorage _localStorage;
  final AppLogger _logger;

  UserEntity? _userLogged;
  bool _isLoading = false;

  AuthStore({
    required LocalStorage localStorage,
    required AppLogger logger,
  })  : _localStorage = localStorage,
        _logger = logger;

  UserEntity? get userLogged => _userLogged;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userLogged != null && _userLogged!.id != 0;

  Future<void> loadUserLogged() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userJson = await _localStorage.read<String>(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
      );

      if (userJson != null) {
        try {
          final userData = UserEntity.fromJson(userJson);
          _userLogged = userData;
          _logger.info('Usuário carregado: ${userData.nickname}');
        } catch (e) {
          _logger.error('Erro ao decodificar dados do usuário', e);
          _userLogged = null;
        }
      } else {
        _userLogged = null;
        _logger.info('Nenhum usuário encontrado no storage');
      }
    } catch (e, s) {
      _logger.error('Erro ao carregar usuário', e, s);
      _userLogged = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserLogged(UserEntity user) async {
    try {
      _userLogged = user;
      await _localStorage.write(
        Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY,
        user.toJson(),
      );
      _logger.info('Usuário salvo: ${user.nickname}');
      notifyListeners();
    } catch (e, s) {
      _logger.error('Erro ao salvar usuário', e, s);
    }
  }

  Future<void> clearUserLogged() async {
    try {
      _userLogged = null;
      await _localStorage.remove(Constants.LOCAL_SOTRAGE_USER_LOGGED_DATA_KEY);
      _logger.info('Usuário removido do storage');
      notifyListeners();
    } catch (e, s) {
      _logger.error('Erro ao remover usuário', e, s);
    }
  }

  Future<void> logout() async {
    await clearUserLogged();
  }
}
