import 'package:flutter_modular/flutter_modular.dart';

import '../../../core/local_storage/flutter_secure_storage/flutter_secure_storage_local_storage_impl.dart';
import '../../../core/local_storage/local_storage.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/rest_client/rest_client.dart';
import '../../../repositories/user/user_repository.dart';
import '../../../repositories/user/user_repository_impl.dart';
import '../../../service/user/user_service.dart';
import '../../../service/user/user_service_impl.dart';
import '../../auth/home/auth_home_page.dart';
import 'auth_store.dart';
import 'login/login_module.dart';

class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<LocalSecureStorage>(
          (i) => FlutterSecureStorageLocalStorageImpl(),
        ),
        Bind.lazySingleton<UserRepository>(
          (i) => UserRepositoryImpl(
            logger: i.get<AppLogger>(),
            restClient: i.get<RestClient>(),
          ),
        ),
        Bind.lazySingleton<UserService>(
          (i) => UserServiceImpl(
            logger: i.get<AppLogger>(),
            userRepository: i.get<UserRepository>(),
            localStorage: i.get<LocalStorage>(),
            localSecureStorage: i.get<LocalSecureStorage>(),
          ),
        ),
        Bind.lazySingleton(
          (i) => AuthStore(
            localStorage: i.get<LocalStorage>(),
          )..loadUserLogged(),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => AuthHomePage(
            authStore: Modular.get<AuthStore>(),
          ),
        ),
        ModuleRoute(
          '/login',
          module: LoginModule(),
        ),
      ];
}
