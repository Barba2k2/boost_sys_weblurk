import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../core/logger/app_logger.dart';

class UniversalWebViewController {
  static Future<WebViewController> createController({
    required AppLogger? logger,
  }) async {
    logger?.info('Criando WebViewController para ${Platform.operatingSystem}');
    
    late final PlatformWebViewControllerCreationParams params;
    
    if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserActionForPlayback: const <PlaybackMediaTypes>{},
      );
    } else {
      params = PlatformWebViewControllerCreationParams();
    }
    
    final controller = WebViewController.fromPlatformCreationParams(params);
    logger?.info('WebViewController criado com sucesso');
    
    return controller;
  }

  static Future<void> configureController({
    required WebViewController controller,
    required NavigationDelegate navigationDelegate,
    required AppLogger? logger,
  }) async {
    logger?.info('Configurando WebViewController');
    
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.transparent);
    await controller.setNavigationDelegate(navigationDelegate);
    await _configurePlatformSpecificSettings(controller, logger);
    
    logger?.info('WebViewController configurado com sucesso');
  }

  static Future<void> _configurePlatformSpecificSettings(
    WebViewController controller,
    AppLogger? logger,
  ) async {
    if (Platform.isAndroid) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (Platform.isIOS) {
      final webKitController = controller.platform as WebKitWebViewController;
      await webKitController.setAllowsBackForwardNavigationGestures(false);
    }
  }

  static Future<void> loadUrl({
    required WebViewController controller,
    required String url,
    required AppLogger? logger,
  }) async {
    logger?.info('Carregando URL: $url');
    await controller.loadRequest(Uri.parse(url));
    logger?.info('URL carregada com sucesso: $url');
  }

  static Future<void> reload({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    logger?.info('Recarregando WebView');
    await controller.reload();
    logger?.info('WebView recarregado com sucesso');
  }

  static Future<void> clearCache({
    required WebViewController controller,
    required AppLogger? logger,
  }) async {
    logger?.info('Limpando cache do WebView');
    await controller.clearCache();
    logger?.info('Cache do WebView limpo com sucesso');
  }
} 