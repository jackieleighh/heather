import '../entities/forecast.dart';
import '../entities/location_info.dart';
import '../entities/weather.dart';

abstract class WeatherRepository {
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  });

  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
  });

  Future<LocationInfo> getCurrentLocation();
}
