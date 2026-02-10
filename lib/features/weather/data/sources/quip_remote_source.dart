import 'package:dio/dio.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/weather.dart';

class QuipRemoteSource {
  final ApiClient apiClient;

  const QuipRemoteSource({required this.apiClient});

  Future<String> fetchQuip({
    required Weather weather,
    required String cityName,
    required String apiKey,
    bool explicit = false,
  }) async {
    try {
      final dio = apiClient.geminiClient(apiKey);
      final systemPrompt =
          explicit ? AppStrings.geminiExplicitPrompt : AppStrings.geminiPrompt;
      final prompt =
          '$systemPrompt\n\n'
          'Current weather: ${weather.description}, '
          '${weather.temperature.round()}°F '
          '(feels like ${weather.feelsLike.round()}°F), '
          'wind ${weather.windSpeed.round()} mph, '
          '${weather.humidity}% humidity, '
          'in $cityName. '
          '${weather.isDay ? "Daytime" : "Nighttime"}.';

      final response = await dio.post(
        '/models/gemini-2.0-flash:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 60, 'temperature': 1.0},
        },
      );

      final data = response.data as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>;
      if (candidates.isEmpty) throw const QuipException('No quip generated');

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      if (parts.isEmpty) throw const QuipException('Empty quip');

      final text = (parts[0]['text'] as String).trim();
      // Strip leading/trailing quotes if present
      final cleaned = text.startsWith('"') || text.startsWith("'")
          ? text.substring(1, text.length - 1)
          : text;
      return cleaned;
    } on DioException {
      throw const QuipException('Failed to generate quip');
    }
  }
}
