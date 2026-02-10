import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class HeatherApp extends StatelessWidget {
  const HeatherApp({super.key});

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
