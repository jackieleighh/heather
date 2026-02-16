import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/weather/presentation/providers/settings_provider.dart';
import 'theme.dart';

class HeatherApp extends ConsumerWidget {
  final GoRouter router;

  const HeatherApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(settingsProvider.select((s) => s.persona));
    return MaterialApp.router(
      title: 'Heather',
      theme: HeatherTheme.light(accentColor: persona.heroColor),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
