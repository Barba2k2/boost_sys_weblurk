import 'package:flutter/foundation.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/home_repository.dart';
import 'package:result_dart/result_dart.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required HomeRepository repository})
      : _repository = repository {
    loadSchedules = Command0<List<ScheduleListEntity>>(_loadSchedules);
    startPolling = Command1<void, int>(_startPolling);
    stopPolling = Command0<void>(_stopPolling);
    reloadWebView = Command0<void>(_reloadWebView);
    loadUrl = Command1<void, String>(_loadUrl);
    initializeHome = Command0<void>(_initializeHome);
  }

  final HomeRepository _repository;

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

  Future<Result<List<ScheduleListEntity>, Exception>> _loadSchedules() async {
    return await _repository.fetchScheduleLists();
  }

  Future<Result<void, Exception>> _startPolling(int streamerId) async {
    return await _repository.startPolling(streamerId);
  }

  Future<Result<void, Exception>> _stopPolling() async {
    return await _repository.stopPolling();
  }

  Future<Result<void, Exception>> _reloadWebView() async {
    return await _repository.reloadWebView();
  }

  Future<Result<void, Exception>> _loadUrl(String url) async {
    return await _repository.loadUrl(url);
  }

  Future<Result<void, Exception>> _initializeHome() async {
    _setInitializing(true);
    try {
      final channelResult = await _repository.fetchCurrentChannel();
      final schedulesResult = await _repository.fetchScheduleLists();
      if (channelResult.isSuccess()) {
        final channel = channelResult.getOrNull();
        _setCurrentChannel(channel);
        _setInitialUrl(channel ?? 'https://www.twitch.tv/BootTeam_');
      } else {
        _setInitialUrl('https://www.twitch.tv/BootTeam_');
      }
      _startPolling(0);
      return Success(null);
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
}
