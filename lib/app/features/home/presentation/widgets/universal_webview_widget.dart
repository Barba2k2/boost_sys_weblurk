import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/logger/app_logger.dart';
import 'universal_webview_widget/universal_webview_widgets.dart';

class UniversalWebViewWidget extends StatefulWidget {
  const UniversalWebViewWidget({
    required this.initialUrl,
    this.currentUrl,
    this.onWebViewCreated,
    this.logger,
    this.isMuted = false,
    super.key,
  });

  final String initialUrl;
  final String? currentUrl;
  final void Function(WebViewController)? onWebViewCreated;
  final AppLogger? logger;
  final bool isMuted;

  @override
  State<UniversalWebViewWidget> createState() => _UniversalWebViewWidgetState();
}

class _UniversalWebViewWidgetState extends State<UniversalWebViewWidget> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentUrl = '';
  final _loadingProgress = ValueNotifier<double>(0);
  Timer? _progressTimer;
  bool _isMuted = false;
  bool _isOperationInProgress = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.currentUrl ?? widget.initialUrl;
    _isMuted = widget.isMuted;
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant UniversalWebViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleUrlUpdate(oldWidget);
    _handleMuteUpdate(oldWidget);
  }

  void _handleUrlUpdate(UniversalWebViewWidget oldWidget) {
    final newUrl = widget.currentUrl ?? widget.initialUrl;
    if (newUrl != _currentUrl && newUrl.isNotEmpty) {
      _currentUrl = newUrl;
      _loadNewUrl(newUrl);
    }
  }

  void _handleMuteUpdate(UniversalWebViewWidget oldWidget) {
    if (widget.isMuted != _isMuted) {
      _isMuted = widget.isMuted;
      _updateAudioMute();
    }
  }

  Future<void> _initWebView() async {
    if (_isOperationInProgress) return;
    _isOperationInProgress = true;
    
    try {
      widget.logger?.info('Inicializando WebView universal para  [1m${Platform.operatingSystem} [0m');
      
      _controller = await UniversalWebViewController.createController(
        logger: widget.logger,
      );
      
      await UniversalWebViewController.configureController(
        controller: _controller,
        navigationDelegate: _createNavigationDelegate(),
        logger: widget.logger,
      );
      
      await UniversalWebViewController.loadUrl(
        controller: _controller,
        url: _currentUrl,
        logger: widget.logger,
      );
      
      if (widget.onWebViewCreated != null) {
        widget.onWebViewCreated!(_controller);
      }
      
      widget.logger?.info('WebView inicializado com sucesso');
    } catch (e, s) {
      _handleInitError(e, s);
    } finally {
      _isOperationInProgress = false;
    }
  }

  void _handleInitError(dynamic e, StackTrace s) {
    widget.logger?.error('Erro na inicialização do WebView:', e, s);
    if (mounted) {
      setState(() {
        _errorMessage = '''
            Erro ao inicializar WebView:
            ${e.toString()}
            \nStackTrace:
            $s
        ''';
      });
    }
  }

  NavigationDelegate _createNavigationDelegate() {
    return UniversalWebViewNavigation.createNavigationDelegate(
      onPageStarted: _handlePageStarted,
      onProgress: _handleProgress,
      onPageFinished: _handlePageFinished,
      onNavigationRequest: _handleNavigationRequest,
      onWebResourceError: _handleWebResourceError,
    );
  }

  void _handlePageStarted(String url) {
    UniversalWebViewNavigation.handlePageStarted(url, widget.logger);
    setState(() {
      _isLoading = true;
      _loadingProgress.value = 0.1;
    });
    _startProgressSimulation();
  }

  void _handleProgress(int progress) {
    UniversalWebViewNavigation.handleProgress(progress, widget.logger);
    _loadingProgress.value = progress / 100;
  }

  void _handlePageFinished(String url) {
    UniversalWebViewNavigation.handlePageFinished(url, widget.logger);
    setState(() {
      _isLoading = false;
      _currentUrl = url;
    });
    _stopProgressSimulation();
    UniversalWebViewJavaScript.injectJavaScriptDialogs(
      controller: _controller,
      logger: widget.logger,
    );
    _updateAudioMute();
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    return UniversalWebViewNavigation.handleNavigationRequest(request, widget.logger);
  }

  void _handleWebResourceError(WebResourceError error) {
    UniversalWebViewNavigation.handleWebResourceError(error, widget.logger);
    setState(() {
      _errorMessage = 'Erro ao carregar página: ${error.description}';
    });
  }

  void _startProgressSimulation() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isLoading && _loadingProgress.value < 0.9) {
        _loadingProgress.value = (_loadingProgress.value + 0.02).clamp(0.0, 0.9);
      }
    });
  }

  void _stopProgressSimulation() {
    _progressTimer?.cancel();
    _loadingProgress.value = 1.0;
  }

  Future<void> _updateAudioMute() async {
    if (_isMuted) {
      await UniversalWebViewAudio.muteAllMedia(
        controller: _controller,
        logger: widget.logger,
      );
    } else {
      await UniversalWebViewAudio.unmuteAllMedia(
        controller: _controller,
        logger: widget.logger,
      );
    }
  }

  Future<void> _loadNewUrl(String url) async {
    try {
      await UniversalWebViewController.loadUrl(
        controller: _controller,
        url: url,
        logger: widget.logger,
      );
    } catch (e, s) {
      widget.logger?.error('Erro ao carregar nova URL: $url', e, s);
    }
  }

  Future<void> _safeRefresh() async {
    await UniversalWebViewRefresh.safeRefresh(
      controller: _controller,
      currentUrl: _currentUrl,
      logger: widget.logger,
      isOperationInProgress: _isOperationInProgress,
      setLoadingState: _setLoadingState,
      startProgressTimer: _startProgressTimer,
      resetWebView: _resetWebView,
    );
  }

  void _setLoadingState(bool loading) {
    setState(() {
      _isLoading = loading;
      _loadingProgress.value = loading ? 0.0 : 1.0;
    });
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isLoading) {
        _loadingProgress.value = (_loadingProgress.value + 0.02).clamp(0.0, 0.95);
      } else {
        _loadingProgress.value = 1.0;
        timer.cancel();
      }
    });
  }

  Future<void> _resetWebView() async {
    try {
      widget.logger?.warning('Reinicializando WebView completamente...');
      _progressTimer?.cancel();
      _setLoadingState(true);
      await UniversalWebViewController.clearCache(
        controller: _controller,
        logger: widget.logger,
      );
      await _initWebView();
    } catch (e, s) {
      _handleResetError(e, s);
    }
  }

  void _handleResetError(dynamic e, StackTrace s) {
    widget.logger?.error('Erro fatal ao reinicializar WebView: $e', s);
    setState(() {
      _errorMessage = '''
          Erro crítico no WebView:
          ${e.toString()}
          \nPor favor, reinicie o aplicativo.
      ''';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return UniversalWebViewUIWidgets.buildErrorWidget(
        errorMessage: _errorMessage!,
        onRetry: _initWebView,
      );
    }
    return _buildWebViewWidget();
  }

  Widget _buildWebViewWidget() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) UniversalWebViewUIWidgets.buildProgressIndicator(
          loadingProgress: _loadingProgress,
        ),
        UniversalWebViewUIWidgets.buildLoadingIndicator(isLoading: _isLoading),
        if (_isMuted) UniversalWebViewUIWidgets.buildMuteIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
} 