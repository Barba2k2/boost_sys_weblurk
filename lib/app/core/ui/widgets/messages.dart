import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Messages {
  Messages._();

  // Mensagens de sucesso
  static void success(String message) {
    Asuka.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => Asuka.hideCurrentSnackBar(),
        ),
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
        backgroundColor: const Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: retryAction != null
            ? SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: () {
                  Asuka.hideCurrentSnackBar();
                  // Aqui você pode adicionar uma callback para retry
                },
              )
            : SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () => Asuka.hideCurrentSnackBar(),
              ),
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
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: retryAction != null
            ? SnackBarAction(
                label: 'Tentar Novamente',
                textColor: Colors.white,
                onPressed: () {
                  Asuka.hideCurrentSnackBar();
                  // Aqui você pode adicionar uma callback para retry
                },
              )
            : SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () => Asuka.hideCurrentSnackBar(),
              ),
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

  // Mensagens específicas para diferentes tipos de erro
  static void networkError() {
    error(
      'Falha na conexão com o servidor. Verifique sua internet e tente novamente.',
      retryAction: 'retry',
    );
  }

  static void authenticationError() {
    error(
      'Sessão expirada. Faça login novamente.',
      retryAction: 'login',
    );
  }

  static void serverError() {
    error(
      'Serviço temporariamente indisponível. Tente novamente em alguns minutos.',
      retryAction: 'retry',
    );
  }

  static void scheduleLoadError() {
    error(
      'Erro ao carregar agendamentos. Verifique sua conexão.',
      retryAction: 'retry',
    );
  }

  static void webViewError() {
    error(
      'Problema no navegador. Tente recarregar a página.',
      retryAction: 'retry',
    );
  }
}
