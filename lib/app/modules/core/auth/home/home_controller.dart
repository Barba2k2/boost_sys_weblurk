import 'dart:async';

// import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  WebViewController? webViewController;

  bool isWebViewInitialized = false;
  bool _isPollingActive = false;

  final Completer<void> _webViewInitialized = Completer<void>();

  // final webViewControllerCompleter = Completer<InAppWebViewController>();

  Timer? _pollingTimer;
  Timer? _scoreCheckTimer;
  Timer? _loaderTimer;

  @action
  Future<void> onInit() async {
    _logger.info('Iniciando HomeController...');
    try {
      await _authStore.loadUserLogged();

      if (_authStore.userLogged == null) {
        _logger.info('Nenhum usuário logado, redirecionando para login...');
        if (!Modular.to.path.contains('/auth/login')) {
          Modular.to.navigate('/auth/login/');
        }
        return;
      }

      _logger.info(
        'Usuário logado: ${_authStore.userLogged?.nickname}, inicializando WebView...',
      );
      if (webViewController != null) {
        await _initializeWebView();
      }
    } catch (e, s) {
      _logger.error("Erro ao inicializar HomeController", e, s);
      Messages.warning('Erro ao inicializar a aplicação');
      if (!Modular.to.path.contains('/auth/login')) {
        await _authStore.logout();
        Modular.to.navigate('/auth/login/');
      }
    }
  }

  Future<void> _initializeWebView() async {
    try {
      await _loadInitialChannel();
      await loadSchedules();
      await startPollingForUpdates();
      await startCheckingScores();
    } catch (e, s) {
      _logger.error("Erro ao inicializar WebView", e, s);
      Messages.warning('Erro ao inicializar WebView');

      // Se o erro for de autenticação, faz logout e redireciona
      if (e.toString().contains('Expire token') ||
          e.toString().contains('authentication') ||
          e.toString().contains('autenticação')) {
        if (!Modular.to.path.contains('/auth/login')) {
          await _authStore.logout();
          Modular.to.navigate('/auth/login/');
        }
      }
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
  Future<void> initializeWebView(WebViewController controller) async {
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
      if (correctUrl == null) {
        throw Failure(message: 'Nenhuma URL encontrada para o canal inicial.');
      }

      await webViewController!.loadRequest(Uri.parse(correctUrl));
      _logger.info('Canal inicial carregado com sucesso: $correctUrl');
    } catch (e, s) {
      _logger.error('Erro ao carregar canal inicial.', e, s);
      throw Failure(message: 'Erro ao carregar o canal inicial.');
    }
  }

  @action
  Future<void> onWebViewCreated(WebViewController controller) async {
    _logger.info('WebView criado, configurando controller...');
    try {
      // Primeiro verifica se o usuário ainda está logado
      if (_authStore.userLogged == null) {
        throw Failure(message: 'Usuário não está autenticado');
      }

      webViewController = controller;
      isWebViewInitialized = true;

      await _loadInitialChannelWithRetry();

      try {
        await loadSchedules();
        await startPollingForUpdates();
        await startCheckingScores();
      } catch (e, s) {
        _logger.error('Erro ao carregar dados complementares', e, s);
      }
    } catch (e, s) {
      if (e is Failure) {
        _logger.error('Erro de negócio: ${e.message}', e, s);
      } else {
        _logger.error('Erro inesperado: $e', e, s);
      }
      _hideLoader();
      _logger.error('Erro durante inicialização do WebView', e, s);

      // Se for erro de autenticação, redireciona para login
      if (e.toString().contains('autenticação') ||
          e.toString().contains('Expire token')) {
        if (!Modular.to.path.contains('/auth/login')) {
          await _authStore.logout();
          Modular.to.navigate('/auth/login/');
        }
      } else {
        Messages.warning('Erro na inicialização.');
      }
    }
  }

  Future<void> _loadInitialChannelWithRetry() async {
    const maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        _logger.info(
          'Tentativa ${attempts + 1} de $maxAttempts para carregar canal inicial.',
        );
        await _loadInitialChannel();
        return;
      } catch (e, s) {
        attempts++;
        if (attempts >= maxAttempts) {
          _logger.error(
            'Erro ao carregar canal inicial após $attempts tentativas.',
            e,
            s,
          );
          throw Failure(message: 'Não foi possível carregar o canal inicial.');
        }

        _logger.warning(
          'Falha na tentativa ${attempts + 1}, tentando novamente...',
        );
        await Future.delayed(const Duration(seconds: 1));
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
        await webViewController!.loadRequest(
          Uri.parse(currentChannel!),
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
        1,
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

  @action
  Future<void> reloadWebView() async {
    _logger.info('Recarregando página...');
    try {
      _showLoader();

      if (webViewController == null) {
        throw Failure(message: 'WebViewController não inicializado');
      }

      await webViewController!.reload();

      // Após recarregar, verifica se está na URL correta
      await _loadInitialChannel();

      _hideLoader();
      _logger.info('Página recarregada com sucesso');
    } catch (e, s) {
      _hideLoader();
      _logger.error('Erro ao recarregar página', e, s);
      Messages.warning('Erro ao atualizar a página');
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
