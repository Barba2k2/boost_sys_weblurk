import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'navigation_service.dart';

class UpdateService {
  static final UpdateService instance = UpdateService._();
  final _shorebird = ShorebirdCodePush();

  UpdateService._();

  Future<void> initialize() async {
    // Primeira verificação ao iniciar
    await checkForUpdate();

    // Configurar verificação quando voltar do background
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
      // Verifica se o Shorebird está disponível
      if (!_shorebird.isShorebirdAvailable()) {
        log('Shorebird não está disponível');
        return;
      }

      // Verifica se há nova atualização disponível para download
      final isUpdateAvailable =
          await _shorebird.isNewPatchAvailableForDownload();

      if (isUpdateAvailable) {
        // Baixa a atualização
        await _shorebird.downloadUpdateIfAvailable();

        // Verifica se a atualização está pronta para ser instalada
        final isReadyToInstall = await _shorebird.isNewPatchReadyToInstall();

        if (isReadyToInstall) {
          _showUpdateDialog();
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar atualização: $e');
    }
  }

  Future<String> _getVersionInfo() async {
    try {
      final currentPatch = await _shorebird.currentPatchNumber();
      final nextPatch = await _shorebird.nextPatchNumber();
      return 'Atualizando do patch $currentPatch para $nextPatch';
    } catch (e) {
      return 'Não foi possível obter informações da versão';
    }
  }

  void _showUpdateDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _UpdateDialog(
        onConfirm: () async {
          // Obtém as informações da versão antes de fechar o diálogo
          final versionInfo = await _getVersionInfo();
          debugPrint(versionInfo);

          // Verifica se o contexto ainda está montado
          if (!dialogContext.mounted) return;

          // Fecha o diálogo e reinicia o app
          Navigator.pop(dialogContext);
          SystemNavigator.pop();
        },
        onCancel: () {
          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _UpdateDialog({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova atualização'),
      content: const Text(
        'É necessário reiniciar o app para aplicar a atualização.',
      ),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: const Text('Reiniciar agora'),
        ),
        TextButton(
          onPressed: onCancel,
          child: const Text('Mais tarde'),
        ),
      ],
    );
  }
}
