// lib/features/home/presentation/viewmodels/home_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../models/schedule_list_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';
import '../../../../service/home/home_service.dart';
import '../../../auth/login/presentation/viewmodels/auth_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required HomeService homeService,
    required AuthViewModel authViewmodel,
    required AppLogger logger,
  })  : _homeService = homeService,
        _authStore = authViewmodel,
        _logger = logger {
    // Escutar mudanças no AuthStore
    _authStore.addListener(() => notifyListeners());

    // Inicializar canais com valores padrão
    _initializeChannels();
  }

  final HomeService _homeService;
  final AuthViewModel _authStore;
  final AppLogger _logger;

  // Estado reativo do AuthStore
  UserModel? get userLogged => _authStore.userLogged;

  // Estado interno
  List<ScheduleListModel> _scheduleLists = [];
  List<ScheduleListModel> get scheduleLists => _scheduleLists;

  String _currentChannel = 'https://twitch.tv/BoostTeam_';
  String get currentChannel => _currentChannel;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  String _currentChannelListA = 'https://twitch.tv/BoostTeam_';
  String _currentChannelListB = 'https://twitch.tv/BoostTeam_';
  String get currentChannelListA => _currentChannelListA;
  String get currentChannelListB => _currentChannelListB;

  // ✅ CORREÇÃO: Armazenar referências dos controllers
  WebviewController? _webviewControllerA;
  WebviewController? _webviewControllerB;

  // Commands para operações
  late final loadSchedulesCommand =
      Command0<List<ScheduleListModel>>(_loadSchedules);
  late final switchTabCommand = Command1<void, int>(_switchTab);
  late final fetchCurrentChannelCommand =
      Command0<String>(_fetchCurrentChannel);
  late final updateChannelsCommand = Command0<void>(_updateChannels);
  late final reloadWebViewCommand = Command0<void>(_reloadWebView);

  void _initializeChannels() {
    _currentChannel = 'https://twitch.tv/BoostTeam_';
    _currentChannelListA = 'https://twitch.tv/BoostTeam_';
    _currentChannelListB = 'https://twitch.tv/BoostTeam_';
  }

  // ✅ CORREÇÃO: Método para registrar controllers dos WebViews
  void onWebViewCreated(WebviewController controller, String identifier) {
    try {
      _logger.info('WebView controller registrado para $identifier');

      if (identifier == 'listaA') {
        _webviewControllerA = controller;
      } else if (identifier == 'listaB') {
        _webviewControllerB = controller;
      }
    } catch (e, s) {
      _logger.error('Erro ao registrar WebView controller', e, s);
    }
  }

  // Método para integração com a HomePage
  Future<void> updateChannels() async {
    await updateChannelsCommand.execute();
  }

  Future<Result<void>> _updateChannels() async {
    try {
      final channelA = await _homeService.fetchCurrentChannelForList('Lista A');
      final channelB = await _homeService.fetchCurrentChannelForList('Lista B');

      final newChannelA = (channelA != null && channelA.isNotEmpty)
          ? channelA
          : 'https://twitch.tv/BoostTeam_';
      final newChannelB = (channelB != null && channelB.isNotEmpty)
          ? channelB
          : 'https://twitch.tv/BoostTeam_';

      bool shouldNotify = false;

      if (_currentChannelListA != newChannelA) {
        _currentChannelListA = newChannelA;
        shouldNotify = true;
        _logger.info('Canal da Lista A atualizado: $newChannelA');
      }

      if (_currentChannelListB != newChannelB) {
        _currentChannelListB = newChannelB;
        shouldNotify = true;
        _logger.info('Canal da Lista B atualizado: $newChannelB');
      }

      // Atualizar canal atual baseado na aba ativa
      final newCurrentChannel =
          _currentTabIndex == 0 ? newChannelA : newChannelB;
      if (_currentChannel != newCurrentChannel) {
        _currentChannel = newCurrentChannel;
        shouldNotify = true;
      }

      if (shouldNotify) {
        notifyListeners();
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao atualizar canais', e, s);
      return Result.error(Exception('Erro ao atualizar canais: $e'));
    }
  }

  void onInit() {
    updateChannels();
    fetchCurrentChannelCommand.execute();
  }

  void reloadWebView() {
    reloadWebViewCommand.execute();
  }

  Future<Result<void>> _reloadWebView() async {
    try {
      _logger.info('Recarregando WebView...');

      // ✅ CORREÇÃO: Recarregar o WebView da aba ativa
      final activeController =
          _currentTabIndex == 0 ? _webviewControllerA : _webviewControllerB;

      if (activeController != null) {
        await activeController.reload();
        _logger.info('WebView recarregado com sucesso');
      } else {
        _logger.warning('Nenhum controller ativo para recarregar');
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView', e, s);
      return Result.error(Exception('Erro ao recarregar WebView: $e'));
    }
  }

  bool get isRecovering => false; // Removido sistema de recuperação complexo

  // Método privado para carregar agendamentos
  Future<Result<List<ScheduleListModel>>> _loadSchedules() async {
    try {
      final schedules = await _homeService.fetchScheduleLists();
      _scheduleLists = schedules;

      // Após carregar os agendamentos, atualizar os canais
      await updateChannels();

      notifyListeners();
      return Result.ok(schedules);
    } catch (e, s) {
      _logger.error('Erro ao carregar agendamentos', e, s);
      return Result.error(Exception('Erro ao carregar agendamentos: $e'));
    }
  }

  // Método privado para trocar aba
  Future<Result<void>> _switchTab(int index) async {
    try {
      if (index < 0 || index > 1) {
        return Result.error(Exception('Índice de aba inválido: $index'));
      }

      if (_currentTabIndex == index) {
        return Result.ok(null);
      }

      final oldIndex = _currentTabIndex;
      _currentTabIndex = index;

      // Atualizar canal atual baseado na nova aba
      _currentChannel =
          index == 0 ? _currentChannelListA : _currentChannelListB;

      _logger.info('Aba alterada de $oldIndex para $index');

      notifyListeners();

      // Carregar agendamentos da aba se necessário
      if (_scheduleLists.isEmpty) {
        await loadSchedulesCommand.execute();
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao trocar aba', e, s);
      return Result.error(Exception('Erro ao trocar aba: $e'));
    }
  }

  // Método privado para buscar canal atual
  Future<Result<String>> _fetchCurrentChannel() async {
    try {
      final channel = await _homeService.fetchCurrentChannel();
      if (channel != null && channel.isNotEmpty) {
        _currentChannel = channel;

        // Atualizar também os canais específicos das listas
        await updateChannels();

        notifyListeners();
        return Result.ok(_currentChannel);
      } else {
        // Se não há canal ativo, usar o canal padrão
        _currentChannel = 'https://twitch.tv/BoostTeam_';
        notifyListeners();
        return Result.ok(_currentChannel);
      }
    } catch (e, s) {
      _logger.error('Erro ao buscar canal atual', e, s);
      // Em caso de erro, manter o canal atual
      return Result.error(Exception('Erro ao buscar canal atual: $e'));
    }
  }

  // Getters para dados da aba atual
  List<ScheduleModel> get currentListSchedules {
    if (_scheduleLists.isEmpty || _currentTabIndex >= _scheduleLists.length) {
      return [];
    }
    return _scheduleLists[_currentTabIndex].schedules;
  }

  String get currentListName {
    if (_scheduleLists.isEmpty || _currentTabIndex >= _scheduleLists.length) {
      return _currentTabIndex == 0 ? 'Lista A' : 'Lista B';
    }
    return _scheduleLists[_currentTabIndex].listName;
  }

  @override
  void dispose() {
    // Limpar controllers se necessário
    _webviewControllerA?.dispose();
    _webviewControllerB?.dispose();
    super.dispose();
  }
}
