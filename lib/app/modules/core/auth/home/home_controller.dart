import 'dart:async';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service.dart';
import '../auth_store.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;
  final AppLogger _logger;
  final AuthStore _authStore;

  // Controle de estado
  @observable
  bool isInitialized = false;

  @observable
  bool isLoading = false;

  @observable
  String? currentChannel;

  @observable
  WebViewController? webViewController;

  // Controles internos
  final _initLock = Lock();
  bool _isPollingActive = false;
  Timer? _pollingTimer;
  Timer? _scoreCheckTimer;
  Timer? _loaderTimer;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
    required AuthStore authStore,
  })  : _homeService = homeService,
        _logger = logger,
        _authStore = authStore;

  @action
  Future<void> onInit() async {
    // Evita inicialização múltipla
    if (isInitialized) {
      _logger.info('HomeController já inicializado');
      return;
    }

    // Usa um lock para garantir inicialização única
    await _initLock.synchronized(() async {
      if (isInitialized) return;

      _logger.info('Iniciando HomeController...');
      try {
        await _checkAuthentication();
        isInitialized = true;
      } catch (e, s) {
        _logger.error("Erro ao inicializar HomeController", e, s);
        await _handleAuthError();
      }
    });
  }

  Future<void> _checkAuthentication() async {
    await _authStore.loadUserLogged();
    final user = _authStore.userLogged;

    if (user == null) {
      _logger.info('Nenhum usuário logado, redirecionando para login...');
      throw Failure(message: 'Usuário não autenticado');
    }
    _logger.info('Usuário logado: ${user.nickname}');
  }

  @action
  Future<void> onWebViewCreated(WebViewController controller) async {
    // Evita recriação do WebView
    if (webViewController != null) {
      _logger.info('WebView já criado');
      return;
    }

    _logger.info('WebView criado, configurando controller...');

    try {
      webViewController = controller;
      await _initializeWebViewFeatures();
    } catch (e, s) {
      _logger.error('Erro durante inicialização do WebView', e, s);
      await _handleError(e);
    }
  }

  Future<void> _initializeWebViewFeatures() async {
    if (!isInitialized) {
      _logger.warning(
          'Tentativa de inicializar features sem controller inicializado');
      return;
    }

    try {
      await _loadInitialChannel();
      await _startServices();
    } catch (e, s) {
      _logger.error('Erro ao inicializar features do WebView', e, s);
      throw Failure(message: 'Erro ao inicializar recursos do WebView');
    }
  }

  Future<void> _startServices() async {
    await loadSchedules();
    await _startPolling();
    await _startScoreChecking();
  }

  Future<void> _loadInitialChannel() async {
    try {
      final url = await _homeService.fetchCurrentChannel();
      if (url == null || webViewController == null) {
        throw Failure(message: 'Erro ao carregar canal inicial');
      }

      await webViewController!.loadRequest(Uri.parse(url));
      runInAction(() => currentChannel = url);
      _logger.info('Canal inicial carregado: $url');
    } catch (e, s) {
      _logger.error('Erro ao carregar canal inicial', e, s);
      throw Failure(message: 'Erro ao carregar canal inicial');
    }
  }

  @action
  Future<void> loadSchedules() async {
    if (!isInitialized) return;

    try {
      runInAction(() => isLoading = true);
      await _homeService.fetchSchedules();
    } catch (e, s) {
      _logger.error('Erro ao carregar agendamentos', e, s);
      throw Failure(message: 'Erro ao carregar agendamentos');
    } finally {
      runInAction(() => isLoading = false);
    }
  }

  Future<void> _startPolling() async {
    if (_isPollingActive) return;

    _isPollingActive = true;
    const interval = Duration(minutes: 6);

    try {
      await _updateChannel();
      _pollingTimer = Timer.periodic(interval, (_) => _updateChannel());
    } catch (e, s) {
      _logger.error('Erro ao iniciar polling', e, s);
      _isPollingActive = false;
    }
  }

  Future<void> _updateChannel() async {
    if (!isInitialized) return;

    try {
      final newChannel = await _homeService.fetchCurrentChannel();
      if (newChannel != null && newChannel != currentChannel) {
        await webViewController?.loadRequest(Uri.parse(newChannel));
        runInAction(() => currentChannel = newChannel);
      }
    } catch (e, s) {
      _logger.error('Erro ao atualizar canal', e, s);
    }
  }

  Future<void> _startScoreChecking() async {
    if (!isInitialized) return;

    const interval = Duration(minutes: 6);
    try {
      await _saveScore();
      _scoreCheckTimer = Timer.periodic(interval, (_) => _saveScore());
    } catch (e, s) {
      _logger.error('Erro ao iniciar verificação de scores', e, s);
    }
  }

  Future<void> _saveScore() async {
    if (!isInitialized) return;

    try {
      final streamerId = _getCurrentStreamerId();
      if (streamerId <= 0) return;

      final now = DateTime.now();
      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        1,
      );
    } catch (e, s) {
      _logger.error('Erro ao salvar score', e, s);
    }
  }

  int _getCurrentStreamerId() {
    final user = _authStore.userLogged;
    if (user?.id == null) return 0;
    return int.tryParse(user!.id.toString()) ?? 0;
  }

  Future<void> _handleError(dynamic error) async {
    if (error.toString().contains('autenticação') ||
        error.toString().contains('Expire token')) {
      await _handleAuthError();
    } else {
      await Future.microtask(() {
        Messages.warning('Erro na inicialização');
      });
    }
  }

  Future<void> _handleAuthError() async {
    if (!Modular.to.path.contains('/auth/login')) {
      await _authStore.logout();
      Modular.to.navigate('/auth/login/');
    }
  }

  @action
  Future<void> reloadWebView() async {
    if (!isInitialized || webViewController == null) {
      _logger.warning('Tentativa de reload sem WebView inicializado');
      return;
    }

    _logger.info('Recarregando WebView...');

    try {
      runInAction(() => isLoading = true);

      await webViewController!.reload();
      await _loadInitialChannel();

      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView', e, s);
      await Future.microtask(() {
        Messages.warning('Erro ao recarregar a página');
      });
    } finally {
      runInAction(() => isLoading = false);
    }
  }

  @action
  void dispose() {
    _logger.info('Disposing HomeController...');
    _loaderTimer?.cancel();
    _pollingTimer?.cancel();
    _scoreCheckTimer?.cancel();
    _isPollingActive = false;
    webViewController = null;
    isInitialized = false;
  }
}

class Lock {
  Completer<void>? _completer;

  Future<T> synchronized<T>(Future<T> Function() fn) async {
    if (_completer != null) {
      await _completer!.future;
      return await fn();
    }

    _completer = Completer<void>();
    try {
      final result = await fn();
      _completer!.complete();
      return result;
    } catch (e) {
      _completer!.complete();
      rethrow;
    } finally {
      _completer = null;
    }
  }
}
