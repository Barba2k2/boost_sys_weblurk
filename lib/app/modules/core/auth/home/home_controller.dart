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
  var currentChannel = 'BoostTeam_';

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
  Future<void> updateLists() async {
    try {
      await _homeService.forceUpdateLive();
    } catch (e, s) {
      _logger.error('Error on force update live', e, s);
      Messages.warning('Erro ao forçar a atualização da live');
      throw Failure(message: 'Erro ao forçar a atualização da live');
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
        final correctUrl = 'https://www.twitch.tv/currentChannel';
        await webViewController.loadUrl(correctUrl);

        isWebViewInitialized = true;
      } catch (e) {
        _logger.error('Error initializing webview', e);
        Messages.warning('Erro ao inicializar o WebView');
      }
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
    }
  }
}
