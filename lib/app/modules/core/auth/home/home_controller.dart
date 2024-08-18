import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:webview_windows/webview_windows.dart';
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

  final webViewController = WebviewController();
  bool isWebViewInitialized = false;

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
  Future<void> initializeWebView() async {
    if (!isWebViewInitialized) {
      try {
        await webViewController.initialize();
        await webViewController.setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, como Gecko) Chrome/91.0.4472.124 Safari/537.36',
        );
        await _loadInitialChannel();

        isWebViewInitialized = true;
      } catch (e, s) {
        _logger.error('Error initializing webview', e, s);
        Messages.warning('Erro ao inicializar o WebView');
      }
    }
  }

  @action
  Future<void> _loadInitialChannel() async {
    try {
      final correctUrl = await _homeService.fetchCurrentChannel();
      await webViewController.loadUrl(correctUrl ?? '$correctUrl');
    } catch (e, s) {
      _logger.error('Error loading initial channel URL', e, s);
      Messages.warning('Erro ao carregar o canal inicial');
      throw Failure(message: 'Erro ao carregar o canal inicial');
    }
  }

  @action
  Future<void> loadCurrentChannel() async {
    try {
      final newChannel = await _homeService.fetchCurrentChannel();
      if (newChannel != null && isWebViewInitialized) {
        currentChannel = newChannel;
        await webViewController.loadUrl(newChannel);
        _logger.info('Current Channel: $newChannel');
      } else {
        // Canal padrão se não houver um canal agendado no momento
        const defaultChannel = 'https://twitch.tv/BoostTeam_';
        currentChannel = defaultChannel;
        if (isWebViewInitialized) {
          await webViewController.loadUrl(defaultChannel);
          _logger.warning(
            'Nenhum canal ao vivo no momento, carregando canal padrão: $defaultChannel',
          );
        } else {
          _logger.warning(
            'Nenhum canal ao vivo no momento e WebView não inicializada',
          );
        }
      }
    } catch (e, s) {
      _logger.error('Error loading current channel URL', e, s);
      Messages.warning('Erro ao carregar o canal atual');
      throw Failure(message: 'Erro ao carregar o canal atual');
    }
  }

  @action
  Future<void> startPollingForUpdates() async {
    const pollingInterval = Duration(seconds: 10);

    while (true) {
      await Future.delayed(pollingInterval);

      // Chame o método que verifica o canal atual
      await loadCurrentChannel();
    }
  }

  @action
  Future<void> forceUpdateLive() async {
    try {
      await _homeService.forceUpdateLive();
      await loadCurrentChannel();
    } catch (e, s) {
      _logger.error('Error on force update', e, s);
      throw Failure(message: 'Erro ao forçar a atualização da live');
    }
  }

  @action
  void onInit() {
    if (_authStore.userLogged == null ||
        _authStore.userLogged!.nickname.isEmpty) {
      Modular.to.navigate('/auth/login/');
    } else {
      initializationFuture = initializeWebView();
      loadSchedules();
      startPollingForUpdates();
    }
  }
}
