import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../service/home/home_service.dart';
import '../auth_store.dart';

part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;
  final AppLogger _logger;
  final AuthStore _authStore;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
    required AuthStore authStore,
  })  : _homeService = homeService,
        _logger = logger,
        _authStore = authStore;

  @observable
  late Future<void> initializationFuture;

  @observable
  var isScheduleVisible = false;

  @observable
  String initialChannel = 'BoostTeam_';

  @observable
  String? currentChannel;

  @observable
  InAppWebViewController? webViewController;

  bool isWebViewInitialized = false;
  bool _isPollingActive = false;

  final Completer<void> _webViewInitialized = Completer<void>();

  final webViewControllerCompleter = Completer<InAppWebViewController>();

  Timer? _pollingTimer;
  Timer? _scoreCheckTimer;
  Timer? _loaderTimer;

  @action
  Future<void> onInit() async {
    _logger.info('Iniciando HomeController...');
    try {
      // Primeiro tenta carregar os dados do usuário
      await _authStore.loadUserLogged();

      if (_authStore.userLogged == null || _authStore.userLogged?.id == null) {
        _logger.warning(
          "Nenhum usuário logado encontrado, redirecionando para login.",
        );
        await _authStore.logout();
        Modular.to.navigate('/auth/login/');
      } else {
        _logger.info(
          "Usuário logado encontrado: ${_authStore.userLogged!.nickname}",
        );
        await _initializeWebView();
      }
    } catch (e, s) {
      _logger.error("Erro ao inicializar HomeController", e, s);
      await _authStore.logout();
      Modular.to.navigate('/auth/login/');
    }
  }

  Future<void> _initializeWebView() async {
    try {
      if (webViewController != null) {
        await _loadInitialChannel();
        await loadSchedules();
        await startPollingForUpdates();
        await startCheckingScores();
      }
    } catch (e, s) {
      _logger.error("Erro ao inicializar WebView", e, s);
      Messages.warning('Erro ao inicializar WebView');
    }
  }

  void _showLoader() {
    Loader.show();
    _loaderTimer?.cancel();
    _loaderTimer = Timer(Duration(seconds: 10), () {
      Loader.hide();
      Messages.warning('Operação demorou mais que o esperado');
    });
  }

  void _hideLoader() {
    _loaderTimer?.cancel();
    Loader.hide();
  }

  @action
  Future<void> loadSchedules() async {
    try {
      await _homeService.fetchSchedules();
    } catch (e, s) {
      _logger.error('Error on load schedules', e, s);
      Messages.warning('Erro ao carregar os agendamentos');
      throw Failure(message: 'Erro ao carregar os agendamentos');
    }
  }

  @action
  Future<void> initializeWebView(InAppWebViewController controller) async {
    webViewController = controller;
    isWebViewInitialized = true;

    if (!_webViewInitialized.isCompleted) {
      _webViewInitialized.complete();
    }

    try {
      await _loadInitialChannel();
    } catch (e, s) {
      if (!_webViewInitialized.isCompleted) {
        _webViewInitialized.completeError(e);
      }
      _logger.error('Error initializing webview', e, s);
    }
  }

  Future<bool> _checkAuthentication() async {
    if (_authStore.userLogged == null || _authStore.userLogged?.id == null) {
      _logger.warning('Usuário não está autenticado');
      await _authStore.logout();
      Modular.to.navigate('/auth/login/');
      return false;
    }
    return true;
  }

  @action
  Future<void> _loadInitialChannel() async {
    try {
      if (!await _checkAuthentication()) return;

      final correctUrl = await _homeService.fetchCurrentChannel();
      if (correctUrl != null) {
        if (webViewController == null) {
          throw Failure(message: 'WebViewController não inicializado');
        }

        await webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(correctUrl)),
        );

        _logger.info('Canal carregado com sucesso: $correctUrl');
      } else {
        throw Failure(message: 'URL não encontrada');
      }
    } catch (e, s) {
      _logger.error('Error loading initial channel URL', e, s);
      Messages.warning('Erro ao carregar o canal inicial');
      throw Failure(message: 'Erro ao carregar o canal inicial');
    }
  }

  @action
  Future<void> onWebViewCreated(InAppWebViewController controller) async {
    _logger.info('WebView criado, configurando controller...');
    try {
      _showLoader();
      webViewController = controller;
      isWebViewInitialized = true;

      _logger.info('Inicializando WebView...');
      await _loadInitialChannelWithRetry();
      _logger.info('Canal inicial carregado com sucesso');

      _logger.info('Carregando schedules...');
      await loadSchedules();
      _logger.info('Schedules carregados com sucesso');

      _logger.info('Iniciando polling...');
      await startPollingForUpdates();
      _logger.info('Polling iniciado com sucesso');

      _logger.info('Iniciando verificação de scores...');
      await startCheckingScores();
      _logger.info('Verificação de scores iniciada com sucesso');

      _hideLoader();
    } catch (e, s) {
      _hideLoader();
      _logger.error('Erro durante inicialização do WebView', e, s);
      Messages.warning('Erro na inicialização.');

      if (e is Failure /*&& e.message?.contains('autenticação') == true*/) {
        await _authStore.logout();
        Modular.to.navigate('/auth/login/');
      }
    }
  }

  Future<void> _loadInitialChannelWithRetry() async {
    int attempts = 0;
    const maxAttempts = 3;
    const retryDelay = Duration(seconds: 1);

    while (attempts < maxAttempts) {
      try {
        _logger.info(
          'Tentativa ${attempts + 1} de $maxAttempts para carregar canal inicial',
        );
        await _loadInitialChannel();
        _logger.info(
          'Canal inicial carregado com sucesso na tentativa ${attempts + 1}',
        );
        return;
      } catch (e, s) {
        attempts++;
        _logger.warning(
          'Falha ao carregar canal inicial (tentativa $attempts de $maxAttempts): ${e.toString()}',
        );

        if (attempts == maxAttempts) {
          _logger.error(
            'Todas as tentativas de carregar canal inicial falharam',
            e,
            s,
          );
          rethrow;
        }

        await Future.delayed(retryDelay);
      }
    }
  }

  @action
  Future<void> loadCurrentChannel() async {
    try {
      final newChannel = await _homeService.fetchCurrentChannel();
      currentChannel = newChannel ?? 'https://twitch.tv/BoostTeam_';

      if (isWebViewInitialized &&
          webViewController != null &&
          currentChannel != null) {
        await webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(currentChannel!)),
        );
        _logger.info('Current Channel: $currentChannel');
      }
    } catch (e, s) {
      _logger.error('Error loading current channel URL', e, s);
      Messages.warning('Erro ao carregar o canal atual');
      throw Failure(message: 'Erro ao carregar o canal atual');
    }
  }

  @action
  Future<void> startPollingForUpdates() async {
    _logger.info('Iniciando polling para atualizações...');

    if (_isPollingActive) {
      _logger.info('Polling já está ativo, ignorando nova chamada');
      return;
    }

    _isPollingActive = true;
    const pollingInterval = Duration(minutes: 6);

    _pollingTimer?.cancel();

    try {
      _logger.info('Executando primeira atualização do polling');
      await loadCurrentChannel();
    } catch (e, s) {
      _logger.error('Erro na primeira atualização do polling', e, s);
    }

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      try {
        _logger.info('Executando polling periódico - ${DateTime.now()}');
        await loadCurrentChannel();
      } catch (e, s) {
        _logger.error('Erro durante polling periódico', e, s);
      }
    });

    _logger.info(
      'Polling iniciado com sucesso - Intervalo: ${pollingInterval.inSeconds}s',
    );
  }

  // @action
  // Future<void> forceUpdateLive() async {
  //   try {
  //     await _homeService.forceUpdateLive();
  //     await loadCurrentChannel();
  //   } catch (e, s) {
  //     _logger.error('Error on force update', e, s);
  //     throw Failure(message: 'Erro ao forçar a atualização da live');
  //   }
  // }

  @action
  Future<void> startCheckingScores() async {
    _logger.info('Iniciando verificação de scores...');

    _scoreCheckTimer?.cancel();

    const interval = Duration(minutes: 6);

    try {
      _logger.info('Executando primeira verificação de score');
      await _saveScore();
      _logger.info('Primeira verificação de score executada com sucesso');
    } catch (e, s) {
      _logger.error('Erro na primeira verificação de score', e, s);
    }

    _scoreCheckTimer = Timer.periodic(interval, (timer) async {
      try {
        _logger.info('Executando verificação periódica de score');
        await _saveScore();
        _logger.info('Verificação periódica de score executada com sucesso');
      } catch (e, s) {
        _logger.error('Erro durante verificação periódica de score', e, s);
      }
    });

    _logger.info('Verificação de scores iniciada com sucesso');
  }

  Future<void> _saveScore() async {
    _logger.info('Iniciando salvamento de score...');

    try {
      if (_authStore.userLogged == null) {
        _logger.warning('Nenhum usuário logado para salvar score');
        return;
      }

      final streamerId = _getCurrentStreamerId();
      if (streamerId <= 0) {
        _logger.warning('ID do streamer inválido: $streamerId');
        return;
      }

      final now = DateTime.now();

      _logger.info(
        'Salvando score para streamer $streamerId em ${now.toString()}',
      );

      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        now.hour,
        now.minute,
        10,
      );

      _logger.info('Score salvo com sucesso');
    } catch (e, s) {
      _logger.error('Erro ao salvar score', e, s);

      if (e is Failure) {
        _logger.error('Motivo do erro: ${e.message}');
      }

      throw Failure(message: 'Erro ao salvar a pontuação');
    }
  }

  int _getCurrentStreamerId() {
    try {
      if (_authStore.userLogged == null) {
        _logger.warning('Nenhum usuário está logado');
        return 0;
      }

      final userId = _authStore.userLogged?.id;
      if (userId == null) {
        _logger.warning('ID do usuário é null');
        return 0;
      }

      final streamerId = int.tryParse(userId.toString());
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

  void dispose() {
    _logger.info('Disposing HomeController...');
    _loaderTimer?.cancel();
    _pollingTimer?.cancel();
    _scoreCheckTimer?.cancel();
    _isPollingActive = false;
    webViewController = null;
    isWebViewInitialized = false;
    _logger.info('HomeController disposed');
  }
}
