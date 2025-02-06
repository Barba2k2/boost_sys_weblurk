import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service.dart';
import '../auth_store.dart';
import 'services/polling_services.dart';
import 'services/webview_service.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;
  final AppLogger _logger;
  final AuthStore _authStore;
  final WebViewService _webViewService;
  final PollingService _pollingService;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
    required AuthStore authStore,
    required WebViewService webViewService,
    required PollingService pollingService,
  })  : _homeService = homeService,
        _logger = logger,
        _authStore = authStore,
        _webViewService = webViewService,
        _pollingService = pollingService;

  Timer? _webViewHealthTimer;
  bool _isDisposed = false;

  @observable
  bool isWebViewHealthy = true;

  @observable
  String? currentChannel;

  @observable
  bool isScheduleVisible = false;

  @observable
  String initialChannel = 'BoostTeam_';

  @action
  Future<void> onInit() async {
    _logger.info('Iniciando HomeController...');
    try {
      _setupWebViewMonitoring();

      await _authStore.loadUserLogged();
      if (_authStore.userLogged == null) {
        await _handleNotLoggedIn();
        return;
      }

      if (_webViewService.isInitialized) {
        await _initializeServices();
      }
    } catch (e, s) {
      await _handleError(e, s);
    }
  }

  void _setupWebViewMonitoring() {
    _webViewHealthTimer?.cancel();
    _webViewHealthTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!_isDisposed) {
        _checkWebViewHealth();
      }
    });
  }

  Future<void> _checkWebViewHealth() async {
    try {
      if (!_webViewService.isInitialized || _webViewService.controller == null) {
        _logger.warning('WebView não está inicializado');
        isWebViewHealthy = false;
        return;
      }

      // Verifica se o WebView está responsivo
      isWebViewHealthy = await _webViewService.isResponding();

      if (!isWebViewHealthy) {
        _logger.warning('WebView não está respondendo, tentando recuperar...');
        await _recoverWebView();
      }
    } catch (e, s) {
      _logger.error('Erro ao verificar saúde do WebView', e, s);
      isWebViewHealthy = false;
      await _recoverWebView();
    }
  }

  Future<void> _recoverWebView() async {
    try {
      _logger.info('Tentando recuperar WebView...');

      // Para o polling antes de reiniciar
      await _pollingService.stopPolling();

      // Tenta recarregar primeiro
      await reloadWebView();

      // Se ainda não está saudável, reinicializa completamente
      if (!isWebViewHealthy) {
        _webViewService.dispose();
        if (_webViewService.controller != null) {
          await _webViewService.initializeWebView(_webViewService.controller!);
          await _initializeServices();
        }
      }

      // Reinicia o polling
      final streamerId = _getCurrentStreamerId();
      if (streamerId > 0) {
        await _pollingService.startPolling(streamerId);
      }

      _logger.info('WebView recuperado com sucesso');
    } catch (e, s) {
      _logger.error('Falha ao recuperar WebView', e, s);
      Messages.warning('Erro ao recuperar aplicação. Tente reiniciar o programa.');
    }
  }

  Future<void> _initializeServices() async {
    _logger.info('Inicializando serviços...');
    try {
      await loadCurrentChannel();
      await _homeService.fetchSchedules();

      final streamerId = _getCurrentStreamerId();
      if (streamerId > 0) {
        await _pollingService.startPolling(streamerId);
      }

      _logger.info('Serviços inicializados com sucesso');
    } catch (e, s) {
      _logger.error('Error initializing services', e, s);
      Messages.warning('Erro ao inicializar serviços');
      rethrow;
    }
  }

  @action
  Future<void> onWebViewCreated(Webview controller) async {
    _logger.info('WebView criado, iniciando configuração...');
    try {
      if (_authStore.userLogged == null) {
        throw Failure(message: 'Usuário não está autenticado');
      }

      await _webViewService.initializeWebView(controller);
      await _initializeServices();

      _logger.info('WebView configurado com sucesso');
    } catch (e, s) {
      _logger.error('Erro durante inicialização do WebView', e, s);
      await _handleError(e, s);
    }
  }

  @action
  Future<void> loadCurrentChannel() async {
    try {
      currentChannel = await _homeService.fetchCurrentChannel();
      if (currentChannel != null) {
        await _webViewService.loadUrl(currentChannel!);
      }
      _logger.info('Canal atual carregado: $currentChannel');
    } catch (e, s) {
      _logger.error('Error loading current channel', e, s);
      Messages.warning('Erro ao carregar canal atual');
      rethrow;
    }
  }

  int _getCurrentStreamerId() {
    try {
      if (_authStore.userLogged == null || _authStore.userLogged?.id == null) {
        _logger.warning('Usuário não está logado ou ID é nulo');
        return 0;
      }

      final streamerId = int.tryParse(_authStore.userLogged!.id.toString());
      if (streamerId == null || streamerId <= 0) {
        _logger.warning('ID do streamer inválido: $streamerId');
        return 0;
      }

      _logger.info('Streamer ID obtido com sucesso: $streamerId');
      return streamerId;
    } catch (e, s) {
      _logger.error('Erro ao obter ID do streamer', e, s);
      return 0;
    }
  }

  @action
  Future<void> reloadWebView() async {
    _logger.info('Recarregando WebView...');
    try {
      Loader.show();
      await _webViewService.reload();
      await loadCurrentChannel();
      Loader.hide();
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      Loader.hide();
      _logger.error('Erro ao recarregar WebView', e, s);
      Messages.warning('Erro ao atualizar a página');
    }
  }

  Future<void> _handleNotLoggedIn() async {
    _logger.info('Usuário não logado, redirecionando...');
    if (!Modular.to.path.contains('/auth/login')) {
      Modular.to.navigate('/auth/login/');
    }
  }

  Future<void> _handleError(Object error, StackTrace stackTrace) async {
    _logger.error('Error in HomeController', error, stackTrace);

    if (error.toString().contains('autenticação') || error.toString().contains('Expire token')) {
      await _authStore.logout();
      if (!Modular.to.path.contains('/auth/login')) {
        Modular.to.navigate('/auth/login/');
      }
    } else {
      Messages.warning('Erro ao inicializar aplicação');
    }
  }

  void dispose() {
    _isDisposed = true;
    _webViewHealthTimer?.cancel();
    _pollingService.stopPolling();
    _webViewService.dispose();
    _logger.info('HomeController disposed');
  }
}
