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

  // Commands para operações
  late final loadSchedulesCommand =
      Command0<List<ScheduleListModel>>(_loadSchedules);
  late final switchTabCommand = Command1<void, int>(_switchTab);
  late final fetchCurrentChannelCommand =
      Command0<String>(_fetchCurrentChannel);

  // Método privado para carregar agendamentos
  Future<Result<List<ScheduleListModel>>> _loadSchedules() async {
    try {
      final schedules = await _homeService.fetchScheduleLists();
      _scheduleLists = schedules;
      notifyListeners();
      return Result.ok(schedules);
    } catch (e) {
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

      _currentTabIndex = index;
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
