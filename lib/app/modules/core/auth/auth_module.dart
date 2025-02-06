import 'package:flutter_modular/flutter_modular.dart';

import '../../../core/local_storage/local_storage.dart';
import '../../../core/logger/app_logger.dart';
import '../../../repositories/user/user_repository.dart';
import '../../../repositories/user/user_repository_impl.dart';
import '../../../service/user/user_service.dart';
import '../../../service/user/user_service_impl.dart';
import '../../auth/home/auth_home_page.dart';
import 'auth_store.dart';
import 'login/login_controller.dart';
import 'login/login_module.dart';

class AuthModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton<UserRepository>(
          (i) => UserRepositoryImpl(
            logger: i(),
            restClient: i(),
          ),
        ),
        Bind.lazySingleton<UserService>(
          (i) => UserServiceImpl(
            logger: i(),
            userRepository: i(),
            localStorage: i(),
            localSecureStorage: i(),
          ),
        ),
        Bind.lazySingleton(
          (i) => LoginController(
            userService: i.get<UserService>(),
            localStorage: i.get<LocalStorage>(),
            logger: i.get<AppLogger>(),
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
