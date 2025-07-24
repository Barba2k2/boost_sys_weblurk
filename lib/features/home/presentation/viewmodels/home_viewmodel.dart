import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_store.dart';
import '../../../../core/utils/command.dart';
import '../../../../core/utils/result.dart';
import '../../../../models/schedule_list_model.dart';
import '../../../../models/schedule_model.dart';
import '../../../../models/user_model.dart';
import '../../../../service/home/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required HomeService homeService,
    required AuthStore authStore,
  })  : _homeService = homeService,
        _authStore = authStore {
    // Escutar mudanças no AuthStore
    _authStore.addListener(() => notifyListeners());

    // Inicializar canais com valores padrão
    _initializeChannels();
  }

  final HomeService _homeService;
  final AuthStore _authStore;

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

  // Commands para operações
  late final loadSchedulesCommand =
      Command0<List<ScheduleListModel>>(_loadSchedules);
  late final switchTabCommand = Command1<void, int>(_switchTab);
  late final fetchCurrentChannelCommand =
      Command0<String>(_fetchCurrentChannel);
  late final updateChannelsCommand = Command0<void>(_updateChannels);

  void _initializeChannels() {
    // Inicializar com canais padrão
    _currentChannel = 'https://twitch.tv/BoostTeam_';
    _currentChannelListA = 'https://twitch.tv/BoostTeam_';
    _currentChannelListB = 'https://twitch.tv/BoostTeam_';
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
      }

      if (_currentChannelListB != newChannelB) {
        _currentChannelListB = newChannelB;
        shouldNotify = true;
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
    } catch (e) {
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
    updateChannels();
    fetchCurrentChannelCommand.execute();
  }

  bool get isRecovering => updateChannelsCommand.running;

  void onWebViewCreated(controller) {
    // Implementação real se necessário
  }

  // Método privado para carregar agendamentos
  Future<Result<List<ScheduleListModel>>> _loadSchedules() async {
    try {
      final schedules = await _homeService.fetchScheduleLists();
      _scheduleLists = schedules;

      // Após carregar os agendamentos, atualizar os canais
      await updateChannels();

      notifyListeners();
      return Result.ok(schedules);
    } catch (e) {
      return Result.error(
        Exception('Erro ao carregar agendamentos: $e'),
      );
    }
  }

  // Método privado para trocar aba
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

      // Atualizar canal atual baseado na nova aba
      _currentChannel = index == 0 //
          ? _currentChannelListA
          : _currentChannelListB;

      notifyListeners();

      // Carregar agendamentos da aba se necessário
      if (_scheduleLists.isEmpty) {
        await loadSchedulesCommand.execute();
      }

      return Result.ok(null);
    } catch (e) {
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
    } catch (e) {
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
}
