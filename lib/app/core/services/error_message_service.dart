import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorMessageService {
  ErrorMessageService._();
  static final ErrorMessageService instance = ErrorMessageService._();

  /// Extrai uma mensagem amigável ao usuário de qualquer tipo de erro
  String extractUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Erro desconhecido. Tente novamente.';
    }

    final errorString = error.toString();

    // Tratar erros de Failure
    if (errorString.contains('Failure')) {
      return _extractFailureMessage(errorString);
    }

    // Tratar erros específicos de login
    if (errorString.contains('login')) {
      return _extractLoginErrorMessage(errorString);
    }

    // Tratar erros de rede/conexão
    if (_isNetworkError(errorString)) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    // Tratar erros de autenticação
    if (_isAuthenticationError(errorString)) {
      return 'Sessão expirada. Faça login novamente.';
    }

    // Tratar erros de servidor
    if (_isServerError(errorString)) {
      return 'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
    }

    // Tratar erros de validação
    if (_isValidationError(errorString)) {
      return 'Dados inválidos. Verifique as informações e tente novamente.';
    }

    // Erro genérico
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  /// Extrai mensagem específica de um Failure
  String _extractFailureMessage(String errorString) {
    // Padrão: Failure(message: 'mensagem')
    final failureMatch =
        RegExp(r"Failure\(message: '([^']*)'\)").firstMatch(errorString);
    if (failureMatch != null) {
      final message = failureMatch.group(1);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    // Padrão: Failure(message: "mensagem")
    final failureMatch2 =
        RegExp(r'Failure\(message: "([^"]*)"\)').firstMatch(errorString);
    if (failureMatch2 != null) {
      final message = failureMatch2.group(1);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    // Padrão mais genérico: Failure(message: qualquer coisa)
    final failureMatch3 =
        RegExp(r'Failure\(message: ([^)]+)\)').firstMatch(errorString);
    if (failureMatch3 != null) {
      final message = failureMatch3.group(1);
      if (message != null && message.isNotEmpty) {
        // Remove aspas se existirem
        return message.replaceAll("'", '').replaceAll('"', '').trim();
      }
    }

    // Se não conseguir extrair, retorna mensagem genérica
    return 'Erro interno do sistema. Tente novamente.';
  }

  /// Extrai mensagem específica de erro de login
  String _extractLoginErrorMessage(String errorString) {
    if (errorString.contains('User not exists') ||
        errorString.contains('User not found') ||
        errorString.contains('Usuario não encontrado')) {
      return 'Usuário não encontrado. Verifique suas credenciais.';
    }

    if (errorString.contains('Token de acesso não encontrado')) {
      return 'Erro na resposta do servidor. Tente novamente.';
    }

    if (errorString.contains('confirmar login')) {
      return 'Erro ao confirmar login. Tente novamente.';
    }

    return 'Erro ao realizar login. Tente novamente.';
  }

  /// Verifica se é um erro de rede
  bool _isNetworkError(String errorString) {
    return errorString.contains('Connection failed') ||
        errorString.contains('Operation not permitted') ||
        errorString.contains('SocketException') ||
        errorString.contains('NetworkException') ||
        errorString.contains('TimeoutException') ||
        errorString.contains('No internet connection');
  }

  /// Verifica se é um erro de autenticação
  bool _isAuthenticationError(String errorString) {
    return errorString.contains('401') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('Token expired') ||
        errorString.contains('Invalid token') ||
        errorString.contains('Sessão expirada');
  }

  /// Verifica se é um erro de servidor
  bool _isServerError(String errorString) {
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('Internal Server Error') ||
        errorString.contains('Bad Gateway') ||
        errorString.contains('Service Unavailable');
  }

  /// Verifica se é um erro de validação
  bool _isValidationError(String errorString) {
    return errorString.contains('400') ||
        errorString.contains('Bad Request') ||
        errorString.contains('Validation failed') ||
        errorString.contains('Invalid input') ||
        errorString.contains('Required field');
  }

  /// Exibe uma mensagem de erro usando o sistema de mensagens
  void showError(dynamic error, {String? retryAction}) {
    final message = extractUserFriendlyMessage(error);
    Messages.error(message, retryAction: retryAction);
  }

  /// Exibe uma mensagem de erro específica para login
  void showLoginError(dynamic error) {
    final message = extractUserFriendlyMessage(error);
    Messages.error(message, retryAction: 'retry');
  }

  /// Exibe uma mensagem de erro de rede
  void showNetworkError() {
    Messages.networkError();
  }

  /// Exibe uma mensagem de erro de autenticação
  void showAuthenticationError() {
    Messages.authenticationError();
  }

  /// Exibe uma mensagem de erro de servidor
  void showServerError() {
    Messages.serverError();
  }

  /// Exibe uma mensagem de erro de agendamento
  void showScheduleError() {
    Messages.scheduleLoadError();
  }

  /// Exibe uma mensagem de erro de WebView
  void showWebViewError() {
    Messages.webViewError();
  }

  /// Exibe uma mensagem de aviso
  void showWarning(String message, {String? retryAction}) {
    Messages.warning(message, retryAction: retryAction);
  }

  /// Exibe uma mensagem de sucesso
  void showSuccess(String message) {
    Messages.success(message);
  }

  /// Exibe uma mensagem de informação
  void showInfo(String message) {
    Messages.info(message);
  }

  /// Loga o erro para debug (mantém o erro original para logs)
  void logError(dynamic error, [StackTrace? stackTrace]) {
    // Aqui você pode adicionar logging para debug
    // Por exemplo, usando um logger como Firebase Crashlytics
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Trata um erro completo: extrai mensagem, exibe para usuário e loga para debug
  void handleError(dynamic error,
      [StackTrace? stackTrace, String? retryAction]) {
    // Loga o erro original para debug
    logError(error, stackTrace);

    // Exibe mensagem amigável para o usuário
    showError(error, retryAction: retryAction);
  }

  /// Trata erro de login especificamente
  void handleLoginError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showLoginError(error);
  }

  /// Trata erro de rede especificamente
  void handleNetworkError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showNetworkError();
  }

  /// Trata erro de autenticação especificamente
  void handleAuthenticationError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showAuthenticationError();
  }
}
