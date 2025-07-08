import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/logger/app_logger.dart';

class UniversalWebViewJavaScript {
  static Future<void> injectJavaScriptDialogs({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    try {
      await controller.runJavaScript(_getDisableDialogsJavaScript());
      logger?.info('Diálogos JavaScript desabilitados com sucesso');
    } catch (e) {
      logger?.error('Erro ao desabilitar diálogos JavaScript: $e');
    }
  }

  static Future<void> captureCurrentUrl({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    try {
      await controller.runJavaScript(
        'window.flutter_inappwebview.callHandler && window.flutter_inappwebview.callHandler(\'current_url\', window.location.href);'
      );
    } catch (e) {
      logger?.error('Erro ao capturar URL atual: $e');
    }
  }

  static String _getDisableDialogsJavaScript() {
    return '''
      window.alert = function(message) { 
        console.log("[Alert interceptado]: " + message);
        return true;
      };
      
      window.confirm = function(message) {
        console.log("[Confirm interceptado]: " + message);
        return true;
      };
      
      window.prompt = function(message, defaultValue) {
        console.log("[Prompt interceptado]: " + message);
        return defaultValue || "";
      };
      
      window.onbeforeunload = null;
      
      try {
        const originalOpen = window.open;
        window.open = function() {
          console.log("[window.open interceptado]");
          return null;
        };
      } catch(e) {
        console.error("Erro ao substituir window.open:", e);
      }
    ''';
  }
} 