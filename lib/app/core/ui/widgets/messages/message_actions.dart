import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';

class MessageActions {
  MessageActions._();

  // Ação OK padrão
  static SnackBarAction okAction() {
    return SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: () => Asuka.hideCurrentSnackBar(),
    );
  }

  // Ação de tentar novamente
  static SnackBarAction retryAction() {
    return SnackBarAction(
      label: 'Tentar Novamente',
      textColor: Colors.white,
      onPressed: () {
        Asuka.hideCurrentSnackBar();
        // Aqui você pode adicionar uma callback para retry
      },
    );
  }

  // Ação de login
  static SnackBarAction loginAction() {
    return SnackBarAction(
      label: 'Fazer Login',
      textColor: Colors.white,
      onPressed: () {
        Asuka.hideCurrentSnackBar();
        // Aqui você pode adicionar uma callback para login
      },
    );
  }
} 