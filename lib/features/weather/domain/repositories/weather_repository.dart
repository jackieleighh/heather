import '../entities/forecast.dart';
import '../entities/location_info.dart';

abstract class WeatherRepository {
  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
  });

  Future<LocationInfo> getCurrentLocation();
}
