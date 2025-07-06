import 'package:get_it/get_it.dart';
import '../../features/auth/domain/entities/auth_store.dart';
import '../../features/home/data/services/home_service_impl.dart';
import '../../features/home/domain/services/home_service.dart';
import '../../features/home/domain/services/polling_service.dart';
import '../../features/home/domain/services/webview_service.dart';
import '../controllers/settings_controller.dart';
import '../controllers/url_launch_controller.dart';
import '../local_storage/flutter_secure_storage/flutter_secure_storage_local_storage_impl.dart';
import '../local_storage/local_storage.dart';
import '../local_storage/shared_preferences/shared_preferences_local_storage_impl.dart';
import '../logger/app_logger.dart';
import '../logger/logger_app_logger_impl.dart';
import '../rest_client/dio/dio_rest_client.dart';
import '../rest_client/rest_client.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/auth/data/services/auth_service_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

final getIt = GetIt.instance;

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

    // Controllers
    _getIt.registerSingleton<UrlLaunchController>(UrlLaunchController(
      logger: get<AppLogger>(),
    ));

    _getIt.registerSingleton<SettingsController>(SettingsController(
      logger: get<AppLogger>(),
    ));

    // Home services
    _getIt.registerSingleton<HomeService>(HomeServiceImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    ));

    // Polling service
    _getIt.registerSingleton<PollingService>(PollingServiceImpl(
      homeService: get<HomeService>(),
      logger: get<AppLogger>(),
    ));

    // WebView service
    _getIt.registerSingleton<WebViewService>(WebViewServiceImpl(
      logger: get<AppLogger>(),
    ));

    // Auth service
    _getIt.registerSingleton<AuthService>(AuthServiceImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    ));

    // Auth repository
    _getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(
      authService: get<AuthService>(),
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
