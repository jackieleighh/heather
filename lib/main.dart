import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
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

  runApp(const ProviderScope(child: HeatherApp()));
}
