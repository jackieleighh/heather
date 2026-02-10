// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hourly_weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HourlyWeather {
  DateTime get time => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get precipitationProbability => throw _privateConstructorUsedError;
  int get weatherCode => throw _privateConstructorUsedError;
  WeatherCondition get condition => throw _privateConstructorUsedError;
  double get windSpeed => throw _privateConstructorUsedError;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyWeatherCopyWith<HourlyWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyWeatherCopyWith<$Res> {
  factory $HourlyWeatherCopyWith(
    HourlyWeather value,
    $Res Function(HourlyWeather) then,
  ) = _$HourlyWeatherCopyWithImpl<$Res, HourlyWeather>;
  @useResult
  $Res call({
    DateTime time,
    double temperature,
    int precipitationProbability,
    int weatherCode,
    WeatherCondition condition,
    double windSpeed,
  });
}

/// @nodoc
class _$HourlyWeatherCopyWithImpl<$Res, $Val extends HourlyWeather>
    implements $HourlyWeatherCopyWith<$Res> {
  _$HourlyWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? precipitationProbability = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? windSpeed = null,
  }) {
    return _then(
      _value.copyWith(
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            precipitationProbability: null == precipitationProbability
                ? _value.precipitationProbability
                : precipitationProbability // ignore: cast_nullable_to_non_nullable
                      as int,
            weatherCode: null == weatherCode
                ? _value.weatherCode
                : weatherCode // ignore: cast_nullable_to_non_nullable
                      as int,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as WeatherCondition,
            windSpeed: null == windSpeed
                ? _value.windSpeed
                : windSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HourlyWeatherImplCopyWith<$Res>
    implements $HourlyWeatherCopyWith<$Res> {
  factory _$$HourlyWeatherImplCopyWith(
    _$HourlyWeatherImpl value,
    $Res Function(_$HourlyWeatherImpl) then,
  ) = __$$HourlyWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime time,
    double temperature,
    int precipitationProbability,
    int weatherCode,
    WeatherCondition condition,
    double windSpeed,
  });
}

/// @nodoc
class __$$HourlyWeatherImplCopyWithImpl<$Res>
    extends _$HourlyWeatherCopyWithImpl<$Res, _$HourlyWeatherImpl>
    implements _$$HourlyWeatherImplCopyWith<$Res> {
  __$$HourlyWeatherImplCopyWithImpl(
    _$HourlyWeatherImpl _value,
    $Res Function(_$HourlyWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? precipitationProbability = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? windSpeed = null,
  }) {
    return _then(
      _$HourlyWeatherImpl(
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        precipitationProbability: null == precipitationProbability
            ? _value.precipitationProbability
            : precipitationProbability // ignore: cast_nullable_to_non_nullable
                  as int,
        weatherCode: null == weatherCode
            ? _value.weatherCode
            : weatherCode // ignore: cast_nullable_to_non_nullable
                  as int,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as WeatherCondition,
        windSpeed: null == windSpeed
            ? _value.windSpeed
            : windSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$HourlyWeatherImpl implements _HourlyWeather {
  const _$HourlyWeatherImpl({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.condition,
    required this.windSpeed,
  });

  @override
  final DateTime time;
  @override
  final double temperature;
  @override
  final int precipitationProbability;
  @override
  final int weatherCode;
  @override
  final WeatherCondition condition;
  @override
  final double windSpeed;

  @override
  String toString() {
    return 'HourlyWeather(time: $time, temperature: $temperature, precipitationProbability: $precipitationProbability, weatherCode: $weatherCode, condition: $condition, windSpeed: $windSpeed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyWeatherImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(
                  other.precipitationProbability,
                  precipitationProbability,
                ) ||
                other.precipitationProbability == precipitationProbability) &&
            (identical(other.weatherCode, weatherCode) ||
                other.weatherCode == weatherCode) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    time,
    temperature,
    precipitationProbability,
    weatherCode,
    condition,
    windSpeed,
  );

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyWeatherImplCopyWith<_$HourlyWeatherImpl> get copyWith =>
      __$$HourlyWeatherImplCopyWithImpl<_$HourlyWeatherImpl>(this, _$identity);
}

abstract class _HourlyWeather implements HourlyWeather {
  const factory _HourlyWeather({
    required final DateTime time,
    required final double temperature,
    required final int precipitationProbability,
    required final int weatherCode,
    required final WeatherCondition condition,
    required final double windSpeed,
  }) = _$HourlyWeatherImpl;

  @override
  DateTime get time;
  @override
  double get temperature;
  @override
  int get precipitationProbability;
  @override
  int get weatherCode;
  @override
  WeatherCondition get condition;
  @override
  double get windSpeed;

  /// Create a copy of HourlyWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyWeatherImplCopyWith<_$HourlyWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
