import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "core/theme/app_theme.dart";
import "providers/auth_provider.dart";
import "screens/auth/login_screen.dart";
import "screens/shell/app_shell.dart";

void main() {
  runApp(const ProviderScope(child: CsmsApp()));
}

class CsmsApp extends ConsumerWidget {
  const CsmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: "CSMS",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

/// Riverpod-aware GoRouter: `refreshListenable` isn't used because AuthState
/// isn't a Listenable, so instead the router listens to authProvider directly
/// via ref and rebuilds/redirects whenever auth status changes.
final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/",
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggingIn = state.matchedLocation == "/login";

      if (authState.status == AuthStatus.unknown) return null; // splash while restoring session

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (!isAuthenticated && !isLoggingIn) return "/login";
      if (isAuthenticated && isLoggingIn) return "/";
      return null;
    },
    routes: [
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: "/",
        builder: (context, state) {
          final status = ref.read(authProvider).status;
          if (status == AuthStatus.unknown) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return const AppShell();
        },
      ),
    ],
  );
});

/// Bridges Riverpod's [authProvider] changes into something GoRouter's
/// `refreshListenable` can subscribe to, so navigation reacts immediately to
/// login/logout without the person needing to manually navigate.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _subscription = _ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
