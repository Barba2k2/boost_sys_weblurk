// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_streamer_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$RegisterStreamerController on RegisterStreamerControllerBase, Store {
  late final _$usersAtom =
      Atom(name: 'RegisterStreamerControllerBase.users', context: context);

  @override
  List<UserModel>? get users {
    _$usersAtom.reportRead();
    return super.users;
  }

  @override
  set users(List<UserModel>? value) {
    _$usersAtom.reportWrite(value, super.users, () {
      super.users = value;
    });
  }

  late final _$errorMessageAtom = Atom(
      name: 'RegisterStreamerControllerBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'RegisterStreamerControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$fetchUsersAsyncAction = AsyncAction(
      'RegisterStreamerControllerBase.fetchUsers',
      context: context);

  @override
  Future<void> fetchUsers() {
    return _$fetchUsersAsyncAction.run(() => super.fetchUsers());
  }

  late final _$registerUserAsyncAction = AsyncAction(
      'RegisterStreamerControllerBase.registerUser',
      context: context);

  @override
  Future<void> registerUser(String nickname, String password, String role) {
    return _$registerUserAsyncAction
        .run(() => super.registerUser(nickname, password, role));
  }

  late final _$deleteUserAsyncAction = AsyncAction(
      'RegisterStreamerControllerBase.deleteUser',
      context: context);

  @override
  Future<void> deleteUser(int id) {
    return _$deleteUserAsyncAction.run(() => super.deleteUser(id));
  }

  late final _$editUserAsyncAction =
      AsyncAction('RegisterStreamerControllerBase.editUser', context: context);

  @override
  Future<void> editUser(int id, String nickname, String password, String role) {
    return _$editUserAsyncAction
        .run(() => super.editUser(id, nickname, password, role));
  }

  @override
  String toString() {
    return '''
users: ${users},
errorMessage: ${errorMessage},
isLoading: ${isLoading}
    ''';
  }
}
