import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../service/user/user_service.dart';
import 'login_controller.dart';
import 'login_page.dart';

class LoginModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.lazySingleton(
          (i) => LoginController(
            userService: i.get<UserService>(),
            localStorage: i.get<LocalStorage>(),
            logger: i.get<AppLogger>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const LoginPage(),
        ),
      ];
}
