import 'package:flutter_modular/flutter_modular.dart';

import 'modules/auth_module.dart';
// import 'modules/core/auth/home/home_module.dart';
// import 'modules/core/auth/register_streamer/register_streamer_module.dart';
// import 'modules/core/core_module.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<Module> get imports => [
    // CoreModule(),
    // HomeModule(),
    // RegisterStreamerModule(),
  ];

  @override
  List<ModularRoute> get routes => [
        ModuleRoute(
          '/auth/',
          module: AuthModule(),
        ),
        // ModuleRoute(
        //   '/home/',
        //   module: HomeModule(),
        // ),
        // ModuleRoute(
        //   '/add-user/',
        //   module: RegisterStreamerModule(),
        // ),
      ];
}
