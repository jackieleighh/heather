import 'package:json_annotation/json_annotation.dart';

import '../../../../core/constants/weather_codes.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/entities/weather.dart';

part 'forecast_response_model.g.dart';

@JsonSerializable()
class ForecastResponseModel {
  final CurrentWeatherModel current;
  final HourlyResponseModel hourly;
  final DailyResponseModel daily;
  @JsonKey(name: 'utc_offset_seconds', defaultValue: 0)
  final int utcOffsetSeconds;

  const ForecastResponseModel({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.utcOffsetSeconds,
  });

  factory ForecastResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastResponseModelToJson(this);

  Forecast toEntity() {
    final now = DateTime.now();

    final hourlyEntities = <HourlyWeather>[];
    for (var i = 0; i < hourly.time.length; i++) {
      final time = DateTime.parse(hourly.time[i]);
      if (time.isBefore(now)) continue;
      if (hourlyEntities.length >= 24) break;
      hourlyEntities.add(HourlyWeather(
        time: time,
        temperature: hourly.temperature2m[i],
        precipitationProbability: hourly.precipitationProbability[i],
        weatherCode: hourly.weatherCode[i],
        condition: WeatherCodes.fromWmo(hourly.weatherCode[i]),
        windSpeed: hourly.windSpeed10m[i],
      ));
    }

    final dailyEntities = <DailyWeather>[];
    for (var i = 0; i < daily.time.length; i++) {
      dailyEntities.add(DailyWeather(
        date: DateTime.parse(daily.time[i]),
        temperatureMax: daily.temperature2mMax[i],
        temperatureMin: daily.temperature2mMin[i],
        weatherCode: daily.weatherCode[i],
        condition: WeatherCodes.fromWmo(daily.weatherCode[i]),
        precipitationSum: daily.precipitationSum[i],
        precipitationProbabilityMax: daily.precipitationProbabilityMax[i],
        sunrise: DateTime.parse(daily.sunrise[i]),
        sunset: DateTime.parse(daily.sunset[i]),
      ));
    }

    return Forecast(
      current: Weather(
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
      ),
      hourly: hourlyEntities,
      daily: dailyEntities,
      utcOffsetSeconds: utcOffsetSeconds,
    );
  }
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

@JsonSerializable()
class HourlyResponseModel {
  @JsonKey(name: 'time')
  final List<String> time;
  @JsonKey(name: 'temperature_2m')
  final List<double> temperature2m;
  @JsonKey(name: 'precipitation_probability')
  final List<int> precipitationProbability;
  @JsonKey(name: 'weather_code')
  final List<int> weatherCode;
  @JsonKey(name: 'wind_speed_10m')
  final List<double> windSpeed10m;

  const HourlyResponseModel({
    required this.time,
    required this.temperature2m,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  factory HourlyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HourlyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyResponseModelToJson(this);
}

@JsonSerializable()
class DailyResponseModel {
  @JsonKey(name: 'time')
  final List<String> time;
  @JsonKey(name: 'weather_code')
  final List<int> weatherCode;
  @JsonKey(name: 'temperature_2m_max')
  final List<double> temperature2mMax;
  @JsonKey(name: 'temperature_2m_min')
  final List<double> temperature2mMin;
  @JsonKey(name: 'precipitation_sum')
  final List<double> precipitationSum;
  @JsonKey(name: 'precipitation_probability_max')
  final List<int> precipitationProbabilityMax;
  final List<String> sunrise;
  final List<String> sunset;

  const DailyResponseModel({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DailyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyResponseModelToJson(this);
}
