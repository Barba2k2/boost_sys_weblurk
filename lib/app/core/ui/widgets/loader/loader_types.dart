import 'loader_overlay.dart';

class LoaderTypes {
  LoaderTypes._();

  // Loaders específicos para diferentes operações
  static void showLoadingSchedules() {
    LoaderOverlay.show();
  }

  static void showLoadingChannel() {
    LoaderOverlay.show();
  }

  static void showReloading() {
    LoaderOverlay.show();
  }

  static void showAuthenticating() {
    LoaderOverlay.show();
  }
} 