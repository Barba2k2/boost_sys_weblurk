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

  final Map<Type, dynamic> _dependencies = {};

  void initialize() {
    // Core services
    _dependencies[AppLogger] = LoggerAppLoggerImpl();
    _dependencies[LocalStorage] = SharedPreferencesLocalStorageImpl();
    _dependencies[LocalSecureStorage] = FlutterSecureStorageLocalStorageImpl();

    // Auth store
    _dependencies[AuthStore] = AuthStore(
      localStorage: get<LocalStorage>(),
      logger: get<AppLogger>(),
    );

    // Rest client
    _dependencies[RestClient] = DioRestClient(
      localStorage: get<LocalStorage>(),
      logger: get<AppLogger>(),
      authStore: get<AuthStore>(),
    );

    // Repositories
    _dependencies[UserRepository] = UserRepositoryImpl(
      logger: get<AppLogger>(),
      restClient: get<RestClient>(),
    );

    _dependencies[HomeRepository] = HomeRepositoryImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    );

    _dependencies[SchedulesRepository] = ScheduleRepositoryImpl(
      restClient: get<RestClient>(),
      logger: get<AppLogger>(),
    );

    // Services
    _dependencies[UserService] = UserServiceImpl(
      logger: get<AppLogger>(),
      userRepository: get<UserRepository>(),
      localStorage: get<LocalStorage>(),
      localSecureStorage: get<LocalSecureStorage>(),
    );

    _dependencies[HomeService] = HomeServiceImpl(
      homeRepository: get<HomeRepository>(),
      logger: get<AppLogger>(),
    );

    _dependencies[ScheduleService] = StreamerServiceImpl(
      streamerRepository: get<SchedulesRepository>(),
      logger: get<AppLogger>(),
    );

    _dependencies[WindowsWebViewService] = WindowsWebViewServiceImpl(
      logger: get<AppLogger>(),
    );

    // Controllers
    _dependencies[UrlLaunchController] = UrlLaunchController(
      logger: get<AppLogger>(),
    );

    _dependencies[SettingsController] = SettingsController(
      logger: get<AppLogger>(),
    );

    // Initialize auth store
    get<AuthStore>().loadUserLogged();
  }

  T get<T>() {
    if (_dependencies.containsKey(T)) {
      return _dependencies[T] as T;
    }
    throw Exception('Dependency $T not found');
  }

  void register<T>(T instance) {
    _dependencies[T] = instance;
  }
}

// Global instance
final di = DependencyInjection();
