import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/forecast_response_model.dart';
import '../models/weather_response_model.dart';

class WeatherRemoteSource {
  final Dio dio;

  const WeatherRemoteSource({required this.dio});

  Future<WeatherResponseModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.weather(latitude: latitude, longitude: longitude),
      );
      return WeatherResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw WeatherException(
        e.message ?? 'Failed to fetch weather',
        sassyMessage:
            'Ugh, the weather gods are ghosting me right now. '
            'Try again in a sec, babe!',
      );
    }
  }

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
}
