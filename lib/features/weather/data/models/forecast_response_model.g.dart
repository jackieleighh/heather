// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForecastResponseModel _$ForecastResponseModelFromJson(
  Map<String, dynamic> json,
) => ForecastResponseModel(
  current: CurrentWeatherModel.fromJson(
    json['current'] as Map<String, dynamic>,
  ),
  hourly: HourlyResponseModel.fromJson(json['hourly'] as Map<String, dynamic>),
  daily: DailyResponseModel.fromJson(json['daily'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ForecastResponseModelToJson(
  ForecastResponseModel instance,
) => <String, dynamic>{
  'current': instance.current,
  'hourly': instance.hourly,
  'daily': instance.daily,
};

CurrentWeatherModel _$CurrentWeatherModelFromJson(Map<String, dynamic> json) =>
    CurrentWeatherModel(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      isDay: (json['is_day'] as num).toInt(),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      snowfall: (json['snowfall'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num).toInt(),
      cloudCover: (json['cloud_cover'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
    );

Map<String, dynamic> _$CurrentWeatherModelToJson(
  CurrentWeatherModel instance,
) => <String, dynamic>{
  'temperature_2m': instance.temperature2m,
  'relative_humidity_2m': instance.relativeHumidity2m,
  'apparent_temperature': instance.apparentTemperature,
  'is_day': instance.isDay,
  'precipitation': instance.precipitation,
  'rain': instance.rain,
  'snowfall': instance.snowfall,
  'weather_code': instance.weatherCode,
  'cloud_cover': instance.cloudCover,
  'wind_speed_10m': instance.windSpeed10m,
};

HourlyResponseModel _$HourlyResponseModelFromJson(Map<String, dynamic> json) =>
    HourlyResponseModel(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      temperature2m: (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbability:
          (json['precipitation_probability'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      windSpeed10m: (json['wind_speed_10m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$HourlyResponseModelToJson(
  HourlyResponseModel instance,
) => <String, dynamic>{
  'time': instance.time,
  'temperature_2m': instance.temperature2m,
  'precipitation_probability': instance.precipitationProbability,
  'weather_code': instance.weatherCode,
  'wind_speed_10m': instance.windSpeed10m,
};

DailyResponseModel _$DailyResponseModelFromJson(Map<String, dynamic> json) =>
    DailyResponseModel(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperature2mMax: (json['temperature_2m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperature2mMin: (json['temperature_2m_min'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationSum: (json['precipitation_sum'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbabilityMax:
          (json['precipitation_probability_max'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );

Map<String, dynamic> _$DailyResponseModelToJson(DailyResponseModel instance) =>
    <String, dynamic>{
      'time': instance.time,
      'weather_code': instance.weatherCode,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
      'precipitation_sum': instance.precipitationSum,
      'precipitation_probability_max': instance.precipitationProbabilityMax,
    };
