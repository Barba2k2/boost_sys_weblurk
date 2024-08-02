// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthStoreBase, Store {
  late final _$_userLoggedAtom =
      Atom(name: 'AuthStoreBase._userLogged', context: context);

  UserModel? get userLogged {
    _$_userLoggedAtom.reportRead();
    return super._userLogged;
  }

  @override
  UserModel? get _userLogged => userLogged;

  @override
  set _userLogged(UserModel? value) {
    _$_userLoggedAtom.reportWrite(value, super._userLogged, () {
      super._userLogged = value;
    });
  }

  late final _$loadUserLoggedAsyncAction =
      AsyncAction('AuthStoreBase.loadUserLogged', context: context);

  @override
  Future<void> loadUserLogged() {
    return _$loadUserLoggedAsyncAction.run(() => super.loadUserLogged());
  }

  late final _$logoutAsyncAction =
      AsyncAction('AuthStoreBase.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
