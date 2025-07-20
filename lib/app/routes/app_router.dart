import 'package:go_router/go_router.dart';

import '../core/di/dependency_injection.dart';
import '../features/auth/domain/entities/auth_state.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/home/presentation/pages/home_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
  refreshListenable: getIt<AuthState>(),
  redirect: (context, state) {
    final authState = getIt<AuthState>();
    final isLoggedIn = authState.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/auth';

    if (!isLoggedIn && !isLoggingIn) {
      return '/auth';
    }

    if (isLoggedIn && isLoggingIn) {
      return '/home';
    }

    return null;
  },
);
