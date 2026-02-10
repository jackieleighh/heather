import 'package:go_router/go_router.dart';

import '../features/weather/presentation/screens/settings_screen.dart';
import '../features/weather/presentation/screens/weather_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WeatherScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
