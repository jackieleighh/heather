import 'package:json_annotation/json_annotation.dart';

import '../../../../core/constants/weather_codes.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/entities/forecast.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/entities/minutely_weather.dart';
import '../../domain/entities/weather.dart';

part 'forecast_response_model.g.dart';

@JsonSerializable()
class ForecastResponseModel {
  final CurrentWeatherModel current;
  final HourlyResponseModel hourly;
  final DailyResponseModel daily;
  @JsonKey(name: 'minutely_15')
  final Minutely15ResponseModel? minutely15;
  @JsonKey(name: 'utc_offset_seconds', defaultValue: 0)
  final int utcOffsetSeconds;

  const ForecastResponseModel({
    required this.current,
    required this.hourly,
    required this.daily,
    this.minutely15,
    required this.utcOffsetSeconds,
  });

  factory ForecastResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastResponseModelToJson(this);

  Forecast toEntity() {
    final deviceNow = DateTime.now();
    final locationOffset = Duration(seconds: utcOffsetSeconds);
    final now = deviceNow.add(locationOffset - deviceNow.timeZoneOffset);

    final hourlyEntities = <HourlyWeather>[];
    final hourlyAllEntities = <HourlyWeather>[];
    for (var i = 0; i < hourly.time.length; i++) {
      final time = DateTime.parse(hourly.time[i]);
      final entity = HourlyWeather(
        time: time,
        temperature: hourly.temperature2m[i],
        precipitationProbability: hourly.precipitationProbability[i],
        weatherCode: hourly.weatherCode[i],
        condition: WeatherCodes.fromWmo(hourly.weatherCode[i]),
        windSpeed: hourly.windSpeed10m[i],
        uvIndex: i < hourly.uvIndex.length ? hourly.uvIndex[i] : 0.0,
        feelsLike: i < hourly.apparentTemperature.length
            ? hourly.apparentTemperature[i]
            : 0.0,
        windGusts: i < hourly.windGusts10m.length
            ? hourly.windGusts10m[i]
            : 0.0,
        windDirection: i < hourly.windDirection10m.length
            ? hourly.windDirection10m[i]
            : 0,
        humidity: i < hourly.relativeHumidity2m.length
            ? hourly.relativeHumidity2m[i]
            : 0,
        pressure: i < hourly.surfacePressure.length
            ? hourly.surfacePressure[i]
            : 0.0,
        precipitation: i < hourly.precipitation.length
            ? hourly.precipitation[i] / 25.4
            : 0.0,
        cloudCover: i < hourly.cloudCover.length
            ? hourly.cloudCover[i]
            : 0,
        dewPoint: i < hourly.dewPoint2m.length
            ? hourly.dewPoint2m[i]
            : 0.0,
        visibility: i < hourly.visibility.length
            ? hourly.visibility[i] / 1609.34
            : 0.0,
      );
      hourlyAllEntities.add(entity);
      // Current + future hours only (for hourly forecast page)
      final currentHour = DateTime(now.year, now.month, now.day, now.hour);
      if (time.isBefore(currentHour)) continue;
      if (hourlyEntities.length >= 24) continue;
      hourlyEntities.add(entity);
    }

    final dailyEntities = <DailyWeather>[];
    for (var i = 0; i < daily.time.length; i++) {
      final dayDate = DateTime.parse(daily.time[i]);
      final dayEnd = dayDate.add(const Duration(days: 1));

      // Compute average humidity from hourly data for this day
      final dayHumidities = hourlyAllEntities
          .where((h) => !h.time.isBefore(dayDate) && h.time.isBefore(dayEnd))
          .map((h) => h.humidity)
          .toList();
      final humidityAvg = dayHumidities.isNotEmpty
          ? (dayHumidities.reduce((a, b) => a + b) / dayHumidities.length)
              .round()
          : 0;

      // Derive daily condition from daytime hourly data using severity logic
      final sunrise = DateTime.parse(daily.sunrise[i]);
      final sunset = DateTime.parse(daily.sunset[i]);
      final daytimeHours = hourlyAllEntities
          .where((h) =>
              !h.time.isBefore(sunrise) && h.time.isBefore(sunset))
          .toList();

      // Check if any daytime hour has a clear-ish sky condition
      const sunnyConditions = {
        WeatherCondition.sunny,
        WeatherCondition.mostlySunny,
        WeatherCondition.partlyCloudy,
      };
      final hasSunnyPeriods = daytimeHours.any(
        (h) => sunnyConditions.contains(WeatherCodes.fromWmo(h.weatherCode)),
      );

      // Probability-gate precipitation: demote low-confidence precip to overcast
      final daytimeConditions = daytimeHours.map((h) {
        final condition = WeatherCodes.fromWmo(h.weatherCode);
        if (WeatherCodes.isPrecipitation(condition) &&
            h.precipitationProbability < 50) {
          return WeatherCondition.overcast;
        }
        return condition;
      }).toList();

      late final int dailyCode;
      late final WeatherCondition dailyCondition;
      if (daytimeConditions.isNotEmpty) {
        dailyCondition =
            WeatherCodes.dominantDaytimeCondition(daytimeConditions);
        dailyCode = WeatherCodes.canonicalWmoCode[dailyCondition] ??
            daily.weatherCode[i];
      } else {
        dailyCode = daily.weatherCode[i];
        dailyCondition = WeatherCodes.fromWmo(dailyCode);
      }

      dailyEntities.add(DailyWeather(
        date: dayDate,
        temperatureMax: daily.temperature2mMax[i],
        temperatureMin: daily.temperature2mMin[i],
        weatherCode: dailyCode,
        condition: dailyCondition,
        precipitationSum: daily.precipitationSum[i],
        precipitationProbabilityMax: daily.precipitationProbabilityMax[i],
        sunrise: sunrise,
        sunset: sunset,
        uvIndexMax: i < daily.uvIndexMax.length ? daily.uvIndexMax[i] : 0.0,
        humidityAvg: humidityAvg,
        hasSunnyPeriods: hasSunnyPeriods,
      ));
    }

    final minutelyEntities = <MinutelyWeather>[];
    if (minutely15 != null) {
      for (var i = 0; i < minutely15!.time.length; i++) {
        minutelyEntities.add(MinutelyWeather(
          time: DateTime.parse(minutely15!.time[i]),
          precipitation: i < minutely15!.precipitation.length
              ? minutely15!.precipitation[i]
              : 0.0,
          rain: i < minutely15!.rain.length ? minutely15!.rain[i] : 0.0,
          snowfall: i < minutely15!.snowfall.length
              ? minutely15!.snowfall[i]
              : 0.0,
        ));
      }
    }

    // Derive condition from WMO code
    var condition = WeatherCodes.fromWmo(current.weatherCode);
    var description = WeatherCodes.description(current.weatherCode);
    var weatherCode = current.weatherCode;

    // Override: API reports active precipitation but weather code doesn't
    if (!WeatherCodes.isPrecipitation(condition)) {
      if (current.snowfall > 0) {
        condition = WeatherCondition.snow;
        weatherCode = 71;
        description = WeatherCodes.description(71);
      } else if (current.rain > 2.0) {
        condition = WeatherCondition.heavyRain;
        weatherCode = 65;
        description = WeatherCodes.description(65);
      } else if (current.rain > 0.5) {
        condition = WeatherCondition.rain;
        weatherCode = 61;
        description = WeatherCodes.description(61);
      } else if (current.rain > 0 || current.precipitation > 0) {
        condition = WeatherCondition.drizzle;
        weatherCode = 51;
        description = WeatherCodes.description(51);
      }
    }

    // Cross-reference: if the hourly slot for "now" shows precipitation
    // but the current snapshot doesn't, prefer the hourly code
    final currentSlot = hourlyAllEntities
        .where((h) => !h.time.isAfter(now))
        .lastOrNull;
    if (currentSlot != null &&
        !WeatherCodes.isPrecipitation(condition) &&
        WeatherCodes.isPrecipitation(currentSlot.condition)) {
      condition = currentSlot.condition;
      weatherCode = currentSlot.weatherCode;
      description = WeatherCodes.description(currentSlot.weatherCode);
    }

    return Forecast(
      minutely15: minutelyEntities,
      current: Weather(
        temperature: current.temperature2m,
        feelsLike: current.apparentTemperature,
        humidity: current.relativeHumidity2m,
        windSpeed: current.windSpeed10m,
        weatherCode: weatherCode,
        condition: condition,
        description: description,
        isDay: current.isDay == 1,
        precipitation: current.precipitation,
        cloudCover: current.cloudCover,
        uvIndex: current.uvIndex,
        dewPoint: current.dewPoint2m,
        visibility: current.visibility / 1609.34,
        pressure: current.pressureMsl,
        windGusts: current.windGusts10m,
        windDirection: current.windDirection10m,
      ),
      hourly: hourlyEntities,
      hourlyAll: hourlyAllEntities,
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
  @JsonKey(name: 'uv_index', defaultValue: 0.0)
  final double uvIndex;
  @JsonKey(name: 'dew_point_2m', defaultValue: 0.0)
  final double dewPoint2m;
  @JsonKey(name: 'visibility', defaultValue: 0.0)
  final double visibility;
  @JsonKey(name: 'pressure_msl', defaultValue: 0.0)
  final double pressureMsl;
  @JsonKey(name: 'wind_gusts_10m', defaultValue: 0.0)
  final double windGusts10m;
  @JsonKey(name: 'wind_direction_10m', defaultValue: 0)
  final int windDirection10m;

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
    required this.uvIndex,
    required this.dewPoint2m,
    required this.visibility,
    required this.pressureMsl,
    required this.windGusts10m,
    required this.windDirection10m,
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
  @JsonKey(name: 'uv_index', defaultValue: [])
  final List<double> uvIndex;
  @JsonKey(name: 'apparent_temperature', defaultValue: [])
  final List<double> apparentTemperature;
  @JsonKey(name: 'wind_gusts_10m', defaultValue: [])
  final List<double> windGusts10m;
  @JsonKey(name: 'wind_direction_10m', defaultValue: [])
  final List<int> windDirection10m;
  @JsonKey(name: 'relative_humidity_2m', defaultValue: [])
  final List<int> relativeHumidity2m;
  @JsonKey(name: 'surface_pressure', defaultValue: [])
  final List<double> surfacePressure;
  @JsonKey(name: 'precipitation', defaultValue: [])
  final List<double> precipitation;
  @JsonKey(name: 'cloud_cover', defaultValue: [])
  final List<int> cloudCover;
  @JsonKey(name: 'dew_point_2m', defaultValue: [])
  final List<double> dewPoint2m;
  @JsonKey(name: 'visibility', defaultValue: [])
  final List<double> visibility;

  const HourlyResponseModel({
    required this.time,
    required this.temperature2m,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.uvIndex,
    required this.apparentTemperature,
    required this.windGusts10m,
    required this.windDirection10m,
    required this.relativeHumidity2m,
    required this.surfacePressure,
    required this.precipitation,
    required this.cloudCover,
    required this.dewPoint2m,
    required this.visibility,
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
  @JsonKey(name: 'uv_index_max', defaultValue: [])
  final List<double> uvIndexMax;

  const DailyResponseModel({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });

  factory DailyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DailyResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DailyResponseModelToJson(this);
}

@JsonSerializable()
class Minutely15ResponseModel {
  @JsonKey(name: 'time')
  final List<String> time;
  @JsonKey(name: 'precipitation', defaultValue: [])
  final List<double> precipitation;
  @JsonKey(name: 'rain', defaultValue: [])
  final List<double> rain;
  @JsonKey(name: 'snowfall', defaultValue: [])
  final List<double> snowfall;

  const Minutely15ResponseModel({
    required this.time,
    required this.precipitation,
    required this.rain,
    required this.snowfall,
  });

  factory Minutely15ResponseModel.fromJson(Map<String, dynamic> json) =>
      _$Minutely15ResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$Minutely15ResponseModelToJson(this);
}
