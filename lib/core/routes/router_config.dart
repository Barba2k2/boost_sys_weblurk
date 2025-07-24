import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/login/presentation/viewmodels/login_viewmodel.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../di/injector.dart';
import 'app_routes.dart';

class RouterConfig {
  static GoRouter get router => GoRouter(
        redirect: _redirect,
        refreshListenable: injector<AuthViewModel>(),
        initialLocation: AppRoutes.splash,
        routes: [
          GoRoute(
            path: AppRoutes.splash,
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => LoginPage(
              viewModel: LoginViewModel(
                authStore: injector(),
                userService: injector(),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => HomePage(
              viewModel: HomeViewModel(
                homeService: injector(),
                authStore: injector(),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => SettingsPage(
              viewModel: SettingsViewModel(
                settingsService: injector(),
                volumeService: injector(),
                urlLauncherService: injector(),
              ),
            ),
          ),
        ],
      );

  static Future<String?> _redirect(
      BuildContext context, GoRouterState state) async {
    final authStore = injector<AuthViewModel>();
    final loggedIn = authStore.userLogged != null;
    final loggingIn = state.matchedLocation == AppRoutes.login;
    final isSplash = state.matchedLocation == AppRoutes.splash;

    // Se está na splash, redireciona baseado no status de login
    if (isSplash) {
      if (loggedIn) {
        return AppRoutes.home;
      } else {
        return AppRoutes.login;
      }
    }

    // Se não está logado e não está fazendo login, redireciona para login
    if (!loggedIn && !loggingIn) {
      return AppRoutes.login;
    }

    // Se está logado e tentando fazer login, redireciona para home
    if (loggingIn && loggedIn) {
      return AppRoutes.home;
    }

    return null;
  }
}

// Página de splash temporária
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
