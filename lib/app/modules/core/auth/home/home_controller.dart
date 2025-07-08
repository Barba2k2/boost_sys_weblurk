import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/ui/widgets/loader.dart';
import '../../../../core/ui/widgets/messages.dart';
import '../../../../models/schedule_model.dart';
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
  bool _servicesInitialized = false;

  @observable
  bool isWebViewHealthy = true;

  @observable
  bool isScheduleVisible = false;

  @observable
  String initialChannel = 'https://twitch.tv/BoostTeam_';

  @observable
  bool isRecovering = false;

  @observable
  int currentTabIndex = 0;

  @observable
  String? currentChannelListA;

  @observable
  String? currentChannelListB;

  @observable
  bool isLoadingLists = false;

  @observable
  List<ScheduleModel> listaASchedules = [];

  @observable
  List<ScheduleModel> listaBSchedules = [];

  @computed
  String? get currentChannel {
    return currentTabIndex == 0 ? currentChannelListA : currentChannelListB;
  }

  @computed
  List<ScheduleModel> get currentListSchedules {
    final schedules = currentTabIndex == 0 ? listaASchedules : listaBSchedules;
    final listName = currentTabIndex == 0 ? 'Lista A' : 'Lista B';
    _logger.info(
        'Retornando ${schedules.length} agendamentos da $listName (aba $currentTabIndex)');
    return schedules;
  }

  void _subscribeToHealthEvents() {
    _webViewHealthSubscription =
        _webViewService.healthStatus.listen((isHealthy) {
      isWebViewHealthy = isHealthy;
      if (!isHealthy && !_recoveryInProgress) {
        _logger.warning(
          'Problema de saúde do WebView detectado, iniciando recuperação...',
        );
        _recoverWebView();
      }
    });

    _pollingHealthSubscription =
        _pollingService.healthStatus.listen((isHealthy) {
      if (!isHealthy) {
        _logger.warning('Problema de saúde do Polling detectado');
        _ensurePollingActive();
      }
    });

    // Subscribe to channel updates from polling service
    _channelUpdateSubscription =
        _pollingService.channelUpdates.listen((channelUrl) {
      _handleChannelUpdate(channelUrl);
    });
  }

  /// Inicializa o controlador da página principal.
  /// Configura monitoramento de saúde, carrega dados do usuário e inicializa serviços.
  @action
  Future<void> onInit() async {
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

  /// Alterna entre as abas Lista A e Lista B.
  /// @param index Índice da aba (0 = Lista A, 1 = Lista B)
  @action
  Future<void> switchTab(int index) async {
    if (index < 0 || index > 1) {
      _logger.warning('Índice de aba inválido: $index');
      return;
    }

    // Se já está na aba selecionada, não faz nada
    if (currentTabIndex == index) {
      _logger.info('Já está na aba $index, ignorando troca');
      return;
    }

    final previousTab = currentTabIndex;
    currentTabIndex = index;

    final tabName = index == 0 ? 'Lista A' : 'Lista B';
    _logger.info('=== INÍCIO TROCA DE ABA ===');
    _logger.info('Trocando de aba $previousTab para $index ($tabName)');
    _logger.info(
        'Estado atual - Lista A: ${listaASchedules.length} agendamentos, Lista B: ${listaBSchedules.length} agendamentos');

    try {
      // Carrega a lista específica da aba selecionada se não foi carregada ainda
      if (index == 0 && listaASchedules.isEmpty) {
        _logger.info('Iniciando carregamento da Lista A...');
        await loadListaA();
        _logger.info(
            'Lista A carregada. Agora tem ${listaASchedules.length} agendamentos');
      } else if (index == 1 && listaBSchedules.isEmpty) {
        _logger.info('Iniciando carregamento da Lista B...');
        await loadListaB();
        _logger.info(
            'Lista B carregada. Agora tem ${listaBSchedules.length} agendamentos');
      }

      _logger.info('=== FIM TROCA DE ABA ===');
    } catch (e, s) {
      _logger.error('Erro ao trocar para aba $index', e, s);
      // Em caso de erro, volta para a aba anterior
      currentTabIndex = previousTab;
      _logger.error('Voltando para aba anterior: $previousTab');
    }
  }

  /// Configura monitoramento periódico da saúde do WebView.
  /// Verifica a cada 2 minutos se o WebView está responsivo.
  void _setupWebViewMonitoring() {
    _webViewHealthTimer?.cancel();
    _webViewHealthTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (!_isDisposed) {
        _checkWebViewHealth();
      }
    });
  }

  /// Verifica se o WebView está saudável e responsivo.
  /// Se não estiver, tenta recuperar automaticamente.
  Future<void> _checkWebViewHealth() async {
    try {
      if (!_webViewService.isInitialized ||
          _webViewService.controller == null) {
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

  /// Tenta recuperar o WebView quando há problemas de saúde.
  /// Para o polling, recarrega o WebView e reinicia o polling.
  @action
  Future<void> _recoverWebView() async {
    // Evita múltiplas recuperações simultâneas
    if (_recoveryInProgress) {
      // _logger.info('Recuperação já em andamento, ignorando...');
      return;
    }

    try {
      _recoveryInProgress = true;
      isRecovering = true;
      // _logger.info('Tentando recuperar WebView...');

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
        _logger.warning(
          'Reload não resolveu o problema, notificando usuário...',
        );
        Messages.warning(
          'Problema detectado no navegador. Tente reiniciar o aplicativo se o problema persistir.',
        );
      }

      // Reinicia o polling
      await _ensurePollingActive();

      // _logger.info('WebView recuperado com sucesso');
      isWebViewHealthy = true;
    } catch (e, s) {
      _logger.error('Falha ao recuperar WebView', e, s);
      Messages.warning(
        'Erro ao recuperar aplicação. Tente reiniciar o programa.',
      );
      isWebViewHealthy = false;
    } finally {
      isRecovering = false;
      _recoveryInProgress = false;
    }
  }

  /// Garante que o polling esteja ativo com o streamer atual.
  /// Obtém o ID do streamer do usuário logado e inicia o polling.
  Future<void> _ensurePollingActive() async {
    final streamerId = _getCurrentStreamerId();
    if (streamerId > 0) {
      // _logger.info('Reiniciando polling com streamerId: $streamerId');
      await _pollingService.startPolling(streamerId);
    } else {
      _logger.warning('Não foi possível obter ID válido para polling');
    }
  }

  /// Inicializa todos os serviços necessários para o funcionamento do app.
  /// Carrega canais iniciais, agendamentos e inicia o polling.
  Future<void> _initializeServices() async {
    try {
      Loader.showLoadingChannel();
      await loadInitialChannels();
      Loader.hide();

      Loader.showLoadingSchedules();
      // Carrega ambas as listas inicialmente
      await loadListaA();
      await loadListaB();
      await _homeService.fetchSchedules();
      Loader.hide();

      await _ensurePollingActive();
    } catch (e, s) {
      Loader.hide();
      _logger.error('Error initializing services', e, s);
      Messages.scheduleLoadError();
      rethrow;
    }
  }

  /// Carrega os canais iniciais para ambas as abas.
  @action
  Future<void> loadInitialChannels() async {
    try {
      _logger.info('=== CARREGANDO CANAIS INICIAIS ===');

      // Carrega canal da Lista A
      final channelA = await _homeService.fetchCurrentChannelForList('Lista A');
      currentChannelListA = channelA;
      _logger.info('Canal inicial da Lista A: $channelA');

      // Carrega canal da Lista B
      final channelB = await _homeService.fetchCurrentChannelForList('Lista B');
      currentChannelListB = channelB;
      _logger.info('Canal inicial da Lista B: $channelB');

      _logger.info('=== CANAIS INICIAIS CARREGADOS ===');
    } catch (e, s) {
      _logger.error('Error loading initial channels', e, s);
      Messages.webViewError();
      rethrow;
    }
  }

  /// Carrega especificamente a Lista A.
  @action
  Future<void> loadListaA() async {
    try {
      _logger.info('=== INÍCIO LOAD LISTA A ===');
      _logger.info('Estado antes: ${listaASchedules.length} agendamentos');

      final scheduleList =
          await _homeService.fetchScheduleListByName('Lista A');
      listaASchedules = scheduleList?.schedules ?? [];

      _logger
          .info('Lista A carregada com ${listaASchedules.length} agendamentos');
      _logger.info('=== FIM LOAD LISTA A ===');
    } catch (e, s) {
      _logger.error('Error loading Lista A', e, s);
      rethrow;
    }
  }

  /// Carrega especificamente a Lista B.
  @action
  Future<void> loadListaB() async {
    try {
      _logger.info('=== INÍCIO LOAD LISTA B ===');
      _logger.info('Estado antes: ${listaBSchedules.length} agendamentos');

      final scheduleList =
          await _homeService.fetchScheduleListByName('Lista B');
      listaBSchedules = scheduleList?.schedules ?? [];

      _logger
          .info('Lista B carregada com ${listaBSchedules.length} agendamentos');
      _logger.info('=== FIM LOAD LISTA B ===');
    } catch (e, s) {
      _logger.error('Error loading Lista B', e, s);
      rethrow;
    }
  }

  /// Configura o WebView quando ele é criado.
  /// Inicializa o WebView e os serviços necessários.
  /// @param controller Controlador do WebView
  @action
  Future<void> onWebViewCreated(WebviewController controller) async {
    try {
      if (_authStore.userLogged == null) {
        throw Failure(message: 'Usuário não está autenticado');
      }

      await _webViewService.initializeWebView(controller);

      // Só inicializa os serviços uma vez (no primeiro WebView criado)
      if (!_servicesInitialized) {
        _servicesInitialized = true;
        await _initializeServices();
      }
    } catch (e, s) {
      _logger.error('Erro durante inicialização do WebView', e, s);
      await _handleError(e, s);
    }
  }

  /// Carrega o canal atual baseado na aba selecionada.
  /// Sempre busca o canal atual da API. Os WebViews se atualizam automaticamente.
  @action
  Future<void> loadCurrentChannel() async {
    try {
      final listName = currentTabIndex == 0 ? 'Lista A' : 'Lista B';
      _logger.info('=== INÍCIO LOAD CURRENT CHANNEL ===');
      _logger.info('Carregando canal para $listName (aba $currentTabIndex)');

      // Busca o canal atual da API baseado na lista atual
      final newChannel =
          await _homeService.fetchCurrentChannelForList(listName);

      // Atualiza o canal atual
      if (currentTabIndex == 0) {
        final oldChannel = currentChannelListA;
        currentChannelListA = newChannel;
        _logger.info('Canal da Lista A atualizado: $oldChannel → $newChannel');
      } else {
        final oldChannel = currentChannelListB;
        currentChannelListB = newChannel;
        _logger.info('Canal da Lista B atualizado: $oldChannel → $newChannel');
      }

      // Os WebViews se atualizam automaticamente via didUpdateWidget
      _logger.info(
          'Canal atual final: $currentChannel - WebViews se atualizarão automaticamente');
      _logger.info('=== FIM LOAD CURRENT CHANNEL ===');
    } catch (e, s) {
      _logger.error('Error loading current channel', e, s);
      Messages.webViewError();
      rethrow;
    }
  }

  /// Obtém o ID do streamer atual do usuário logado.
  /// @return ID do streamer ou 0 se não for possível obter
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

      // _logger.info('Streamer ID obtido com sucesso: $streamerId');
      return streamerId;
    } catch (e, s) {
      _logger.error('Erro ao obter ID do streamer', e, s);
      return 0;
    }
  }

  /// Recarrega o WebView ativo.
  /// Mostra loader durante o processo e trata erros adequadamente.
  @action
  Future<void> reloadWebView() async {
    try {
      Loader.showReloading();

      // Como agora temos WebViews independentes, cada um gerencia seu próprio reload
      // O serviço ainda mantém referência ao último WebView inicializado
      if (_webViewService.isInitialized) {
        await _webViewService.reload();
      }

      Loader.hide();
      _logger.info('WebView recarregado com sucesso');
    } catch (e, s) {
      Loader.hide();
      _logger.error('Erro ao recarregar WebView', e, s);
      Messages.webViewError();
    }
  }

  /// Redireciona para a tela de login quando o usuário não está logado.
  Future<void> _handleNotLoggedIn() async {
    if (!Modular.to.path.contains('/auth/login')) {
      Modular.to.navigate('/auth/login/');
    }
  }

  /// Trata erros gerais do controlador.
  /// Se for erro de autenticação, faz logout e redireciona para login.
  /// @param error Erro ocorrido
  /// @param stackTrace Stack trace do erro
  Future<void> _handleError(Object error, StackTrace stackTrace) async {
    _logger.error('Error in HomeController', error, stackTrace);

    if (error.toString().contains('autenticação') ||
        error.toString().contains('Expire token')) {
      await _authStore.logout();
      Messages.authenticationError();
      if (!Modular.to.path.contains('/auth/login')) {
        Modular.to.navigate('/auth/login/');
      }
    } else {
      Messages.serverError();
    }
  }

  /// Processa atualizações de canal recebidas do serviço de polling.
  /// Atualiza o canal da lista correspondente (A ou B).
  /// @param channelUrl Nova URL do canal
  @action
  Future<void> _handleChannelUpdate(String channelUrl) async {
    try {
      final listName = currentTabIndex == 0 ? 'Lista A' : 'Lista B';
      _logger.info(
          'Polling atualizando canal da $listName (aba $currentTabIndex): $channelUrl');

      // Update the current channel based on current tab
      if (currentTabIndex == 0) {
        currentChannelListA = channelUrl;
        _logger.info('Canal da Lista A atualizado via polling: $channelUrl');
      } else {
        currentChannelListB = channelUrl;
        _logger.info('Canal da Lista B atualizado via polling: $channelUrl');
      }

      // Com IndexedStack, cada WebView mantém seu próprio estado
      // Não carregamos a URL automaticamente para evitar conflitos
      _logger.info(
          'Canal atualizado. WebViews independentes manterão seus próprios estados.');
    } catch (e, s) {
      _logger.error('Erro ao processar atualização de canal', e, s);
    }
  }

  /// Limpa recursos e cancela timers/subscriptions quando o controlador é descartado.
  void dispose() {
    _isDisposed = true;
    _webViewHealthTimer?.cancel();
    _webViewHealthSubscription.cancel();
    _pollingHealthSubscription.cancel();
    _channelUpdateSubscription.cancel();
    _pollingService.stopPolling();
    _webViewService.dispose();
  }
}
