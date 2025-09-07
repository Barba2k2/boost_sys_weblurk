import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/auth/login/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/login/presentation/viewmodels/login_viewmodel.dart';
import '../../features/auth/register/presentation/pages/register_page.dart';
import '../../features/auth/register/presentation/viewmodels/register_viewmodel.dart';
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: LoginPage(
                viewModel: injector<LoginViewModel>(),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).chain(
                        CurveTween(
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween(
                          begin: 0.8,
                          end: 1.0,
                        ).chain(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.register,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: RegisterPage(
                viewModel: injector<RegisterViewModel>(),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(
                        begin: const Offset(0.0, 0.3),
                        end: Offset.zero,
                      ).chain(
                        CurveTween(
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                    child: ScaleTransition(
                      scale: animation.drive(
                        Tween(
                          begin: 0.8,
                          end: 1.0,
                        ).chain(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
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
