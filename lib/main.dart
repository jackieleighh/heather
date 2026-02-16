import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await NotificationService().init();
  await FcmService().init();
  await WidgetService.init();

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final router = buildRouter(onboardingCompleted: onboardingCompleted);

  runApp(
    ProviderScope(
      child: HeatherApp(router: router),
    ),
  );
}
