import 'package:flutter/material.dart';

class MessageStyles {
  MessageStyles._();

  // Cores das mensagens
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  // Durações padrão
  static const Duration defaultDuration = Duration(seconds: 4);
  static const Duration warningDuration = Duration(seconds: 5);
  static const Duration errorDuration = Duration(seconds: 6);

  // Comportamento padrão
  static const SnackBarBehavior defaultBehavior = SnackBarBehavior.floating;
} 