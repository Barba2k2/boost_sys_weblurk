import 'package:get_it/get_it.dart';
import '../../features/auth/domain/entities/auth_store.dart';
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
import '../../service/webview/windows_web_view_service.dart';
import '../../service/webview/windows_web_view_service_impl.dart';
import '../controllers/settings_controller.dart';
import '../controllers/url_launch_controller.dart';
import '../local_storage/flutter_secure_storage/flutter_secure_storage_local_storage_impl.dart';
import '../local_storage/local_storage.dart';
import '../local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import '../logger/app_logger.dart';
import '../logger/logger_app_logger_impl.dart';
import '../rest_client/dio/dio_rest_client.dart';
import '../rest_client/rest_client.dart';

class DependencyInjection {
  DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  static final DependencyInjection _instance = DependencyInjection._internal();

  final GetIt _getIt = GetIt.instance;

  void initialize() {
    // Core services
    _getIt.registerSingleton<AppLogger>(LoggerAppLoggerImpl());
    _getIt.registerSingleton<LocalStorage>(SharedPreferencesLocalStorageImpl());
    _getIt.registerSingleton<LocalSecureStorage>(
        FlutterSecureStorageLocalStorageImpl());

    // Auth store
    _getIt.registerSingleton<AuthStore>(AuthStore(
      localStorage: get<LocalStorage>(),
      logger: get<AppLogger>(),
    ));

    // Rest client
    _getIt.registerSingleton<RestClient>(DioRestClient(
      localStorage: get<LocalStorage>(),
      logger: get<AppLogger>(),
      authStore: get<AuthStore>(),
    ));

    // Repositories
    _getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      logger: get<AppLogger>(),
      restClient: get<RestClient>(),
    ));

    _getIt.registerSingleton<HomeRepository>(HomeRepositoryImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    ));

    _getIt.registerSingleton<SchedulesRepository>(ScheduleRepositoryImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    ));

    // Services
    _getIt.registerSingleton<UserService>(UserServiceImpl(
      logger: get<AppLogger>(),
      userRepository: get<UserRepository>(),
      localStorage: get<LocalStorage>(),
      localSecureStorage: get<LocalSecureStorage>(),
    ));

    _getIt.registerSingleton<HomeService>(HomeServiceImpl(
      homeRepository: get<HomeRepository>(),
      logger: get<AppLogger>(),
    ));

    _getIt.registerSingleton<ScheduleService>(StreamerServiceImpl(
      streamerRepository: get<SchedulesRepository>(),
      logger: get<AppLogger>(),
    ));

    _getIt.registerSingleton<WindowsWebViewService>(WindowsWebViewServiceImpl(
      logger: get<AppLogger>(),
    ));

    // Controllers
    _getIt.registerSingleton<UrlLaunchController>(UrlLaunchController(
      logger: get<AppLogger>(),
    ));

    _getIt.registerSingleton<SettingsController>(SettingsController(
      logger: get<AppLogger>(),
    ));

    // Initialize auth store
    get<AuthStore>().loadUserLogged();
  }

  T get<T extends Object>() {
    return _getIt<T>();
  }

  void register<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  void reset() {
    _getIt.reset();
  }
}

// Global instance
final di = DependencyInjection();
