import 'package:flutter/foundation.dart';
import '../models/update_progress_model.dart';
import '../services/shorebird_update_service.dart';
import '../services/app_restart_service.dart';

class UpdateViewModel extends ChangeNotifier {
  final ShorebirdUpdateService _updateService;
  final AppRestartService _restartService;

  UpdateViewModel({
    required ShorebirdUpdateService updateService,
    required AppRestartService restartService,
  })  : _updateService = updateService,
        _restartService = restartService;

  // State
  UpdateInfoModel? _updateInfo;
  UpdateProgressModel _progress = UpdateProgressModel.initializing;
  bool _isCheckingForUpdates = false;
  bool _isDownloading = false;
  String? _errorMessage;

  // Getters
  UpdateInfoModel? get updateInfo => _updateInfo;
  UpdateProgressModel get progress => _progress;
  bool get isCheckingForUpdates => _isCheckingForUpdates;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;
  bool get hasUpdate => _updateInfo?.hasUpdate ?? false;
  bool get hasError => _errorMessage != null;

  /// Check if updates are available
  Future<void> checkForUpdates() async {
    _isCheckingForUpdates = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasUpdate = await _updateService.checkForUpdates();
      final currentPatch = await _updateService.getCurrentPatch();

      _updateInfo = UpdateInfoModel(
        hasUpdate: hasUpdate,
        currentPatchNumber: currentPatch,
        lastChecked: DateTime.now(),
      );

      debugPrint('✅ Update check completed. Has update: $hasUpdate');
    } catch (e) {
      _errorMessage = 'Erro ao verificar atualizações: $e';
      debugPrint('❌ Error checking for updates: $e');
    } finally {
      _isCheckingForUpdates = false;
      notifyListeners();
    }
  }

  /// Download and install update with progress tracking
  Future<void> downloadAndInstallUpdate() async {
    if (_isDownloading) return;

    _isDownloading = true;
    _errorMessage = null;
    _progress = UpdateProgressModel.initializing;
    notifyListeners();

    try {
      await _performUpdateWithProgress();
      debugPrint('✅ Update completed successfully');
    } catch (e) {
      _errorMessage = 'Erro durante a atualização: $e';
      _progress = _progress.copyWith(stage: UpdateStage.error);
      debugPrint('❌ Error during update: $e');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Restart the application
  void restartApp() {
    _restartService.restart();
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset progress state
  void resetProgress() {
    _progress = UpdateProgressModel.initializing;
    _isDownloading = false;
    notifyListeners();
  }

  /// Private method to handle update progress stages
  Future<void> _performUpdateWithProgress() async {
    // Stage 1: Checking for updates
    _progress = UpdateProgressModel.checking;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));

    // Stage 2: Downloading with progress
    _progress = UpdateProgressModel.downloading;
    notifyListeners();

    // Simulate download progress
    for (int i = 0; i <= 100; i += 10) {
      if (!_isDownloading) return; // Allow cancellation

      _progress = UpdateProgressModel.downloading.copyWith(value: i / 100);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Stage 3: Installing
    _progress = UpdateProgressModel.installing;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    // Stage 4: Finalizing
    _progress = UpdateProgressModel.finalizing;
    notifyListeners();

    // Actually perform the update
    await _updateService.downloadUpdate();

    // Stage 5: Complete
    _progress = UpdateProgressModel.complete;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}