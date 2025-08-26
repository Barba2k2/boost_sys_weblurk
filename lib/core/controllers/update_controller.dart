import 'package:flutter/material.dart';
import '../models/update_progress_model.dart';
import '../viewmodels/update_viewmodel.dart';
import '../services/shorebird_update_service.dart';
import '../services/app_restart_service.dart';
import '../ui/dialogs/update_dialogs.dart';

/// Controller that coordinates update flow between UI and business logic
/// Following MVVM pattern: View -> Controller -> ViewModel -> Model/Service
class UpdateController {
  late final UpdateViewModel _viewModel;

  UpdateController() {
    _viewModel = UpdateViewModel(
      updateService: ShorebirdUpdateService(),
      restartService: AppRestartService(),
    );
  }

  /// Check for updates and show dialog if available
  Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    if (_viewModel.updateInfo?.hasUpdate != true) {
      await _viewModel.checkForUpdates();
    }

    if (!context.mounted) return;

    if (_viewModel.hasUpdate) {
      await _showUpdateAvailableDialog(context);
    } else if (_viewModel.hasError) {
      await UpdateDialogs.showErrorDialog(
        context,
        title: 'Erro na Verificação',
        message: 'Não foi possível verificar atualizações.',
        technicalDetails: _viewModel.errorMessage,
      );
    }
  }

  /// Show update available dialog and handle user choice
  Future<void> _showUpdateAvailableDialog(BuildContext context) async {
    final shouldUpdate = await UpdateDialogs.showUpdateAvailableDialog(context);
    
    if (shouldUpdate == true && context.mounted) {
      await _performUpdate(context);
    }
  }

  /// Perform the update with progress tracking
  Future<void> _performUpdate(BuildContext context) async {
    // Create a ValueNotifier to track progress
    final progressNotifier = ValueNotifier<UpdateProgressModel>(
      UpdateProgressModel.initializing,
    );

    // Show progress dialog
    UpdateDialogs.showDownloadProgressDialog(
      context,
      progressNotifier,
    );

    // Listen to ViewModel progress changes
    void progressListener() {
      progressNotifier.value = _viewModel.progress;
    }

    _viewModel.addListener(progressListener);

    try {
      // Start the update process
      await _viewModel.downloadAndInstallUpdate();

      // Close progress dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show restart dialog on success
      if (!_viewModel.hasError && context.mounted) {
        await _showRestartDialog(context);
      } else if (_viewModel.hasError && context.mounted) {
        await UpdateDialogs.showErrorDialog(
          context,
          title: 'Erro na Atualização',
          message: 'Não foi possível completar a atualização.',
          technicalDetails: _viewModel.errorMessage,
        );
      }
    } finally {
      _viewModel.removeListener(progressListener);
      progressNotifier.dispose();
    }
  }

  /// Show restart confirmation dialog
  Future<void> _showRestartDialog(BuildContext context) async {
    final restartService = AppRestartService();
    
    await UpdateDialogs.showRestartDialog(
      context,
      restartMessage: restartService.restartMessage,
      onRestart: () => _viewModel.restartApp(),
    );
  }

  /// Manual check for updates (for user-initiated checks)
  Future<void> manualCheckForUpdates(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _viewModel.checkForUpdates();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (_viewModel.hasUpdate && context.mounted) {
        await _showUpdateAvailableDialog(context);
      } else if (!_viewModel.hasUpdate && context.mounted) {
        // Show "no updates" message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma atualização disponível.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        await UpdateDialogs.showErrorDialog(
          context,
          title: 'Erro na Verificação',
          message: 'Não foi possível verificar atualizações.',
          technicalDetails: e.toString(),
        );
      }
    }
  }

  /// Get current update info
  UpdateInfoModel? get updateInfo => _viewModel.updateInfo;

  /// Check if update is in progress
  bool get isUpdating => _viewModel.isDownloading;

  /// Check if has available update
  bool get hasUpdate => _viewModel.hasUpdate;

  /// Dispose resources
  void dispose() {
    _viewModel.dispose();
  }
}