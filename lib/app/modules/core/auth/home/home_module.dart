import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/rest_client/rest_client.dart';
import '../../../../repositories/home/home_repository.dart';
import '../../../../repositories/home/home_repository_impl.dart';
import '../../../../service/home/home_service.dart';
import '../../../../service/home/home_service_impl.dart';
import '../../../../service/webview/windows_web_view_service.dart';
import '../../../../service/webview/windows_web_view_service_impl.dart';
import 'services/polling_services.dart';
import '../auth_store.dart';
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
        Bind.lazySingleton<WindowsWebViewService>(
          (i) => WindowsWebViewServiceImpl(
            logger: i<AppLogger>(),
          ),
        ),
        Bind.lazySingleton<PollingService>(
          (i) => PollingServiceImpl(
            homeService: i<HomeService>(),
            logger: i<AppLogger>(),
          ),
        ),
        Bind.lazySingleton<HomeController>(
          (i) => HomeController(
            homeService: i<HomeService>(),
            authStore: i<AuthStore>(),
            logger: i<AppLogger>(),
            webViewService: i<WindowsWebViewService>(),
            pollingService: i<PollingService>(),
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
