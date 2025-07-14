import 'package:flutter_modular/flutter_modular.dart';

import 'core/controllers/settings_controller.dart';
import 'core/controllers/url_launch_controller.dart';
import 'core/controllers/volume_controller.dart';
import 'core/local_storage/local_storage.dart';
import 'core/local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import 'core/logger/app_logger.dart';
import 'core/logger/logger_app_logger_impl.dart';
import 'core/rest_client/dio/dio_rest_client.dart';
import 'core/rest_client/rest_client.dart';
import 'modules/core/auth/auth_module.dart';
import 'modules/core/auth/auth_store.dart';
import 'modules/core/core_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        // Core services
        Bind.lazySingleton<AppLogger>(
          (i) => LoggerAppLoggerImpl(),
        ),
        Bind.lazySingleton<LocalStorage>(
          (i) => SharedPreferencesLocalStorageImpl(),
        ),
        Bind.lazySingleton<AuthStore>(
          (i) => AuthStore(
            localStorage: i<LocalStorage>(),
          ),
        ),
        Bind.lazySingleton<RestClient>(
          (i) => DioRestClient(
            localStorage: i<LocalStorage>(),
            logger: i<AppLogger>(),
            authStore: i<AuthStore>(),
          ),
        ),

        // Controllers
        Bind.lazySingleton<VolumeController>(
          (i) => VolumeController(
            logger: i<AppLogger>(),
          ),
        ),
        Bind.lazySingleton<SettingsController>(
          (i) => SettingsController(
            logger: i<AppLogger>(),
            volumeController: i<VolumeController>(),
          ),
        ),
        Bind.lazySingleton<UrlLaunchController>(
          (i) => UrlLaunchController(
            logger: i<AppLogger>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/', module: CoreModule()),
        ModuleRoute('/auth', module: AuthModule()),
      ];
}
