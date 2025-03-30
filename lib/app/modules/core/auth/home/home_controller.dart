import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service.dart';
import '../../../../service/webview/windows_web_view_service.dart';
import '../auth_store.dart';
import 'services/polling_services.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
    required AuthStore authStore,
    required WindowsWebViewService webViewService,
    required PollingService pollingService,
  })  : _homeService = homeService,
        _logger = logger,
        _authStore = authStore,
        _webViewService = webViewService,
        _pollingService = pollingService {
    // Observa o status de saúde do WebView e do Polling
    _subscribeToHealthEvents();
  }

  final HomeService _homeService;
  final AppLogger _logger;
  final AuthStore _authStore;
  final WindowsWebViewService _webViewService;
  final PollingService _pollingService;

  late StreamSubscription _webViewHealthSubscription;
  late StreamSubscription _pollingHealthSubscription;
  late StreamSubscription _channelUpdateSubscription;

  Timer? _webViewHealthTimer;
  bool _isDisposed = false;
  bool _recoveryInProgress = false;

  @observable
  bool isWebViewHealthy = true;

  @observable
  String? currentChannel;

  @observable
  bool isScheduleVisible = false;

  @observable
  String initialChannel = 'https://twitch.tv/BoostTeam_';

  @observable
  bool isRecovering = false;

  void _subscribeToHealthEvents() {
    _webViewHealthSubscription = _webViewService.healthStatus.listen((isHealthy) {
      isWebViewHealthy = isHealthy;
      if (!isHealthy && !_recoveryInProgress) {
        _logger.warning('Problema de saúde do WebView detectado, iniciando recuperação...');
        _recoverWebView();
      }
    });

    _pollingHealthSubscription = _pollingService.healthStatus.listen((isHealthy) {
      if (!isHealthy) {
        _logger.warning('Problema de saúde do Polling detectado');
        _ensurePollingActive();
      }
    });

    // Subscribe to channel updates from polling service
    _channelUpdateSubscription = _pollingService.channelUpdates.listen((channelUrl) {
      _handleChannelUpdate(channelUrl);
    });
  }

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
    _webViewHealthTimer = Timer.periodic(const Duration(minutes: 2), (_) {
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

  @action
  Future<void> _recoverWebView() async {
    // Evita múltiplas recuperações simultâneas
    if (_recoveryInProgress) {
      _logger.info('Recuperação já em andamento, ignorando...');
      return;
    }

    try {
      _recoveryInProgress = true;
      isRecovering = true;
      _logger.info('Tentando recuperar WebView...');

      // Para o polling antes de reiniciar
      await _pollingService.stopPolling();

      // Tenta recarregar primeiro
      await reloadWebView();

      // Aguarda um momento para verificar se o reload resolveu
      await Future.delayed(const Duration(seconds: 3));

      // Verifica novamente o status de saúde
      final isResponding = await _webViewService.isResponding();

      // Se ainda não está saudável, notifica o problema
      if (!isResponding) {
        _logger.warning('Reload não resolveu o problema, notificando usuário...');
        Messages.warning(
            'Problema detectado no navegador. Tente reiniciar o aplicativo se o problema persistir.');
      }

      // Reinicia o polling
      await _ensurePollingActive();

      _logger.info('WebView recuperado com sucesso');
      isWebViewHealthy = true;
    } catch (e, s) {
      _logger.error('Falha ao recuperar WebView', e, s);
      Messages.warning('Erro ao recuperar aplicação. Tente reiniciar o programa.');
      isWebViewHealthy = false;
    } finally {
      isRecovering = false;
      _recoveryInProgress = false;
    }
  }

  Future<void> _ensurePollingActive() async {
    final streamerId = _getCurrentStreamerId();
    if (streamerId > 0) {
      _logger.info('Reiniciando polling com streamerId: $streamerId');
      await _pollingService.startPolling(streamerId);
    } else {
      _logger.warning('Não foi possível obter ID válido para polling');
    }
  }

  Future<void> _initializeServices() async {
    _logger.info('Inicializando serviços...');
    try {
      await loadCurrentChannel();
      await _homeService.fetchSchedules();

      await _ensurePollingActive();

      _logger.info('Serviços inicializados com sucesso');
    } catch (e, s) {
      _logger.error('Error initializing services', e, s);
      Messages.warning('Erro ao inicializar serviços');
      rethrow;
    }
  }

  @action
  Future<void> onWebViewCreated(WebviewController controller) async {
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
      // Armazena o canal atual para comparação
      final previousChannel = currentChannel;

      // Busca o novo canal
      currentChannel = await _homeService.fetchCurrentChannel();

      // Se mudou de canal, carrega a nova URL
      if (currentChannel != null && currentChannel != previousChannel) {
        _logger.info('Canal alterado de $previousChannel para $currentChannel');
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

  @action
  Future<void> _handleChannelUpdate(String channelUrl) async {
    try {
      _logger.info('Recebido update de canal do polling: $channelUrl');

      // Update the current channel
      currentChannel = channelUrl;

      // Load the new URL in the webview
      if (_webViewService.isInitialized) {
        _logger.info('Carregando novo canal no WebView: $channelUrl');
        await _webViewService.loadUrl(channelUrl);
      } else {
        _logger.warning('WebView não inicializado, não foi possível carregar o canal: $channelUrl');
      }
    } catch (e, s) {
      _logger.error('Erro ao processar atualização de canal', e, s);
    }
  }

  void dispose() {
    _isDisposed = true;
    _webViewHealthTimer?.cancel();
    _webViewHealthSubscription.cancel();
    _pollingHealthSubscription.cancel();
    _channelUpdateSubscription.cancel();
    _pollingService.stopPolling();
    _webViewService.dispose();
    _logger.info('HomeController disposed');
  }
}
