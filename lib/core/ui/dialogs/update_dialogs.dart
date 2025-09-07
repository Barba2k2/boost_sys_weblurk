import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/update_progress_model.dart';
import 'download_progress_dialog.dart';
import 'error_dialog.dart';
import 'restart_dialog.dart';
import 'update_available_dialog.dart';

/// Collection of update-related dialogs following Material Design
class UpdateDialogs {
  /// Show the initial update available dialog
  static Future<bool?> showUpdateAvailableDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const UpdateAvailableDialog(),
    );
  }

  /// Show the download progress dialog
  static Future<void> showDownloadProgressDialog(
    BuildContext context,
    ValueListenable<UpdateProgressModel> progressNotifier,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => DownloadProgressDialog(
        progressNotifier: progressNotifier,
      ),
    );
  }

  /// Show the restart confirmation dialog
  static Future<bool?> showRestartDialog(
    BuildContext context, {
    required String restartMessage,
    required VoidCallback onRestart,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => RestartDialog(
        restartMessage: restartMessage,
        onRestart: onRestart,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? technicalDetails,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => ErrorDialog(
        title: title,
        message: message,
        technicalDetails: technicalDetails,
      ),
    );
  }
}
