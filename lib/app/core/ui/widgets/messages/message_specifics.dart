import 'message_types.dart';

class MessageSpecifics {
  MessageSpecifics._();

  // Mensagens específicas para diferentes tipos de erro
  static void networkError() {
    MessageTypes.error(
      'Falha na conexão com o servidor. Verifique sua internet e tente novamente.',
      retryAction: 'retry',
    );
  }

  static void authenticationError() {
    MessageTypes.error(
      'Sessão expirada. Faça login novamente.',
      retryAction: 'login',
    );
  }

  static void serverError() {
    MessageTypes.error(
      'Serviço temporariamente indisponível. Tente novamente em alguns minutos.',
      retryAction: 'retry',
    );
  }

  static void scheduleLoadError() {
    MessageTypes.error(
      'Erro ao carregar agendamentos. Verifique sua conexão.',
      retryAction: 'retry',
    );
  }

  static void webViewError() {
    MessageTypes.error(
      'Problema no navegador. Tente recarregar a página.',
      retryAction: 'retry',
    );
  }
} 