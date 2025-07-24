import '../logger/app_logger.dart';
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

class AppRouter {
  static GoRouter get router => GoRouter(
        // ✅ CORREÇÃO: Adicionado o logger ao redirect para depuração.
        redirect: (context, state) => _redirect(context, state, injector()),
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
              // ✅ CORREÇÃO: ViewModel injetado diretamente.
              viewModel: injector<LoginViewModel>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => HomePage(
              // ✅ CORREÇÃO: ViewModel injetado diretamente.
              viewModel: injector<HomeViewModel>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => SettingsPage(
              // ✅ CORREÇÃO: ViewModel injetado diretamente.
              viewModel: injector<SettingsViewModel>(),
            ),
          ),
        ],
      );

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
    AppLogger logger,
  ) async {
    final authStore = injector<AuthViewModel>();
    final loggedIn = authStore.userLogged != null;
    final loggingIn = state.matchedLocation == AppRoutes.login;
    final isSplash = state.matchedLocation == AppRoutes.splash;

    logger.info(
        'Redirecting... loggedIn: $loggedIn, location: ${state.matchedLocation}');

    if (isSplash) {
      return loggedIn ? AppRoutes.home : AppRoutes.login;
    }

    if (!loggedIn && !loggingIn) {
      logger.info('User not logged in, redirecting to login.');
      return AppRoutes.login;
    }

    if (loggedIn && loggingIn) {
      logger.info('User already logged in, redirecting to home.');
      return AppRoutes.home;
    }

    return null; // Nenhuma ação de redirecionamento necessária
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
