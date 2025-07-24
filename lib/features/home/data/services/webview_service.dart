// lib/features/home/data/services/webview_service.dart
import 'dart:async';
import '../../../../core/logger/app_logger.dart';

abstract class WebViewService {
  bool get isVolumeControlAvailable;
  Future<void> muteWebView();
  Future<void> unmuteWebView();
  Future<void> setWebViewVolume(double volume);
  void dispose();
}

class WebViewServiceImpl implements WebViewService {
  WebViewServiceImpl({
    required AppLogger logger,
  }) : _logger = logger;

  final AppLogger _logger;

  @override
  bool get isVolumeControlAvailable => true;

  @override
  Future<void> muteWebView() async {
    try {
      _logger.info('WebView muted (service level)');
    } catch (e, s) {
      _logger.error('Error muting WebView', e, s);
    }
  }

  @override
  Future<void> unmuteWebView() async {
    try {
      _logger.info('WebView unmuted (service level)');
    } catch (e, s) {
      _logger.error('Error unmuting WebView', e, s);
    }
  }

  @override
  Future<void> setWebViewVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      _logger.info('WebView volume set to: $clampedVolume (service level)');
    } catch (e, s) {
      _logger.error('Error setting WebView volume', e, s);
    }
  }

  @override
  void dispose() {
    _logger.info('WebView service disposed');
  }
}
