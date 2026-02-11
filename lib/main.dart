import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/services/notification_service.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await dotenv.load(fileName: '.env');
  await NotificationService().init();

  final geminiKey = dotenv.env['GEMINI_API_KEY'];
  if (geminiKey != null && geminiKey.isNotEmpty) {
    await SecureStorage().saveGeminiKey(geminiKey);
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final router = buildRouter(onboardingCompleted: onboardingCompleted);

  runApp(
    ProviderScope(
      child: HeatherApp(router: router),
    ),
  );
}
