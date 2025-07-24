import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/home/data/services/polling_services.dart';
import '../../features/home/data/services/webview_service.dart';
import '../../repositories/home/home_repository.dart';
import '../../repositories/home/home_repository_impl.dart';
import '../../repositories/schedule/schedule_repository.dart';
import '../../repositories/schedule/schedule_repository_impl.dart';
import '../../repositories/user/user_repository.dart';
import '../../repositories/user/user_repository_impl.dart';
import '../../service/home/home_service.dart';
import '../../service/home/home_service_impl.dart';
import '../../service/schedule/schedule_service.dart';
import '../../service/schedule/schedule_service_impl.dart';
import '../../service/user/user_service.dart';
import '../../service/user/user_service_impl.dart';
import '../local_storage/flutter_secure_storage/flutter_secure_storage_local_storage_impl.dart';
import '../local_storage/local_storage.dart';
import '../local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import '../logger/app_logger.dart';
import '../logger/logger_app_logger_impl.dart';
import '../rest_client/dio/dio_rest_client.dart';
import '../rest_client/rest_client.dart';
import '../services/settings_service.dart';
import '../services/url_launcher_service.dart';
import '../services/volume_service.dart';

final GetIt i = GetIt.instance;

class Injector {
  static Future<void> setup() async {
    await _injectCoreServices();
    await _injectRepositories();
    await _injectServices();
    await _injectControllers();
  }

  static Future<void> _injectCoreServices() async {
    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    i.registerLazySingleton<SharedPreferences>(() => prefs);

    // Local Storage
    i.registerLazySingleton<LocalStorage>(
      () => SharedPreferencesLocalStorageImpl(),
    );

    i.registerLazySingleton<LocalSecureStorage>(
      () => FlutterSecureStorageLocalStorageImpl(),
    );

    // Logger
    i.registerLazySingleton<AppLogger>(
      () => LoggerAppLoggerImpl(),
    );

    // Auth Store
    i.registerLazySingleton<AuthViewModel>(
      () => AuthViewModel(
        localStorage: i(),
        logger: i(),
      ),
    );

    // Rest Client
    i.registerLazySingleton<RestClient>(
      () => DioRestClient(
        localStorage: i(),
        logger: i(),
        authStore: i(),
      ),
    );
  }

  static Future<void> _injectRepositories() async {
    // User Repository
    i.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        logger: i(),
        restClient: i(),
      ),
    );

    // Schedule Repository
    i.registerLazySingleton<SchedulesRepository>(
      () => ScheduleRepositoryImpl(
        restClient: i(),
        logger: i(),
      ),
    );

    // Home Repository
    i.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        restClient: i(),
        logger: i(),
      ),
    );
  }

  static Future<void> _injectServices() async {
    // User Service
    i.registerLazySingleton<UserService>(
      () => UserServiceImpl(
        logger: i(),
        userRepository: i(),
        localStorage: i(),
        localSecureStorage: i(),
      ),
    );

    // Schedule Service
    i.registerLazySingleton<ScheduleService>(
      () => StreamerServiceImpl(
        logger: i(),
        streamerRepository: i(),
      ),
    );

    // WebView Service
    i.registerLazySingleton<WebViewService>(
      () => WebViewServiceImpl(
        logger: i(),
      ),
    );

    // Home Service
    i.registerLazySingleton<HomeService>(
      () => HomeServiceImpl(
        homeRepository: i(),
        logger: i(),
      ),
    );

    // Polling Service
    i.registerLazySingleton<PollingService>(
      () => PollingServiceImpl(
        homeService: i(),
        logger: i(),
      ),
    );

    // Volume Service
    i.registerLazySingleton<VolumeService>(
      () => VolumeService(
        logger: i(),
        webViewService: i(),
      ),
    );

    // Settings Service
    i.registerLazySingleton<SettingsService>(
      () => SettingsService(
        logger: i(),
        volumeService: i(),
      ),
    );

    // UrlLauncher Service
    i.registerLazySingleton<UrlLauncherService>(
      () => UrlLauncherService(
        logger: i(),
      ),
    );
  }

  static Future<void> _injectControllers() async {
    // Remover injeção dos antigos controllers
  }
}

// Helper para facilitar o acesso
T injector<T extends Object>() => i<T>();
