import 'dart:developer';

import 'package:flutter/material.dart';

import '../ui/widgets/messages.dart';

class ErrorMessageService {
  ErrorMessageService._();
  static final ErrorMessageService instance = ErrorMessageService._();

  String extractUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Erro desconhecido. Tente novamente.';
    }

    final errorString = error.toString();

    if (errorString.contains('Failure')) {
      return _extractFailureMessage(errorString);
    }

    if (errorString.contains('login')) {
      return _extractLoginErrorMessage(errorString);
    }

    if (_isNetworkError(errorString)) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    if (_isAuthenticationError(errorString)) {
      return 'Sessão expirada. Faça login novamente.';
    }

    if (_isServerError(errorString)) {
      return 'Serviço temporariamente indisponível. Tente novamente em alguns minutos.';
    }

    if (_isValidationError(errorString)) {
      return 'Dados inválidos. Verifique as informações e tente novamente.';
    }

    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  String _extractFailureMessage(String errorString) {
    final failureMatch =
        RegExp(r"Failure\(message: '([^']*)'\)").firstMatch(errorString);
    if (failureMatch != null) {
      final message = failureMatch.group(1);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final failureMatch2 =
        RegExp(r'Failure\(message: "([^"]*)"\)').firstMatch(errorString);
    if (failureMatch2 != null) {
      final message = failureMatch2.group(1);
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    final failureMatch3 =
        RegExp(r'Failure\(message: ([^)]+)\)').firstMatch(errorString);
    if (failureMatch3 != null) {
      final message = failureMatch3.group(1);
      if (message != null && message.isNotEmpty) {
        return message.replaceAll("'", '').replaceAll('"', '').trim();
      }
    }

    return 'Erro interno do sistema. Tente novamente.';
  }

  String _extractLoginErrorMessage(String errorString) {
    if (errorString.contains('User not exists') ||
        errorString.contains('User not found') ||
        errorString.contains('Usuario não encontrado')) {
      return 'Usuário não encontrado. Verifique suas credenciais.';
    }

    if (errorString.contains('Invalid password')) {
      return 'Senha incorreta. Verifique e tente novamente.';
    }

    if (errorString.contains('Token de acesso não encontrado')) {
      return 'Erro na resposta do servidor. Tente novamente.';
    }

    if (errorString.contains('confirmar login')) {
      return 'Erro ao confirmar login. Tente novamente.';
    }

    return 'Erro ao realizar login. Tente novamente.';
  }

  bool _isNetworkError(String errorString) {
    return errorString.contains('Connection failed') ||
        errorString.contains('Operation not permitted') ||
        errorString.contains('SocketException') ||
        errorString.contains('NetworkException') ||
        errorString.contains('TimeoutException') ||
        errorString.contains('No internet connection');
  }

  bool _isAuthenticationError(String errorString) {
    return errorString.contains('401') ||
        errorString.contains('Unauthorized') ||
        errorString.contains('Token expired') ||
        errorString.contains('Invalid token') ||
        errorString.contains('Sessão expirada');
  }

  bool _isServerError(String errorString) {
    log('errorString: $errorString');
    return errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504') ||
        errorString.contains('Internal Server Error') ||
        errorString.contains('Erro interno do sistema') ||
        errorString.contains('Bad Gateway') ||
        errorString.contains('Service Unavailable');
  }

  bool _isValidationError(String errorString) {
    return errorString.contains('400') ||
        errorString.contains('Bad Request') ||
        errorString.contains('Validation failed') ||
        errorString.contains('Invalid input') ||
        errorString.contains('Required field');
  }

  void showError(dynamic error, {String? retryAction}) {
    final message = extractUserFriendlyMessage(error);
    Messages.error(message, retryAction: retryAction);
  }

  void showLoginError(dynamic error) {
    final message = extractUserFriendlyMessage(error);
    Messages.error(message, retryAction: 'retry');
  }

  void showNetworkError() {
    Messages.networkError();
  }

  void showAuthenticationError() {
    Messages.authenticationError();
  }

  void showServerError() {
    Messages.serverError();
  }

  void showScheduleError() {
    Messages.scheduleLoadError();
  }

  void showWebViewError() {
    Messages.webViewError();
  }

  void showWarning(String message, {String? retryAction}) {
    Messages.warning(message, retryAction: retryAction);
  }

  void showSuccess(String message) {
    Messages.success(message);
  }

  void showInfo(String message) {
    Messages.info(message);
  }

  void logError(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  void handleError(dynamic error,
      [StackTrace? stackTrace, String? retryAction]) {
    logError(error, stackTrace);

    showError(error, retryAction: retryAction);
  }

  void handleLoginError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showLoginError(error);
  }

  void handleNetworkError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showNetworkError();
  }

  void handleAuthenticationError(dynamic error, [StackTrace? stackTrace]) {
    logError(error, stackTrace);
    showAuthenticationError();
  }
}
