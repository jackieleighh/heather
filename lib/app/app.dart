import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import 'theme.dart';

class HeatherApp extends ConsumerWidget {
  final GoRouter router;

  const HeatherApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Heather',
      theme: HeatherTheme.light(accentColor: AppColors.magenta),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
