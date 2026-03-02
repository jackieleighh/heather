import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/forecast_response_model.dart';

class WeatherRemoteSource {
  final Dio dio;

  const WeatherRemoteSource({required this.dio});

  Future<ForecastResponseModel> fetchForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.forecast(latitude: latitude, longitude: longitude),
      );
      return ForecastResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw WeatherException(
        e.message ?? 'Failed to fetch forecast',
        sassyMessage:
            'Ugh, the weather gods are ghosting me right now. '
            'Try again in a sec, babe!',
      );
    }
  }

  Future<Map<String, ForecastResponseModel>> fetchForecastBatch({
    required List<({String id, double latitude, double longitude})> locations,
  }) async {
    if (locations.isEmpty) return {};
    try {
      final response = await dio.get(
        ApiEndpoints.forecastBatch(
          latitudes: locations.map((l) => l.latitude).toList(),
          longitudes: locations.map((l) => l.longitude).toList(),
        ),
      );

      final results = <String, ForecastResponseModel>{};

      if (locations.length == 1) {
        // Single location: API returns a plain object
        results[locations.first.id] = ForecastResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        // Multiple locations: API returns an array
        final list = response.data as List<dynamic>;
        for (var i = 0; i < list.length; i++) {
          results[locations[i].id] = ForecastResponseModel.fromJson(
            list[i] as Map<String, dynamic>,
          );
        }
      }

      return results;
    } on DioException catch (e) {
      throw WeatherException(
        e.message ?? 'Failed to fetch forecasts',
        sassyMessage:
            'Ugh, the weather gods are ghosting me right now. '
            'Try again in a sec, babe!',
      );
    }
  }
}
