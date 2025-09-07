import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/services/volume_service.dart';
import '../../../../core/services/update_service.dart';
import '../../../../models/schedule_list_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';
import '../../../../service/home/home_service.dart';
import '../../../auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/services/webview_service.dart';
import '../../data/services/polling_services.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required HomeService homeService,
    required AuthViewModel authViewmodel,
    required AppLogger logger,
    required WebViewService webViewService,
    required VolumeService volumeService,
    required PollingService pollingService,
  })  : _homeService = homeService,
        _authViewmodel = authViewmodel,
        _logger = logger,
        _webViewService = webViewService,
        _volumeService = volumeService,
        _pollingService = pollingService {
    _authViewmodel.addListener(() => notifyListeners());

    _initializeChannels();
    _initializeCorrectChannel();
    _startPollingIfLoggedIn();

    _startMuteStateCheck();
  }

  final HomeService _homeService;
  final AuthViewModel _authViewmodel;
  final AppLogger _logger;
  final WebViewService _webViewService;
  final VolumeService _volumeService;
  final PollingService _pollingService;

  Timer? _muteStateCheckTimer;
  Timer? _debounceTimer;
  bool _isUpdatingChannels = false;

  UserModel? get userLogged => _authViewmodel.userLogged;

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

  WebviewController? _webviewControllerA;
  WebviewController? _webviewControllerB;

  late final loadSchedulesCommand =
      Command0<List<ScheduleListModel>>(_loadSchedules);
  late final switchTabCommand = Command1<void, int>(_switchTab);
  late final fetchCurrentChannelCommand =
      Command0<String>(_fetchCurrentChannel);
  late final updateChannelsCommand = Command0<void>(_updateChannels);
  late final reloadWebViewCommand = Command0<void>(_reloadWebView);
  late final checkUpdateCommand = Command0<void>(_checkUpdate);

  void _initializeChannels() {
    _currentChannel = 'https://twitch.tv/BoostTeam_';
    _currentChannelListA = 'https://twitch.tv/BoostTeam_';
    _currentChannelListB = 'https://twitch.tv/BoostTeam_';
  }

  void _startPollingIfLoggedIn() {
    if (_authViewmodel.userLogged != null) {
      _pollingService.startPolling(_authViewmodel.userLogged!.id);
    }
  }

  /// Debounce para evitar chamadas múltiplas simultâneas
  void _debounce(Function() callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), callback);
  }

  /// Verifica se já está atualizando canais para evitar chamadas simultâneas
  bool _canUpdateChannels() {
    if (_isUpdatingChannels) {
      return false;
    }
    return true;
  }

  Future<void> _initializeCorrectChannel() async {
    try {
      // Buscar canal atual imediatamente
      final correctChannel = await _homeService.fetchCurrentChannel();
      if (correctChannel != null && correctChannel.isNotEmpty) {
        _currentChannel = correctChannel;
      }

      // Buscar canais das listas
      final channelA = await _homeService.fetchCurrentChannelForList('Lista A');
      final channelB = await _homeService.fetchCurrentChannelForList('Lista B');

      if (channelA != null && channelA.isNotEmpty) {
        _currentChannelListA = channelA;
      }

      if (channelB != null && channelB.isNotEmpty) {
        _currentChannelListB = channelB;
      }

      // Atualizar canal atual baseado na aba ativa
      final newCurrentChannel =
          _currentTabIndex == 0 ? _currentChannelListA : _currentChannelListB;
      if (_currentChannel != newCurrentChannel) {
        _currentChannel = newCurrentChannel;
      }

      // Notificar imediatamente para atualizar a UI
      notifyListeners();

      // Aguardar um pouco e verificar novamente para garantir
      await Future.delayed(const Duration(milliseconds: 1000));
      await _updateChannels();

      // Forçar atualização do WebView se necessário
      if (_webviewControllerA != null || _webviewControllerB != null) {
        await _reloadWebView();
      }
    } catch (e, s) {
      _logger.error('Erro ao inicializar canais corretos', e, s);
    }
  }

  void onWebViewCreated(WebviewController controller, String identifier) {
    try {
      if (identifier == 'listaA') {
        _webviewControllerA = controller;
      } else if (identifier == 'listaB') {
        _webviewControllerB = controller;
      }

      _webViewService.setWebViewControllers(
        _webviewControllerA,
        _webviewControllerB,
      );
    } catch (e, s) {
      _logger.error('Erro ao registrar WebView controller', e, s);
    }
  }

  Future<void> updateChannels() async {
    if (!_canUpdateChannels()) return;

    _debounce(() async {
      await updateChannelsCommand.execute();
    });
  }

  Future<Result<void>> _updateChannels() async {
    if (!_canUpdateChannels()) {
      return Result.ok(null);
    }

    _isUpdatingChannels = true;
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
      }

      if (_currentChannelListB != newChannelB) {
        _currentChannelListB = newChannelB;
        shouldNotify = true;
      }

      final newCurrentChannel =
          _currentTabIndex == 0 ? newChannelA : newChannelB;
      if (_currentChannel != newCurrentChannel) {
        _currentChannel = newCurrentChannel;
        shouldNotify = true;
      }

      if (shouldNotify) {
        notifyListeners();

        // Forçar recarregamento do WebView se necessário
        if (_webviewControllerA != null || _webviewControllerB != null) {
          await _reloadWebView();
        }
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao atualizar canais', e, s);
      return Result.error(
        Exception('Erro ao atualizar canais: $e'),
      );
    } finally {
      _isUpdatingChannels = false;
    }
  }

  void onInit() {
    // O canal já foi inicializado no construtor, apenas atualizar se necessário
    updateChannels();
  }

  void reloadWebView() {
    reloadWebViewCommand.execute();
  }

  void checkUpdate() {
    checkUpdateCommand.execute();
  }

  Future<Result<void>> _checkUpdate() async {
    try {
      await UpdateService.instance.checkForUpdateManually();
      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao verificar atualização', e, s);
      return Result.error(
        Exception('Erro ao verificar atualização: $e'),
      );
    }
  }

  Future<Result<void>> _reloadWebView() async {
    try {
      final activeController = _currentTabIndex == 0 //
          ? _webviewControllerA
          : _webviewControllerB;

      if (activeController != null) {
        // Buscar canal atual da API primeiro
        final apiChannel = await _homeService.fetchCurrentChannel();
        final currentUrl = (apiChannel?.isNotEmpty == true
                ? apiChannel
                : (_currentTabIndex == 0
                    ? _currentChannelListA
                    : _currentChannelListB)) ??
            'https://twitch.tv/BoostTeam_';

        await activeController.loadUrl(currentUrl);
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao recarregar WebView', e, s);
      return Result.error(
        Exception('Erro ao recarregar WebView: $e'),
      );
    }
  }

  bool get isRecovering => false;

  Future<Result<List<ScheduleListModel>>> _loadSchedules() async {
    try {
      // Limpar cache e buscar dados atualizados
      await _homeService.updateLists();
      final schedules = await _homeService.fetchScheduleLists();
      _scheduleLists = schedules;

      // Usar debounce para atualizar canais
      _debounce(() async {
        await updateChannels();
      });

      notifyListeners();

      // Forçar atualização do WebView se necessário
      if (_webviewControllerA != null || _webviewControllerB != null) {
        await _reloadWebView();
      }

      return Result.ok(schedules);
    } catch (e, s) {
      _logger.error('Erro ao carregar agendamentos', e, s);
      return Result.error(
        Exception('Erro ao carregar agendamentos: $e'),
      );
    }
  }

  Future<Result<void>> _switchTab(int index) async {
    try {
      if (index < 0 || index > 1) {
        return Result.error(
          Exception('Índice de aba inválido: $index'),
        );
      }

      if (_currentTabIndex == index) {
        return Result.ok(null);
      }

      _currentTabIndex = index;

      final newChannel = index == 0 //
          ? _currentChannelListA
          : _currentChannelListB;
      _currentChannel = newChannel;

      await _volumeService.syncMuteState();

      notifyListeners();

      // Forçar atualização do WebView se necessário
      if (_webviewControllerA != null || _webviewControllerB != null) {
        await _reloadWebView();
      }

      if (_scheduleLists.isEmpty) {
        await loadSchedulesCommand.execute();
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao trocar aba', e, s);
      return Result.error(Exception('Erro ao trocar aba: $e'));
    }
  }

  Future<Result<String>> _fetchCurrentChannel() async {
    try {
      final channel = await _homeService.fetchCurrentChannel();

      if (channel != null && channel.isNotEmpty) {
        _currentChannel = channel;

        // Usar debounce para atualizar canais
        _debounce(() async {
          await updateChannels();
        });

        notifyListeners();

        // Forçar atualização do WebView se necessário
        if (_webviewControllerA != null || _webviewControllerB != null) {
          await _reloadWebView();
        }

        return Result.ok(_currentChannel);
      } else {
        _currentChannel = 'https://twitch.tv/BoostTeam_';
        notifyListeners();
        return Result.ok(_currentChannel);
      }
    } catch (e, s) {
      _logger.error('Erro ao buscar canal atual', e, s);
      return Result.error(
        Exception('Erro ao buscar canal atual: $e'),
      );
    }
  }

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

  void _startMuteStateCheck() {
    _muteStateCheckTimer?.cancel();
    _muteStateCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        try {
          await _volumeService.periodicMuteStateCheck();
        } catch (e, s) {
          _logger.error(
            'Erro na verificação periódica do estado de mute',
            e,
            s,
          );
        }
      },
    );
  }

  void _stopMuteStateCheck() {
    _muteStateCheckTimer?.cancel();
    _muteStateCheckTimer = null;
  }

  @override
  void dispose() {
    _stopMuteStateCheck();
    _debounceTimer?.cancel();
    _pollingService.stopPolling();

    _webviewControllerA?.dispose();
    _webviewControllerB?.dispose();
    super.dispose();
  }
}
