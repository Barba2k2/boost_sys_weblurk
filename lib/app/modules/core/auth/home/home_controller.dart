import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/adapters/web_view_adapter.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/services/pooling_manager.dart';
import '../../../../core/services/score_manager.dart';
import '../../../../core/services/webview_manager.dart';
import '../../../../core/ui/webview/controller/web_view_state_controller.dart';
import '../../../../service/home/home_service.dart';
import '../auth_store.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;
  final AppLogger _logger;
  final AuthStore _authStore;

  late final WebViewManager _webViewManager;
  late final PollingManager _pollingManager;
  late final ScoreManager _scoreManager;

  int _initAttempts = 0;
  static const int maxInitAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @observable
  String? initializationError;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
    required AuthStore authStore,
  })  : _homeService = homeService,
        _logger = logger,
        _authStore = authStore {
    _webViewManager = WebViewManager(logger);
    _pollingManager = PollingManager(logger, homeService, _webViewManager);
    _scoreManager = ScoreManager(logger, homeService, authStore);

    initializationFuture = _initialize();
  }

  @observable
  late Future<void> initializationFuture;

  @observable
  var isScheduleVisible = false;

  @computed
  WebViewAdapter get webViewController => _webViewManager.webViewController;

  @computed
  WebViewStateController get stateController => _webViewManager.stateController;

  @computed
  String? get currentChannel => _pollingManager.currentChannel;

  @computed
  bool get isWebViewInitialized => _webViewManager.isWebViewInitialized;

  @action
  Future<void> onInit() async {
    _logger.info('Iniciando HomeController...');
    initializationFuture = _initializeWithRetry();
    try {
      await initializationFuture;
    } catch (e, s) {
      _logger.error('Erro fatal na inicialização do HomeController', e, s);
      await _handleInitializationError(e);
    }
  }

  Future<void> _initializeWithRetry() async {
    while (_initAttempts < maxInitAttempts) {
      try {
        await _initialize();
        _logger.info(
          'HomeController inicializado com sucesso na tentativa ${_initAttempts + 1}',
        );
        initializationError = null;
        return;
      } catch (e, s) {
        _initAttempts++;
        _logger.error(
          'Falha na tentativa $_initAttempts de $maxInitAttempts de inicialização',
          e,
          s,
        );

        if (_initAttempts >= maxInitAttempts) {
          initializationError =
              'Falha na inicialização após $_initAttempts tentativas';
          rethrow;
        }

        await _cleanup();
        await Future.delayed(retryDelay);
      }
    }
  }

  Future<void> _initialize() async {
    try {
      _logger.info('Iniciando carregamento do usuário...');
      await _authStore.loadUserLogged();
      if (_authStore.userLogged == null || _authStore.userLogged?.id == null) {
        throw Failure(message: 'Usuário não autenticado');
      }

      _logger.info('Iniciando WebView...');
      await _webViewManager.initialize();

      _logger.info('Iniciando Polling...');
      await _pollingManager.start();

      _logger.info('Iniciando Score Manager...');
      await _scoreManager.startChecking();

      _logger.info('HomeController totalmente inicializado');
    } catch (e, s) {
      _logger.error('Erro durante inicialização', e, s);
      await _cleanup();
      rethrow;
    }
  }

  Future<void> _cleanup() async {
    _logger.info('Realizando cleanup após falha...');
    try {
      _webViewManager.dispose();
      _pollingManager.dispose();
      _scoreManager.dispose();
    } catch (e, s) {
      _logger.error('Erro durante cleanup', e, s);
    }
  }

  Future<void> _handleInitializationError(dynamic error) async {
    try {
      String errorMessage = 'Erro ao inicializar aplicação';
      if (error is Failure) {
        errorMessage = error.message ?? errorMessage;
      }

      _logger.error('Erro de inicialização: $errorMessage');
      await _authStore.logout();
      Modular.to.navigate('/auth/login/');
    } catch (e, s) {
      _logger.error('Erro ao lidar com erro de inicialização', e, s);
    }
  }

  @action
  Future<void> loadSchedules() async {
    try {
      _logger.info('Carregando agendamentos...');
      await _homeService.fetchSchedules();
      _logger.info('Agendamentos carregados com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao carregar agendamentos', e, s);
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @action
  void toggleScheduleVisibility() {
    isScheduleVisible = !isScheduleVisible;
  }

  @action
  Future<void> forceUpdateChannel() async {
    try {
      _logger.info('Forçando atualização do canal...');
      await _pollingManager.forceUpdate();
      _logger.info('Canal atualizado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao forçar atualização do canal', e, s);
      throw Failure(message: 'Erro ao atualizar o canal');
    }
  }

  @action
  Future<void> restartWebView() async {
    try {
      _logger.info('Reiniciando WebView...');
      _webViewManager.dispose();
      await _webViewManager.initialize();
      await _pollingManager.start();
      _logger.info('WebView reiniciado com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao reiniciar WebView', e, s);
      throw Failure(message: 'Erro ao reiniciar WebView');
    }
  }

  void dispose() {
    _logger.info('Disposing HomeController...');
    try {
      _webViewManager.dispose();
      _pollingManager.dispose();
      _scoreManager.dispose();
      _logger.info('HomeController disposed com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao fazer dispose do HomeController', e, s);
    }
  }
}
