import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/login/presentation/viewmodels/login_viewmodel.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../di/injector.dart';
import '../logger/app_logger.dart';
import '../services/navigation_service.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter get router => GoRouter(
        navigatorKey: NavigationService.navigatorKey,
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
              viewModel: injector<LoginViewModel>(),
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => HomePage(
              viewModel: injector<HomeViewModel>(),
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

    if (isSplash) {
      return loggedIn ? AppRoutes.home : AppRoutes.login;
    }

    if (!loggedIn && !loggingIn) {
      return AppRoutes.login;
    }

    if (loggedIn && loggingIn) {
      return AppRoutes.home;
    }

    return null;
  }
}

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
