import 'package:flutter_modular/flutter_modular.dart';

import '../../../repositories/user/user_repository.dart';
import '../../../repositories/user/user_repository_impl.dart';
import '../../../service/user/user_service.dart';
import '../../../service/user/user_service_impl.dart';
import '../../auth/home/auth_home_page.dart';
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
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => AuthHomePage(
            authSotre: Modular.get(),
          ),
        ),
        ModuleRoute(
          '/login',
          module: LoginModule(),
        )
      ];
}
