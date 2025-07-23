import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';

class Loader {
  Loader._();

  static OverlayEntry? _entry;
  static bool _open = false;

  static void show() {
    _entry ??= OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
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

  // Loaders específicos para diferentes operações
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
