import 'package:flutter/foundation.dart';
import '../../../../core/result/result.dart';
import '../../../../utils/command.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required HomeRepository repository,
    required AuthState authState,
  })  : _repository = repository,
        _authState = authState {
    loadSchedules = Command0<List<ScheduleListEntity>>(_loadSchedules);
    startPolling = Command1<void, int>(_startPolling);
    stopPolling = Command0<void>(_stopPolling);
    reloadWebView = Command0<void>(_reloadWebView);
    loadUrl = Command1<void, String>(_loadUrl);
    initializeHome = Command0<void>(_initializeHome);

    // Escuta mudanças no AuthState para reiniciar o polling quando necessário
    _authState.addListener(_onAuthStateChanged);
  }

  final HomeRepository _repository;
  final AuthState _authState;

  late Command0<List<ScheduleListEntity>> loadSchedules;
  late Command1<void, int> startPolling;
  late Command0<void> stopPolling;
  late Command0<void> reloadWebView;
  late Command1<void, String> loadUrl;
  late Command0<void> initializeHome;

  String? _currentChannel;
  bool _isInitializing = false;
  String? _initialUrl;

  String? get currentChannel => _currentChannel;
  bool get isInitializing => _isInitializing;
  String? get initialUrl => _initialUrl;

  void _onAuthStateChanged() {
    // Se o usuário fez login, inicia o polling
    if (_authState.isLoggedIn) {
      _startPolling(0);
    } else {
      // Se o usuário fez logout, para o polling
      _stopPolling();
    }
  }

  Future<AppResult<List<ScheduleListEntity>>> _loadSchedules() async {
    return await _repository.fetchScheduleLists();
  }

  Future<AppResult<void>> _startPolling(int streamerId) async {
    return await _repository.startPolling(streamerId);
  }

  Future<AppResult<void>> _stopPolling() async {
    return await _repository.stopPolling();
  }

  Future<AppResult<void>> _reloadWebView() async {
    return await _repository.reloadWebView();
  }

  Future<AppResult<void>> _loadUrl(String url) async {
    return await _repository.loadUrl(url);
  }

  Future<AppResult<void>> _initializeHome() async {
    _setInitializing(true);
    try {
      final channelResult = await _repository.fetchCurrentChannel();
      await _repository.fetchScheduleLists();
      if (channelResult.isSuccess) {
        final channel = channelResult.data;
        _setCurrentChannel(channel);
        _setInitialUrl(channel ?? 'https://www.twitch.tv/BootTeam_');
      } else {
        _setInitialUrl('https://www.twitch.tv/BootTeam_');
      }

      // Só inicia o polling se o usuário estiver logado
      if (_authState.isLoggedIn) {
        _startPolling(0);
      }

      return AppSuccess(null);
    } finally {
      _setInitializing(false);
    }
  }

  void _setCurrentChannel(String? channel) {
    _currentChannel = channel;
    notifyListeners();
  }

  void _setInitializing(bool initializing) {
    _isInitializing = initializing;
    notifyListeners();
  }

  void _setInitialUrl(String? url) {
    _initialUrl = url;
    notifyListeners();
  }

  @override
  void dispose() {
    _authState.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
