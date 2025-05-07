import 'package:go_router/go_router.dart';
import 'package:monit/pages/authentication/forgot_password.dart';
import 'package:monit/pages/authentication/login.dart';
import 'package:monit/pages/authentication/reset_password.dart';
import 'package:monit/pages/authentication/verify.dart';
import 'package:monit/pages/dashboard.dart';
import 'package:monit/pages/history.dart';
import 'package:monit/pages/profile.dart';
import 'package:monit/utils/const.dart';
import 'package:monit/widgets/main_layout.dart';

GoRouter router = GoRouter(
  initialLocation: MyRoutes.verify,
  routes: [
    ...authRoutes,
    // Using StatefulShellRoute for tab-based navigation with state preservation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainLayout(child: navigationShell),
      branches: [
        // Dashboard/Home tab
        StatefulShellBranch(routes: [
          GoRoute(
            path: MyRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          )
        ]),
        // Profile tab
        StatefulShellBranch(routes: [
          GoRoute(
            path: MyRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          )
        ]),
        // History tab
        StatefulShellBranch(routes: [
          GoRoute(
            path: MyRoutes.usageHistory,
            builder: (context, state) => const HistoryScreen(),
          )
        ]),
      ],
    ),
  ],
);

// Auth related routes
final List<RouteBase> authRoutes = [
  GoRoute(
    path: MyRoutes.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: MyRoutes.verify,
    builder: (context, state) => const VerifyScreen(),
  ),
  GoRoute(
    path: MyRoutes.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: MyRoutes.resetPassword,
    builder: (context, state) {
      final email = state.uri.queryParameters['email'] ?? '';
      return ResetPasswordScreen(email: email);
    },
  ),
];
