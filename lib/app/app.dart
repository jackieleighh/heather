import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';

class HeatherApp extends StatelessWidget {
  final GoRouter router;

  const HeatherApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Heather',
      theme: HeatherTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
