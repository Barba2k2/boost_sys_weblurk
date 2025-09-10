import 'dart:io';

import 'package:flutter/foundation.dart';

import 'webview_android_controller.dart';
import 'webview_controller_interface.dart';
import 'webview_windows_controller.dart';

/// Factory class to create platform-specific webview controllers
class WebViewControllerFactory {
  /// Create a webview controller based on the current platform
  static WebViewControllerInterface createController() {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported');
    }

    if (Platform.isWindows) {
      return WebViewWindowsController();
    } else if (Platform.isAndroid) {
      return WebViewAndroidController();
    } else if (Platform.isIOS || Platform.isMacOS) {
      // Use webview_flutter for iOS and macOS (supports WKWebView)
      return WebViewAndroidController();
    } else {
      throw UnsupportedError(
          'Platform ${Platform.operatingSystem} is not supported');
    }
  }

  /// Check if the current platform is supported
  static bool isPlatformSupported() {
    if (kIsWeb) return false;
    return Platform.isWindows ||
        Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS;
  }

  /// Get the current platform name
  static String getPlatformName() {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystem;
  }
}
