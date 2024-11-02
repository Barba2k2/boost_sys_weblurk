import 'package:flutter/foundation.dart';

class WebViewStateController extends ChangeNotifier {
  bool _isWebviewReady = false;
  String _currentUrl = '';
  String _authToken = '';
  String? _error;
  bool _isLoading = false;

  bool get isWebviewReady => _isWebviewReady;
  String get currentUrl => _currentUrl;
  String get authToken => _authToken;
  String? get error => _error;
  bool get isLoading => _isLoading;

  void setWebviewReady(bool value) {
    _isWebviewReady = value;
    notifyListeners();
  }

  void setCurrentUrl(String url) {
    _currentUrl = url;
    notifyListeners();
  }

  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
