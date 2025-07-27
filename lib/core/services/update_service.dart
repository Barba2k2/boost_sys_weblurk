import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'navigation_service.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  bool _isChecking = false;
  bool _hasShownDialog = false;

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));

    await checkForUpdateOnStartup();

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        log('App resumed: verificando atualizações...');
        await checkForUpdateOnResume();
      }
      return null;
    });
  }

  Future<void> checkForUpdateOnStartup() async {
    if (_isChecking || _hasShownDialog) return;

    _isChecking = true;
    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        _showUpdateDialog(
          title: 'Nova Atualização Disponível',
          message:
              'Uma nova versão do aplicativo está disponível. Deseja atualizar agora?',
          isStartup: true,
        );
      }
    } catch (e) {
      log('Erro ao verificar atualização no startup: $e');
    } finally {
      _isChecking = false;
    }
  }

  Future<void> checkForUpdateOnResume() async {
    if (_isChecking || _hasShownDialog) return;

    _isChecking = true;
    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        _showUpdateDialog(
          title: 'Atualização Disponível',
          message: 'Uma nova versão foi encontrada. Deseja atualizar agora?',
          isStartup: false,
        );
      }
    } catch (e) {
      log('Erro ao verificar atualização no resume: $e');
    } finally {
      _isChecking = false;
    }
  }

  Future<void> checkForUpdateManually() async {
    if (_isChecking) return;

    _isChecking = true;
    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        _showUpdateDialog(
          title: 'Atualização Disponível',
          message: 'Uma nova versão foi encontrada. Deseja atualizar agora?',
          isStartup: false,
        );
      } else {
        _showNoUpdateDialog();
      }
    } catch (e) {
      log('Erro na verificação manual: $e');
      _showErrorDialog();
    } finally {
      _isChecking = false;
    }
  }

  void _showUpdateDialog({
    required String title,
    required String message,
    required bool isStartup,
  }) {
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      _hasShownDialog = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: isStartup ? false : true,
      builder: (dialogContext) => _UpdateDialog(
        title: title,
        message: message,
        isStartup: isStartup,
        onConfirm: () async {
          try {
            await _updater.update();
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            SystemNavigator.pop();
          } on UpdateException {
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
              _showErrorDialog();
            }
          } finally {
            _hasShownDialog = false;
          }
        },
        onCancel: () {
          Navigator.pop(dialogContext);
          _hasShownDialog = false;
        },
      ),
    );
  }

  void _showNoUpdateDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atualização'),
        content: const Text('Seu aplicativo está atualizado!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erro na Atualização'),
        content: const Text(
          'Não foi possível verificar ou aplicar a atualização. Tente novamente mais tarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void resetState() {
    _hasShownDialog = false;
    _isChecking = false;
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({
    required this.title,
    required this.message,
    required this.isStartup,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String message;
  final bool isStartup;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O aplicativo será reiniciado automaticamente após a atualização.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!isStartup)
          TextButton(
            onPressed: onCancel,
            child: const Text('Mais tarde'),
          ),
        ElevatedButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.download),
          label: const Text('Atualizar agora'),
        ),
      ],
    );
  }
}
