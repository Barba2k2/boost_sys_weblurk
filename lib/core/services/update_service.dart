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

  /// Inicializa o serviço de atualizações
  /// Verifica automaticamente no startup e quando o app volta do background
  Future<void> initialize() async {
    log('Inicializando serviço de atualizações...');

    // Aguarda um pouco para garantir que o app está totalmente carregado
    await Future.delayed(const Duration(seconds: 2));

    // Verifica atualização no startup
    await checkForUpdateOnStartup();

    // Configura listener para quando o app volta do background
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        log('App resumed: verificando atualizações...');
        await checkForUpdateOnResume();
      }
      return null;
    });
  }

  /// Verifica atualização no startup do app
  Future<void> checkForUpdateOnStartup() async {
    if (_isChecking || _hasShownDialog) return;

    _isChecking = true;
    try {
      log('Verificando atualizações no startup...');
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        log('Atualização disponível no startup');
        _showUpdateDialog(
          title: 'Nova Atualização Disponível',
          message:
              'Uma nova versão do aplicativo está disponível. Deseja atualizar agora?',
          isStartup: true,
        );
      } else {
        log('Aplicativo está atualizado no startup');
      }
    } catch (e) {
      log('Erro ao verificar atualização no startup: $e');
      debugPrint('Erro ao verificar atualização no startup: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Verifica atualização quando o app volta do background
  Future<void> checkForUpdateOnResume() async {
    if (_isChecking || _hasShownDialog) return;

    _isChecking = true;
    try {
      log('Verificando atualizações no resume...');
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        log('Atualização disponível no resume');
        _showUpdateDialog(
          title: 'Atualização Disponível',
          message: 'Uma nova versão foi encontrada. Deseja atualizar agora?',
          isStartup: false,
        );
      } else {
        log('Aplicativo está atualizado no resume');
      }
    } catch (e) {
      log('Erro ao verificar atualização no resume: $e');
      debugPrint('Erro ao verificar atualização no resume: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Verifica atualização manualmente (pode ser chamado de um botão na UI)
  Future<void> checkForUpdateManually() async {
    if (_isChecking) return;

    _isChecking = true;
    try {
      log('Verificação manual de atualizações...');
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        log('Atualização disponível na verificação manual');
        _showUpdateDialog(
          title: 'Atualização Disponível',
          message: 'Uma nova versão foi encontrada. Deseja atualizar agora?',
          isStartup: false,
        );
      } else {
        log('Aplicativo está atualizado na verificação manual');
        _showNoUpdateDialog();
      }
    } catch (e) {
      log('Erro na verificação manual: $e');
      debugPrint('Erro na verificação manual: $e');
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
      log('Contexto não disponível para mostrar diálogo de atualização');
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
            log('Iniciando atualização...');
            await _updater.update();
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
            log('Atualização aplicada, reiniciando app...');
            SystemNavigator.pop();
          } on UpdateException catch (e) {
            log('Erro ao aplicar atualização: $e');
            debugPrint('Erro ao aplicar atualização: $e');
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
              _showErrorDialog();
            }
          } finally {
            _hasShownDialog = false;
          }
        },
        onCancel: () {
          log('Usuário cancelou atualização');
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
            'Não foi possível verificar ou aplicar a atualização. Tente novamente mais tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Reseta o estado para permitir nova verificação
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
