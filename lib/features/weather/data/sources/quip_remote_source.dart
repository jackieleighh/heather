import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/persona.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/weather.dart';

class QuipRemoteSource {
  final ApiClient apiClient;

  const QuipRemoteSource({required this.apiClient});

  /// Fetches quips for all [locations] in a single Gemini API call.
  Future<List<String>> fetchBatchQuips({
    required List<({Weather weather, String cityName})> locations,
    required String apiKey,
    bool explicit = false,
    Persona persona = Persona.heather,
  }) async {
    assert(locations.isNotEmpty);

    final dio = apiClient.geminiClient(apiKey);
    final systemPrompt = persona.prompt(altTone: explicit);

    // Single location — use simpler prompt for cleaner output
    if (locations.length == 1) {
      final loc = locations.first;
      final prompt =
          '$systemPrompt\n\n'
          'Current weather: ${loc.weather.description}, '
          '${loc.weather.temperature.round()}°F '
          '(feels like ${loc.weather.feelsLike.round()}°F), '
          'wind ${loc.weather.windSpeed.round()} mph, '
          '${loc.weather.humidity}% humidity, '
          'in ${loc.cityName}. '
          '${loc.weather.isDay ? "Daytime" : "Nighttime"}.';

      try {
        final text = await _callGemini(dio, prompt, maxTokens: 60);
        return [_cleanQuip(text)];
      } on DioException catch (e) {
        debugPrint('Gemini API error: ${e.response?.statusCode} '
            '${e.response?.data}');
        throw const QuipException('Failed to generate quip');
      }
    }

    // Multiple locations — numbered prompt, one Gemini call
    final descriptions = locations.indexed.map((pair) {
      final (i, loc) = pair;
      final w = loc.weather;
      return '${i + 1}. ${loc.cityName}: ${w.description}, '
          '${w.temperature.round()}°F (feels like ${w.feelsLike.round()}°F), '
          'wind ${w.windSpeed.round()} mph, ${w.humidity}% humidity. '
          '${w.isDay ? "Daytime" : "Nighttime"}.';
    }).join('\n');

    final prompt =
        '$systemPrompt\n\n'
        'Generate exactly one short quip for EACH location below. '
        'Respond with ONLY the quips, one per line, numbered to match.\n\n'
        '$descriptions';

    try {
      final text = await _callGemini(
        dio,
        prompt,
        maxTokens: 60 * locations.length,
      );
      return _parseBatchResponse(text, locations.length);
    } on DioException catch (e) {
      debugPrint('Gemini API error: ${e.response?.statusCode} '
          '${e.response?.data}');
      throw const QuipException('Failed to generate quips');
    }
  }

  Future<String> _callGemini(
    Dio dio,
    String prompt, {
    required int maxTokens,
  }) async {
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'maxOutputTokens': maxTokens, 'temperature': 1.0},
    };

    final response = await dio.post(
      '/models/gemini-2.0-flash:generateContent',
      data: body,
    );

    final data = response.data as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>;
    if (candidates.isEmpty) throw const QuipException('No quip generated');

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    if (parts.isEmpty) throw const QuipException('Empty quip');

    return (parts[0]['text'] as String).trim();
  }

  List<String> _parseBatchResponse(String text, int expected) {
    final lines = text
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .map(_cleanQuip)
        .toList();

    // Pad with last quip if Gemini returned fewer lines than expected
    while (lines.length < expected) {
      lines.add(lines.isNotEmpty ? lines.last : '');
    }
    return lines.sublist(0, expected);
  }

  String _cleanQuip(String text) {
    if ((text.startsWith('"') && text.endsWith('"')) ||
        (text.startsWith("'") && text.endsWith("'"))) {
      return text.substring(1, text.length - 1);
    }
    return text;
  }
}
