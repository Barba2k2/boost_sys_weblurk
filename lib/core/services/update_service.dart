import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'navigation_service.dart';

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();
  final ShorebirdUpdater _updater = ShorebirdUpdater();

  Future<void> initialize() async {
    await checkForUpdate();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        log('App resumed: $msg');
        await checkForUpdate();
      }
      return null;
    });
  }

  Future<void> checkForUpdate() async {
    try {
      final status = await _updater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        _showUpdateDialog();
      } else {
        log('Nenhuma atualização disponível');
      }
    } catch (e) {
      debugPrint('Erro ao verificar atualização: $e');
    }
  }

  void _showUpdateDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Contexto não disponível para mostrar diálogo de atualização');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _UpdateDialog(
        onConfirm: () async {
          try {
            await _updater.update();
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            SystemNavigator.pop();
          } on UpdateException catch (e) {
            debugPrint('Erro ao atualizar: $e');
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          }
        },
        onCancel: () {
          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({
    required this.onConfirm,
    required this.onCancel,
  });
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova atualização'),
      content: const Text(
        'É necessário reiniciar o app para aplicar a atualização.',
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Mais tarde'),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Reiniciar agora'),
        ),
      ],
    );
  }
}
