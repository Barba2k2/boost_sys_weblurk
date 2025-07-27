import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';

class Loader {
  Loader._();

  static OverlayEntry? _entry;
  static bool _open = false;

  static void show() {
    _entry ??= OverlayEntry(
      builder: (context) => Container(
        color: AppColors.loaderBackground,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.loader,
          ),
        ),
      ),
    );

    if (!_open) {
      _open = true;
      Asuka.addOverlay(_entry!);
    }
  }

  static void hide() {
    if (_open) {
      _open = false;
      _entry?.remove();
    }
  }

  static void showLoadingSchedules() {
    show();
  }

  static void showLoadingChannel() {
    show();
  }

  static void showReloading() {
    show();
  }

  static void showAuthenticating() {
    show();
  }
}
