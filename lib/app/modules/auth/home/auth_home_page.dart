import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../core/ui/extensions/size_screen_extension.dart';
import '../../core/auth/auth_store.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({
    required AuthStore authStore,
    super.key,
  }) : _authStore = authStore;

  final AuthStore _authStore;

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  @override
  void initState() {
    super.initState();
    // reaction<UserModel?>(
    //   (_) => widget._authStore.userLogged,
    //   (userLogged) {
    //     if (userLogged != null && userLogged.nickname.isNotEmpty) {
    //       Modular.to.navigate('/home/');
    //     } else {
    //       Modular.to.navigate('/auth/login/');
    //     }
    //   },
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    try {
      await widget._authStore.loadUserLogged();

      final userLogged = widget._authStore.userLogged;

      if (userLogged != null && userLogged.id != 0 && userLogged.nickname.isNotEmpty) {
        Modular.to.navigate('/home/');
      } else {
        Modular.to.navigate('/auth/login/');
      }
    } catch (e, s) {
      log('Erro ao verificar usuário: $e \n StackTarce: $s');
      await widget._authStore.logout();
      Modular.to.navigate('/auth/login/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            scale: 2,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: Image.asset(
              'assets/images/logo-cla-boost.png',
              width: 550.w,
              height: 550.h,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
