import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio() {
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  Dio get weatherClient => dio;

  Dio geminiClient(String apiKey) {
    final gemini = Dio();
    gemini.options.baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
    gemini.options.connectTimeout = const Duration(seconds: 10);
    gemini.options.receiveTimeout = const Duration(seconds: 10);
    gemini.options.queryParameters = {'key': apiKey};
    gemini.options.headers = {'Content-Type': 'application/json'};
    return gemini;
  }
}
