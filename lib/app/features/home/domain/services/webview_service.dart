import 'dart:async';

import '../../../../core/result/result.dart';

abstract class WebViewService {
  Future<AppResult<AppUnit>> initializeWebView(dynamic controller);
  Future<AppResult<AppUnit>> loadUrl(String url);
  Future<AppResult<AppUnit>> reloadWebView();
  Future<AppResult<bool>> isResponding();
  dynamic get controller;
  bool get isInitialized;
  Stream<bool> get healthStatus;
}
