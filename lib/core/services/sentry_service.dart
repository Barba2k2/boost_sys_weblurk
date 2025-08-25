import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static const String _dsn = 
      'https://580a020e1bae72626f33e68ae69ea9be@o4509748376371200.ingest.us.sentry.io/4509748377747456';

  static Future<void> init({required Future<void> Function() appRunner}) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        
        // Configurações básicas
        options.environment = kDebugMode ? 'development' : 'production';
        
        // Configurações de produção vs desenvolvimento
        if (kDebugMode) {
          // Desenvolvimento: captura mais dados para debug
          options.debug = true;
          options.tracesSampleRate = 1.0;
          options.replay.sessionSampleRate = 0.1;
          options.replay.onErrorSampleRate = 1.0;
          options.sendDefaultPii = true;
        } else {
          // Produção: configurações otimizadas
          options.debug = false;
          options.tracesSampleRate = 0.1; // 10% das transações
          options.replay.sessionSampleRate = 0.01; // 1% das sessões
          options.replay.onErrorSampleRate = 0.1; // 10% dos erros
          options.sendDefaultPii = false; // Não enviar PII em produção
        }
        
        // Configurações de filtros
        options.beforeSend = (event, hint) {
          // Filtrar erros conhecidos ou irrelevantes
          if (event.exceptions?.any((exception) => 
              exception.type?.contains('NetworkException') == true ||
              exception.type?.contains('SocketException') == true
          ) == true) {
            // Log local mas não enviar para Sentry em produção
            if (kDebugMode) {
              debugPrint('Sentry: Erro de rede filtrado - ${event.exceptions}');
            }
            return null; // Não enviar
          }
          return event;
        };
        
        // Configurações específicas para Flutter Desktop
        options.attachStacktrace = true;
        options.enableAutoSessionTracking = true;
        options.autoSessionTrackingInterval = const Duration(seconds: 30);
        
        // Configurar upload de símbolos para produção
        if (!kDebugMode) {
          options.considerInAppFramesByDefault = false;
          options.addInAppInclude('boost_sys_weblurk');
        }
      },
      appRunner: appRunner,
    );
    
    // Configurar contexto após inicialização
    await _configureContext();
  }

  static Future<void> _configureContext() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      Sentry.configureScope((scope) {
        scope.setTag('platform', 'windows');
        scope.setTag('app_type', 'desktop');
        scope.setTag('app_name', packageInfo.appName);
        scope.setTag('app_version', packageInfo.version);
        scope.setTag('build_number', packageInfo.buildNumber);
      });
    } catch (e) {
      debugPrint('Erro ao configurar contexto Sentry: $e');
    }
  }

  static void captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
    Map<String, dynamic>? extra,
  }) {
    Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (hint != null) {
          scope.setTag('hint', hint);
        }
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setTag(key, value.toString());
          });
        }
      },
    );
  }

  static void captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) {
    Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setTag(key, value.toString());
          });
        }
      },
    );
  }

  static void addBreadcrumb(
    String message, {
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
      ),
    );
  }

  static void setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        email: email,
        username: username,
        data: extras,
      ));
    });
  }

  static void setTag(String key, String value) {
    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  static void setContext(String key, Map<String, dynamic> context) {
    Sentry.configureScope((scope) {
      context.forEach((contextKey, value) {
        scope.setTag('${key}_$contextKey', value.toString());
      });
    });
  }
}