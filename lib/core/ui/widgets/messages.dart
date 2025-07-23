import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

class Messages {
  Messages._();

  // Contexto global para SnackBar
  static BuildContext? _globalContext;

  // Método para configurar o contexto global
  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  // Método para obter o contexto global
  static BuildContext? get _context => _globalContext;

  // Mensagens de sucesso
  static void success(String message) {
    final context = _context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: AppColors.cardHeaderText),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Mensagens de aviso com sugestão de retry
  static void warning(String message, {String? retryAction}) {
    final context = _context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: AppColors.cardHeaderText),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: retryAction != null
              ? SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: AppColors.cardHeaderText,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // Aqui você pode adicionar uma callback para retry
                  },
                )
              : SnackBarAction(
                  label: 'OK',
                  textColor: AppColors.cardHeaderText,
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
        ),
      );
    }
  }

  // Mensagens de erro específicas
  static void error(String message, {String? retryAction}) {
    final context = _context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(color: AppColors.cardHeaderText),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          action: retryAction != null
              ? SnackBarAction(
                  label: 'Tentar Novamente',
                  textColor: AppColors.cardHeaderText,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // Aqui você pode adicionar uma callback para retry
                  },
                )
              : SnackBarAction(
                  label: 'OK',
                  textColor: AppColors.cardHeaderText,
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                ),
        ),
      );
    }
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
