// Messages barrel
export 'message_actions.dart';
export 'message_specifics.dart';
export 'message_styles.dart';
export 'message_types.dart';

// Classe principal para compatibilidade
import 'message_types.dart';
import 'message_specifics.dart';

class Messages {
  Messages._();

  // Delegate para MessageTypes
  static void success(String message) => MessageTypes.success(message);
  static void warning(String message, {String? retryAction}) => 
      MessageTypes.warning(message, retryAction: retryAction);
  static void error(String message, {String? retryAction}) => 
      MessageTypes.error(message, retryAction: retryAction);
  static void alert(String message) => MessageTypes.alert(message);
  static void info(String message) => MessageTypes.info(message);

  // Delegate para MessageSpecifics
  static void networkError() => MessageSpecifics.networkError();
  static void authenticationError() => MessageSpecifics.authenticationError();
  static void serverError() => MessageSpecifics.serverError();
  static void scheduleLoadError() => MessageSpecifics.scheduleLoadError();
  static void webViewError() => MessageSpecifics.webViewError();
} 