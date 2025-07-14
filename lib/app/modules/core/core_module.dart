import 'package:flutter_modular/flutter_modular.dart';

import '../../core/controllers/settings_controller.dart';
import '../../core/controllers/url_launch_controller.dart';
import '../../core/controllers/volume_controller.dart';
import '../../core/local_storage/flutter_secure_storage/flutter_secure_storage_local_storage_impl.dart';
import '../../core/local_storage/local_storage.dart';
import '../../core/local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import '../../core/logger/app_logger.dart';
import '../../core/logger/logger_app_logger_impl.dart';
import '../../core/rest_client/dio/dio_rest_client.dart';
import '../../core/rest_client/rest_client.dart';
import '../../repositories/schedule/schedule_repository.dart';
import '../../repositories/schedule/schedule_repository_impl.dart';
import '../../service/schedule/schedule_service.dart';
import '../../service/schedule/schedule_service_impl.dart';
import 'auth/auth_store.dart';
import 'auth/home/home_module.dart';

class CoreModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<AppLogger>(
          (i) => LoggerAppLoggerImpl(),
          export: true,
        ),
        Bind.lazySingleton<LocalStorage>(
          (i) => SharedPreferencesLocalStorageImpl(),
          export: true,
        ),
        Bind.lazySingleton<LocalSecureStorage>(
          (i) => FlutterSecureStorageLocalStorageImpl(),
          export: true,
        ),
        Bind.lazySingleton(
          (i) => AuthStore(
            localStorage: i(),
          ),
          export: true,
        ),
        Bind.lazySingleton<RestClient>(
          (i) => DioRestClient(
            localStorage: i(),
            logger: i(),
            authStore: i(),
          ),
          export: true,
        ),
        Bind.lazySingleton<SchedulesRepository>(
          (i) => ScheduleRepositoryImpl(
            restClient: i(),
            logger: i(),
          ),
          export: true,
        ),
        Bind.lazySingleton<ScheduleService>(
          (i) => StreamerServiceImpl(
            streamerRepository: i(),
            logger: i(),
          ),
          export: true,
        ),
        Bind.lazySingleton<VolumeController>(
          (i) => VolumeController(
            logger: i<AppLogger>(),
          ),
          export: true,
        ),
        Bind.lazySingleton<UrlLaunchController>(
          (i) => UrlLaunchController(
            logger: i<AppLogger>(),
          ),
          export: true,
        ),
        Bind.lazySingleton<SettingsController>(
          (i) => SettingsController(
            logger: i<AppLogger>(),
            volumeController: i<VolumeController>(),
          ),
          export: true,
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute('/', module: HomeModule()),
      ];
}
