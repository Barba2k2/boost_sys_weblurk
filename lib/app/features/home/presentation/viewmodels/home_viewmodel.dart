import 'package:flutter/foundation.dart';
import '../../../../utils/command.dart';
import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../../utils/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required HomeRepository repository})
      : _repository = repository {
    loadSchedules = Command0<List<ScheduleListEntity>>(_loadSchedules);
    startPolling = Command1<void, int>(_startPolling);
    stopPolling = Command0<void>(_stopPolling);
    reloadWebView = Command0<void>(_reloadWebView);
    loadUrl = Command1<void, String>(_loadUrl);
  }

  final HomeRepository _repository;

  late Command0<List<ScheduleListEntity>> loadSchedules;
  late Command1<void, int> startPolling;
  late Command0<void> stopPolling;
  late Command0<void> reloadWebView;
  late Command1<void, String> loadUrl;

  String? _currentChannel;
  bool _isInitializing = false;

  String? get currentChannel => _currentChannel;
  bool get isInitializing => _isInitializing;

  Future<Result<List<ScheduleListEntity>>> _loadSchedules() async {
    return await _repository.fetchScheduleLists();
  }

  Future<Result<void>> _startPolling(int streamerId) async {
    return await _repository.startPolling(streamerId);
  }

  Future<Result<void>> _stopPolling() async {
    return await _repository.stopPolling();
  }

  Future<Result<void>> _reloadWebView() async {
    return await _repository.reloadWebView();
  }

  Future<Result<void>> _loadUrl(String url) async {
    return await _repository.loadUrl(url);
  }

  void _setCurrentChannel(String? channel) {
    _currentChannel = channel;
    notifyListeners();
  }

  void _setInitializing(bool initializing) {
    _isInitializing = initializing;
    notifyListeners();
  }
}
