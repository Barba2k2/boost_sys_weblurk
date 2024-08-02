import 'package:flutter_modular/flutter_modular.dart';

import 'register_streamer_controller.dart';
import 'register_streamer_page.dart';

class RegisterStreamerModule extends Module {
  @override
  List<Bind> get binds => [
    Bind.lazySingleton(
      (i) => RegisterStreamerController(
        streamerService: i(),
        logger: i(),
      ),
    ),
  ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, __) => const RegisterStreamerPage(),
        )
      ];
}
