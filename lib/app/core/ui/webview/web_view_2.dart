import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'interfaces/webview2_interface.dart';

class WebView2 {
  final int hwnd;
  late Pointer<ICoreWebView2Controller> _controller;
  late Pointer<ICoreWebView2> _webview;

  final _webMessageController = StreamController<String>.broadcast();
  final _navigationCompletedController = StreamController<bool>.broadcast();
  final _navigationStartingController = StreamController<void>.broadcast();
  final _sourceChangedController = StreamController<String>.broadcast();

  Stream<String> get webMessageReceived => _webMessageController.stream;
  Stream<bool> get navigationCompleted => _navigationCompletedController.stream;
  Stream<void> get navigationStarting => _navigationStartingController.stream;
  Stream<String> get sourceChanged => _sourceChangedController.stream;

  WebView2(this.hwnd);

  Future<void> initialize() async {
    try {
      final environment = calloc<Pointer<ICoreWebView2Environment>>();
      final options = calloc<Pointer<ICoreWebView2EnvironmentOptions>>();

      // ... [Mantida a criação do ambiente] ...

      final controllerPtr = calloc<Pointer<ICoreWebView2Controller>>();
      final createHr = environment.value.createController(hwnd, controllerPtr);

      if (FAILED(createHr)) {
        throw WindowsException(createHr);
      }

      _controller = controllerPtr.value;

      final webviewPtr = calloc<Pointer<ICoreWebView2>>();
      final getViewHr = _controller.getCoreWebView2(webviewPtr);

      if (FAILED(getViewHr)) {
        throw WindowsException(getViewHr);
      }

      _webview = webviewPtr.value;

      _setupEventHandlers();

      // Libera a memória alocada
      free(environment);
      free(options);
      free(controllerPtr);
      free(webviewPtr);
    } catch (e) {
      rethrow;
    }
  }

  void _setupEventHandlers() {
    // Implementação dos handlers será adicionada posteriormente
  }

  Future<void> navigate(String url) async {
    final urlPtr = url.toNativeUtf16();
    try {
      final hr = _webview.navigate(urlPtr);
      if (FAILED(hr)) {
        throw WindowsException(hr);
      }
      _sourceChangedController.add(url);
    } finally {
      free(urlPtr);
    }
  }

  Future<void> executeScript(String script) async {
    final scriptPtr = script.toNativeUtf16();
    final resultPtr = calloc<Pointer<Utf16>>();
    try {
      final hr = _webview.executeScript(
        scriptPtr,
        resultPtr,
      );
      if (FAILED(hr)) {
        throw WindowsException(hr);
      }
    } finally {
      free(scriptPtr);
      free(resultPtr);
    }
  }

  Future<void> addScriptToExecuteOnDocumentCreated(String script) async {
    final scriptPtr = script.toNativeUtf16();
    try {
      final hr = _webview.addScriptToExecuteOnDocumentCreated(
        scriptPtr,
        nullptr,
      );
      if (FAILED(hr)) {
        throw WindowsException(hr);
      }
    } finally {
      free(scriptPtr);
    }
  }

  void resize(int width, int height) {
    final bounds = calloc<RECT>()
      ..ref.left = 0
      ..ref.top = 0
      ..ref.right = width
      ..ref.bottom = height;

    try {
      final hr = _controller.putBounds(
        bounds,
      );
      if (FAILED(hr)) {
        throw WindowsException(hr);
      }
    } finally {
      free(bounds);
    }
  }

  void dispose() {
    _webMessageController.close();
    _navigationCompletedController.close();
    _navigationStartingController.close();
    _sourceChangedController.close();

    _controller.close();
    _webview.release();
  }
}
