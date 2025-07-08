import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'message_styles.dart';
import 'message_actions.dart';

class MessageTypes {
  MessageTypes._();

  // Mensagens de sucesso
  static void success(String message) {
    Asuka.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: MessageStyles.successColor,
        behavior: SnackBarBehavior.floating,
        action: MessageActions.okAction(),
      ),
    );
  }

  // Mensagens de aviso com sugestão de retry
  static void warning(String message, {String? retryAction}) {
    Asuka.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: MessageStyles.warningColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: retryAction != null
            ? MessageActions.retryAction()
            : MessageActions.okAction(),
      ),
    );
  }

  // Mensagens de erro específicas
  static void error(String message, {String? retryAction}) {
    Asuka.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: MessageStyles.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: retryAction != null
            ? MessageActions.retryAction()
            : MessageActions.okAction(),
      ),
    );
  }

  // Métodos de compatibilidade (mantidos para não quebrar código existente)
  static void alert(String message) {
    warning(message);
  }

  static void info(String message) {
    success(message);
  }
} 