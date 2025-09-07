import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

/// Widget that handles Android back button press with confirmation dialog
class AndroidBackButtonHandler extends StatelessWidget {
  const AndroidBackButtonHandler({
    super.key,
    required this.child,
    this.onBackPressed,
  });

  final Widget child;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    // Only wrap with WillPopScope on Android
    if (!Platform.isAndroid) {
      return child;
    }

    return WillPopScope(
      onWillPop: () => _handleBackButton(context),
      child: child,
    );
  }

  Future<bool> _handleBackButton(BuildContext context) async {
    // If custom handler is provided, use it
    if (onBackPressed != null) {
      onBackPressed!();
      return false; // Prevent default back behavior
    }

    // Show confirmation dialog
    final shouldPop = await _showExitConfirmationDialog(context);
    return shouldPop;
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.cosmicDarkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: AppColors.cosmicBorder.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.exit_to_app,
                    color: AppColors.cosmicAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sair do App',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Ibrand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Tem certeza que deseja sair do Boost SysWebLurk?',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Ibrand',
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Cancel
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        AppColors.cosmicBlue.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontFamily: 'Ibrand',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm exit
                    SystemNavigator.pop(); // Exit the app
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        AppColors.cosmicAccent.withValues(alpha: 0.8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      fontFamily: 'Ibrand',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }
}
