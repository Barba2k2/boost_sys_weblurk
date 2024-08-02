import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter/material.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../../../repositories/home/home_repository.dart';
import '../../../../repositories/home/home_repository_impl.dart';
import '../../../../service/home/home_service.dart';
import '../../../../service/home/home_service_impl.dart';
import 'home_controller.dart';
import 'home_page.dart';

class HomeModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<HomeRepository>(
          (i) => HomeRepositoryImpl(
            restClient: i<RestClient>(),
            logger: i<AppLogger>(),
          ),
        ),
        Bind.singleton<HomeService>(
          (i) => HomeServiceImpl(
            homeRepository: i<HomeRepository>(),
            logger: i<AppLogger>(),
          ),
        ),
        Bind.factory(
          (i) => List<TextEditingController>.generate(
            24,
            (index) => TextEditingController(),
          ),
        ),
        Bind.factory((i) => DateTime.now()),
        Bind.lazySingleton<HomeController>(
          (i) => HomeController(
            controllers: i<List<TextEditingController>>(),
            homeService: i<HomeService>(),
            logger: i<AppLogger>(),
            selectedDate: i<DateTime>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (_, __) => const HomePage(),
        ),
      ];
}
