import 'package:go_router/go_router.dart';

import '../features/weather/presentation/screens/onboarding_screen.dart';
import '../features/weather/presentation/screens/settings_screen.dart';
import '../features/weather/presentation/screens/weather_screen.dart';

GoRouter buildRouter({required bool onboardingCompleted}) {
  return GoRouter(
    initialLocation: onboardingCompleted ? '/' : '/onboarding',
    redirect: (context, state) {
      final uri = state.uri;
      // Ignore non-app URIs (e.g. Glance widget callbacks)
      if (uri.scheme.isNotEmpty && uri.scheme != 'https' && uri.scheme != 'http') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WeatherScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
