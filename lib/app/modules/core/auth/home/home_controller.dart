import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
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

  final Completer<void> _webViewInitialized = Completer<void>();

  final webViewControllerCompleter = Completer<InAppWebViewController>();

  Timer? _pollingTimer;

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

  @action
  Future<void> _loadInitialChannel() async {
    try {
      final correctUrl = await _homeService.fetchCurrentChannel();
      if (correctUrl != null) {
        await webViewController!.loadUrl(
          urlRequest: URLRequest(url: WebUri(correctUrl)),
        );
      } else {
        throw Failure(message: 'URL não encontrada');
      }
    } catch (e, s) {
      _logger.error('Error loading initial channel URL', e, s);
      Messages.warning('Erro ao carregar o canal inicial');
      throw Failure(message: 'Erro ao carregar o canal inicial');
    }
  }

  void onWebViewCreated(InAppWebViewController controller) {
    if (!webViewControllerCompleter.isCompleted) {
      webViewControllerCompleter.complete(controller);
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
    const pollingInterval = Duration(minutes: 6);

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      try {
        await loadCurrentChannel();
      } catch (e, s) {
        _logger.error('Error while polling for live updates', e, s);
      }
    });
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
    const Duration interval = Duration(minutes: 6);
    while (true) {
      await Future.delayed(interval);
      await _saveScore();
    }
  }

  Future<void> _saveScore() async {
    try {
      final now = DateTime.now();
      final hour = now.hour;
      final minute = now.minute;
      const points = 10;
      final streamerId = _getCurrentStreamerId();

      if (streamerId == 0) {
        _logger.warning('Invalid streamer ID. Aborting save score operation.');
        return;
      }

      await _homeService.saveScore(
        streamerId,
        DateTime(now.year, now.month, now.day),
        hour,
        minute,
        points,
      );
    } catch (e, s) {
      _logger.error('Error saving score', e, s);
      throw Failure(message: 'Erro ao salvar a pontuação');
    }
  }

  int _getCurrentStreamerId() {
    try {
      if (_authStore.userLogged == null) {
        _logger.warning('No user is currently logged in.');
        throw Failure(message: 'Nenhum usuário está logado.');
      }

      final streamerId =
          int.tryParse(_authStore.userLogged?.id.toString() ?? '0') ?? 0;

      if (streamerId > 0) {
        _logger.info('Streamer ID: $streamerId');
        return streamerId;
      } else {
        _logger.warning('Streamer ID not found.');
        return 0;
      }
    } catch (e, s) {
      _logger.error('Error getting current streamer ID', e, s);
      Messages.warning('Erro ao obter o ID do Streamer');
      throw Failure(message: 'Erro ao obter o ID do streamer');
    }
  }

  @action
  void onInit() {
    _logger.info('Iniciando HomeController...');
    if (_authStore.userLogged == null ||
        _authStore.userLogged!.nickname.isEmpty) {
      Modular.to.navigate('/auth/login/');
    } else {
      webViewControllerCompleter.future.then((controller) {
        initializeWebView(controller).then((_) {
          loadSchedules();
          startPollingForUpdates();
          startCheckingScores();
        }).catchError((error) {
          _logger.error('Falha na inicialização', error);
          Messages.warning('Erro na inicialização.');
        });
      });
    }
  }
}
