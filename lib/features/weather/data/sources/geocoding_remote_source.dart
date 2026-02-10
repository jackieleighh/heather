import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/saved_location.dart';
import '../models/geocoding_response_model.dart';

class GeocodingRemoteSource {
  final Dio dio;

  const GeocodingRemoteSource({required this.dio});

  Future<List<SavedLocation>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await dio.get(
        ApiEndpoints.geocoding(query: Uri.encodeComponent(query.trim())),
      );
      final model = GeocodingResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return model.toEntities();
    } on DioException catch (e) {
      throw WeatherException(
        e.message ?? 'Failed to search locations',
        sassyMessage: "Can't find that place, babe. Try again?",
      );
    }
  }
}
