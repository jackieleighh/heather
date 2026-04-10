import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio() {
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Dio get weatherClient => dio;
}

/// Single shared Dio instance for all API calls — enables connection pooling
/// and avoids repeated TCP+TLS handshakes.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 15);
  return dio;
});

/// Single shared ApiClient for weather-specific requests.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// SharedPreferences initialized once in main() and overridden in
/// ProviderScope so every provider gets instant synchronous access.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});
