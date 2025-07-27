import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/services/volume_service.dart';
import '../../../../models/schedule_list_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';
import '../../../../service/home/home_service.dart';
import '../../../auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/services/webview_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required HomeService homeService,
    required AuthViewModel authViewmodel,
    required AppLogger logger,
    required WebViewService webViewService,
    required VolumeService volumeService,
  })  : _homeService = homeService,
        _authViewmodel = authViewmodel,
        _logger = logger,
        _webViewService = webViewService,
        _volumeService = volumeService {
    _authViewmodel.addListener(() => notifyListeners());

    _initializeChannels();

    _startMuteStateCheck();
  }

  final HomeService _homeService;
  final AuthViewModel _authViewmodel;
  final AppLogger _logger;
  final WebViewService _webViewService;
  final VolumeService _volumeService;

  Timer? _muteStateCheckTimer;

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

  void _initializeChannels() {
    _currentChannel = 'https://twitch.tv/BoostTeam_';
    _currentChannelListA = 'https://twitch.tv/BoostTeam_';
    _currentChannelListB = 'https://twitch.tv/BoostTeam_';
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
      }

      return Result.ok(null);
    } catch (e, s) {
      _logger.error('Erro ao atualizar canais', e, s);
      return Result.error(
        Exception('Erro ao atualizar canais: $e'),
      );
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
      final activeController = _currentTabIndex == 0 //
          ? _webviewControllerA
          : _webviewControllerB;

      if (activeController != null) {
        await activeController.reload();
      } else {
        _logger.warning('Nenhum controller ativo para recarregar');
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
      final schedules = await _homeService.fetchScheduleLists();
      _scheduleLists = schedules;

      await updateChannels();

      notifyListeners();
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

      _currentChannel = index == 0 //
          ? _currentChannelListA
          : _currentChannelListB;

      await _volumeService.syncMuteState();

      notifyListeners();

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

        await updateChannels();

        notifyListeners();
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

    _webviewControllerA?.dispose();
    _webviewControllerB?.dispose();
    super.dispose();
  }
}
