import 'package:json_annotation/json_annotation.dart';

import '../../../../core/constants/weather_codes.dart';
import '../../domain/entities/weather.dart';

part 'weather_response_model.g.dart';

@JsonSerializable()
class WeatherResponseModel {
  final CurrentWeatherModel current;

  const WeatherResponseModel({required this.current});

  factory WeatherResponseModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherResponseModelToJson(this);

  Weather toEntity() => Weather(
    temperature: current.temperature2m,
    feelsLike: current.apparentTemperature,
    humidity: current.relativeHumidity2m,
    windSpeed: current.windSpeed10m,
    weatherCode: current.weatherCode,
    condition: WeatherCodes.fromWmo(current.weatherCode),
    description: WeatherCodes.description(current.weatherCode),
    isDay: current.isDay == 1,
    precipitation: current.precipitation,
    cloudCover: current.cloudCover,
  );
}

@JsonSerializable()
class CurrentWeatherModel {
  @JsonKey(name: 'temperature_2m')
  final double temperature2m;
  @JsonKey(name: 'relative_humidity_2m')
  final int relativeHumidity2m;
  @JsonKey(name: 'apparent_temperature')
  final double apparentTemperature;
  @JsonKey(name: 'is_day')
  final int isDay;
  @JsonKey(name: 'precipitation', defaultValue: 0.0)
  final double precipitation;
  @JsonKey(name: 'rain', defaultValue: 0.0)
  final double rain;
  @JsonKey(name: 'snowfall', defaultValue: 0.0)
  final double snowfall;
  @JsonKey(name: 'weather_code')
  final int weatherCode;
  @JsonKey(name: 'cloud_cover', defaultValue: 0)
  final int cloudCover;
  @JsonKey(name: 'wind_speed_10m')
  final double windSpeed10m;

  const CurrentWeatherModel({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.isDay,
    required this.precipitation,
    required this.rain,
    required this.snowfall,
    required this.weatherCode,
    required this.cloudCover,
    required this.windSpeed10m,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherModelFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentWeatherModelToJson(this);
}
