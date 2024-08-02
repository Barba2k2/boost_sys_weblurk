import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'core/ui/ui_config.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute('/auth/');

    Modular.setObservers([
      Asuka.asukaHeroController,
    ]);

    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      builder: (_, __) => MaterialApp.router(
        // title: UiConfig.title,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Asuka.builder(context, child);
        },
        // theme: UiConfig.theme,
        routerDelegate: Modular.routerDelegate,
        routeInformationParser: Modular.routeInformationParser,
      ),
    );
  }
}
