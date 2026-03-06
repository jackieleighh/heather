import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/saved_location.dart';
import '../models/geocoding_response_model.dart';

class GeocodingRemoteSource {
  final Dio dio;

  const GeocodingRemoteSource({required this.dio});

  Future<List<SavedLocation>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    String? qualifier;

    try {
      // Try the full query first
      var results = await _fetchResults(trimmed);

      // If no results and query contains a comma or space, retry with just
      // the city portion and use the rest as a filter for state/country.
      if (results.isEmpty) {
        final parts = trimmed.split(RegExp(r'[,\s]+'));
        if (parts.length > 1) {
          // Try progressively shorter prefixes to handle multi-word city
          // names like "New York" — drop one word at a time from the end.
          for (var wordCount = parts.length - 1;
              wordCount >= 1 && results.isEmpty;
              wordCount--) {
            final cityPart = parts.sublist(0, wordCount).join(' ');
            results = await _fetchResults(cityPart);
          }

          qualifier =
              parts.sublist(1).join(' ').toLowerCase().replaceAll(',', '').trim();
        }
      }

      // Sort results: qualifier match first, then by population descending.
      if (results.isNotEmpty) {
        results.sort((a, b) {
          // Qualifier match takes top priority
          if (qualifier != null && qualifier.isNotEmpty) {
            final aMatch = _matchesQualifier(a, qualifier);
            final bMatch = _matchesQualifier(b, qualifier);
            if (aMatch && !bMatch) return -1;
            if (!aMatch && bMatch) return 1;
          }

          // Higher population first (null treated as 0)
          return (b.population ?? 0).compareTo(a.population ?? 0);
        });
      }

      return results.map((r) => r.toEntity()).toList();
    } on DioException catch (e) {
      throw WeatherException(
        e.message ?? 'Failed to search locations',
        sassyMessage: "Can't find that place, babe. Try again?",
      );
    }
  }

  Future<List<GeocodingResultModel>> _fetchResults(String query) async {
    final response = await dio.get(
      ApiEndpoints.geocoding(query: Uri.encodeComponent(query)),
    );
    final model = GeocodingResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    return model.results;
  }

  bool _matchesQualifier(GeocodingResultModel result, String qualifier) {
    final admin1 = result.admin1?.toLowerCase() ?? '';
    final country = (result.country ?? '').toLowerCase();
    return admin1.startsWith(qualifier) || country.startsWith(qualifier);
  }
}
