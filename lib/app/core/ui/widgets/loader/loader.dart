// Loader barrel
export 'loader_overlay.dart';
export 'loader_types.dart';

// Classe principal para compatibilidade
import 'loader_overlay.dart';
import 'loader_types.dart';

class Loader {
  Loader._();

  // Delegate para LoaderOverlay
  static void show() => LoaderOverlay.show();
  static void hide() => LoaderOverlay.hide();
  static bool get isOpen => LoaderOverlay.isOpen;

  // Delegate para LoaderTypes
  static void showLoadingSchedules() => LoaderTypes.showLoadingSchedules();
  static void showLoadingChannel() => LoaderTypes.showLoadingChannel();
  static void showReloading() => LoaderTypes.showReloading();
  static void showAuthenticating() => LoaderTypes.showAuthenticating();
} 