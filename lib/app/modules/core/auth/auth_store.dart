import 'dart:convert';

import 'package:mobx/mobx.dart';

import '../../../core/helpers/constants.dart';
import '../../../core/local_storage/local_storage.dart';
import '../../../models/user_model.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  final LocalStorage _localStorage;

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
    } else {
      _userLogged = UserModel.empty();
      // await logout();
    }
  }

  @action
  Future<void> logout() async {
    await _localStorage.clear();
    _userLogged = UserModel.empty();
  }
}