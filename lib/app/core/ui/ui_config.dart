import 'package:flutter/material.dart';

class UiConfig {
  UiConfig._();

  static String title = 'Painel de Agendamento';

  static ThemeData get theme => ThemeData(
        useMaterial3: false,
        primaryColor: Colors.purple.shade900,
        primaryColorDark: Colors.purple,
        primaryColorLight: Colors.purple.shade400,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          centerTitle: true,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.purple,
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purple,
        ),
      );
}
