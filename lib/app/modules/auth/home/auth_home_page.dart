import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../core/ui/extensions/size_screen_extension.dart';
import '../../../models/user_model.dart';
import '../../core/auth/auth_store.dart';

class AuthHomePage extends StatefulWidget {
  final AuthStore _authStore;

  const AuthHomePage({
    required AuthStore authSotre,
    super.key,
  }) : _authStore = authSotre;

  @override
  State<AuthHomePage> createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  @override
  void initState() {
    super.initState();
    reaction<UserModel?>(
      (_) => widget._authStore.userLogged,
      (userLogged) {
        if (userLogged != null && userLogged.nickname.isNotEmpty) {
          Modular.to.navigate('/auth/login/');
          // Modular.to.navigate('/home/');
        } else {
          Modular.to.navigate('/auth/login/');
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget._authStore.loadUserLogged();
    });
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
