import 'package:asuka/asuka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/ui/ui_config.dart';
import 'routes/app_router.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 720),
      builder: (_, __) => MaterialApp.router(
        title: UiConfig.title,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Asuka.builder(context, child);
        },
        theme: UiConfig.lightTheme,
        darkTheme: UiConfig.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
