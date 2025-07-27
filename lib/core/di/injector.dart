import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/login/presentation/viewmodels/login_viewmodel.dart';
import '../../features/home/data/services/polling_services.dart';
import '../../features/home/data/services/webview_service.dart';
import '../../features/home/presentation/viewmodels/home_viewmodel.dart';
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
    final prefs = await SharedPreferences.getInstance();
    i.registerLazySingleton<SharedPreferences>(() => prefs);

    i.registerLazySingleton<LocalStorage>(
      () => SharedPreferencesLocalStorageImpl(),
    );

    i.registerLazySingleton<LocalSecureStorage>(
      () => FlutterSecureStorageLocalStorageImpl(),
    );

    i.registerLazySingleton<AppLogger>(
      () => LoggerAppLoggerImpl(),
    );

    i.registerLazySingleton<AuthViewModel>(
      () => AuthViewModel(
        localStorage: i(),
        logger: i(),
      ),
    );

    i.registerLazySingleton<RestClient>(
      () => DioRestClient(
        localStorage: i(),
        logger: i(),
        authStore: i(),
      ),
    );
  }

  static Future<void> _injectRepositories() async {
    i.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        logger: i(),
        restClient: i(),
      ),
    );

    i.registerLazySingleton<SchedulesRepository>(
      () => ScheduleRepositoryImpl(
        restClient: i(),
        logger: i(),
      ),
    );

    i.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        restClient: i(),
        logger: i(),
      ),
    );
  }

  static Future<void> _injectServices() async {
    i.registerLazySingleton<UserService>(
      () => UserServiceImpl(
        logger: i(),
        userRepository: i(),
        localStorage: i(),
        localSecureStorage: i(),
      ),
    );

    i.registerLazySingleton<ScheduleService>(
      () => StreamerServiceImpl(
        logger: i(),
        streamerRepository: i(),
      ),
    );

    i.registerLazySingleton<WebViewService>(
      () => WebViewServiceImpl(
        logger: i(),
      ),
    );

    i.registerLazySingleton<HomeService>(
      () => HomeServiceImpl(
        homeRepository: i(),
        logger: i(),
      ),
    );

    i.registerLazySingleton<PollingService>(
      () => PollingServiceImpl(
        homeService: i(),
        logger: i(),
      ),
    );

    i.registerLazySingleton<VolumeService>(
      () => VolumeService(
        logger: i(),
        webViewService: i(),
      ),
    );

    i.registerLazySingleton<SettingsService>(
      () => SettingsService(
        logger: i(),
        volumeService: i(),
      ),
    );

    i.registerLazySingleton<UrlLauncherService>(
      () => UrlLauncherService(
        logger: i(),
      ),
    );
  }

  static Future<void> _injectControllers() async {
    
    i.registerFactory<LoginViewModel>(
      () => LoginViewModel(
        authStore: i(),
        userService: i(),
      ),
    );

    
    i.registerFactory<HomeViewModel>(
      () => HomeViewModel(
        homeService: i(),
        logger: i(),
        authViewmodel: i(),
        webViewService: i(),
        volumeService: i(),
      ),
    );
  }
}


T injector<T extends Object>() => i<T>();
