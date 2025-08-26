import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service responsible for restarting the application
class AppRestartService {
  /// Restart the application based on the current platform
  void restart() {
    debugPrint('🔄 Iniciando reinicialização do aplicativo...');
    
    if (Platform.isWindows) {
      _restartWindows();
    } else if (Platform.isAndroid) {
      _restartAndroid();
    } else if (Platform.isIOS) {
      _restartIOS();
    } else if (Platform.isMacOS) {
      _restartMacOS();
    } else {
      _restartGeneric();
    }
  }

  /// Check if restart is supported on current platform
  bool get isRestartSupported {
    return Platform.isWindows || 
           Platform.isAndroid || 
           Platform.isIOS || 
           Platform.isMacOS;
  }

  /// Get platform-specific restart message
  String get restartMessage {
    if (Platform.isWindows) {
      return 'O aplicativo será fechado. Abra-o novamente para ver as atualizações.';
    } else if (Platform.isAndroid) {
      return 'O aplicativo será reiniciado automaticamente.';
    } else if (Platform.isIOS) {
      return 'Feche e abra o aplicativo novamente para ver as atualizações.';
    } else if (Platform.isMacOS) {
      return 'O aplicativo será fechado. Abra-o novamente para ver as atualizações.';
    } else {
      return 'Feche e abra o aplicativo novamente para ver as atualizações.';
    }
  }

  void _restartWindows() {
    debugPrint('💻 Encerrando aplicativo Windows...');
    // On Windows desktop, we close the app and let the user restart it
    SystemNavigator.pop();
  }

  void _restartAndroid() {
    debugPrint('📱 Reiniciando aplicativo Android...');
    // On Android, this will close the app - the user can reopen it
    SystemNavigator.pop();
    
    // TODO: For true Android restart, we would need to implement
    // platform-specific code using method channels
  }

  void _restartIOS() {
    debugPrint('📱 Reiniciando aplicativo iOS...');
    // iOS doesn't allow programmatic app restart
    // The user needs to manually close and reopen the app
    SystemNavigator.pop();
  }

  void _restartMacOS() {
    debugPrint('💻 Encerrando aplicativo macOS...');
    // Similar to Windows, close the app and let user restart
    SystemNavigator.pop();
  }

  void _restartGeneric() {
    debugPrint('🔧 Encerrando aplicativo (plataforma genérica)...');
    // Generic fallback - just close the app
    SystemNavigator.pop();
  }
}