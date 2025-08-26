import 'package:flutter/material.dart';
import '../../controllers/update_controller.dart';

/// Widget that provides update functionality following MVVM pattern
/// This widget demonstrates how to integrate the update system into your app
class UpdateCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool autoCheckOnInit;
  final Duration? autoCheckInterval;

  const UpdateCheckerWidget({
    super.key,
    required this.child,
    this.autoCheckOnInit = true,
    this.autoCheckInterval,
  });

  @override
  State<UpdateCheckerWidget> createState() => _UpdateCheckerWidgetState();
}

class _UpdateCheckerWidgetState extends State<UpdateCheckerWidget> {
  late final UpdateController _updateController;

  @override
  void initState() {
    super.initState();
    _updateController = UpdateController();

    // Auto check for updates on app start
    if (widget.autoCheckOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateController.checkAndShowUpdateDialog(context);
      });
    }

    // Set up periodic checks if specified
    if (widget.autoCheckInterval != null) {
      _setupPeriodicCheck();
    }
  }

  void _setupPeriodicCheck() {
    // TODO: Implement periodic update checking
    // This could use a Timer.periodic or similar mechanism
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateInheritedWidget(
      controller: _updateController,
      child: widget.child,
    );
  }
}

/// InheritedWidget to provide UpdateController throughout the widget tree
class UpdateInheritedWidget extends InheritedWidget {
  final UpdateController controller;

  const UpdateInheritedWidget({
    super.key,
    required this.controller,
    required super.child,
  });

  static UpdateController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<UpdateInheritedWidget>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(UpdateInheritedWidget oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Utility class to access update functionality from anywhere in the app
class UpdateHelper {
  /// Get the update controller from context
  static UpdateController? of(BuildContext context) {
    return UpdateInheritedWidget.of(context);
  }

  /// Manual update check - call this from a menu or button
  static Future<void> checkForUpdates(BuildContext context) async {
    final controller = of(context);
    if (controller != null) {
      await controller.manualCheckForUpdates(context);
    }
  }

  /// Check if app is currently updating
  static bool isUpdating(BuildContext context) {
    final controller = of(context);
    return controller?.isUpdating ?? false;
  }

  /// Check if update is available
  static bool hasUpdate(BuildContext context) {
    final controller = of(context);
    return controller?.hasUpdate ?? false;
  }
}

/// Example usage in a settings screen or menu
class UpdateMenuItem extends StatelessWidget {
  const UpdateMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UpdateInheritedWidget.of(context);
    final isUpdating = controller?.isUpdating ?? false;
    final hasUpdate = controller?.hasUpdate ?? false;

    return ListTile(
      leading: Icon(
        hasUpdate ? Icons.system_update_alt : Icons.system_update,
        color: hasUpdate ? Colors.orange : null,
      ),
      title: const Text('Verificar Atualizações'),
      subtitle: Text(
        hasUpdate 
          ? 'Atualização disponível'
          : isUpdating 
            ? 'Verificando...'
            : 'Aplicativo atualizado',
      ),
      trailing: hasUpdate
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nova',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
      onTap: isUpdating
          ? null
          : () => UpdateHelper.checkForUpdates(context),
    );
  }
}