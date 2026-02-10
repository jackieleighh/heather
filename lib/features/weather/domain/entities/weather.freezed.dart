// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Weather {
  double get temperature => throw _privateConstructorUsedError;
  double get feelsLike => throw _privateConstructorUsedError;
  int get humidity => throw _privateConstructorUsedError;
  double get windSpeed => throw _privateConstructorUsedError;
  int get weatherCode => throw _privateConstructorUsedError;
  WeatherCondition get condition => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isDay => throw _privateConstructorUsedError;
  double get precipitation => throw _privateConstructorUsedError;
  int get cloudCover => throw _privateConstructorUsedError;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherCopyWith<Weather> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherCopyWith<$Res> {
  factory $WeatherCopyWith(Weather value, $Res Function(Weather) then) =
      _$WeatherCopyWithImpl<$Res, Weather>;
  @useResult
  $Res call({
    double temperature,
    double feelsLike,
    int humidity,
    double windSpeed,
    int weatherCode,
    WeatherCondition condition,
    String description,
    bool isDay,
    double precipitation,
    int cloudCover,
  });
}

/// @nodoc
class _$WeatherCopyWithImpl<$Res, $Val extends Weather>
    implements $WeatherCopyWith<$Res> {
  _$WeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? feelsLike = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? description = null,
    Object? isDay = null,
    Object? precipitation = null,
    Object? cloudCover = null,
  }) {
    return _then(
      _value.copyWith(
            temperature: null == temperature
                ? _value.temperature
                : temperature // ignore: cast_nullable_to_non_nullable
                      as double,
            feelsLike: null == feelsLike
                ? _value.feelsLike
                : feelsLike // ignore: cast_nullable_to_non_nullable
                      as double,
            humidity: null == humidity
                ? _value.humidity
                : humidity // ignore: cast_nullable_to_non_nullable
                      as int,
            windSpeed: null == windSpeed
                ? _value.windSpeed
                : windSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
            weatherCode: null == weatherCode
                ? _value.weatherCode
                : weatherCode // ignore: cast_nullable_to_non_nullable
                      as int,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as WeatherCondition,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isDay: null == isDay
                ? _value.isDay
                : isDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            precipitation: null == precipitation
                ? _value.precipitation
                : precipitation // ignore: cast_nullable_to_non_nullable
                      as double,
            cloudCover: null == cloudCover
                ? _value.cloudCover
                : cloudCover // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeatherImplCopyWith<$Res> implements $WeatherCopyWith<$Res> {
  factory _$$WeatherImplCopyWith(
    _$WeatherImpl value,
    $Res Function(_$WeatherImpl) then,
  ) = __$$WeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double temperature,
    double feelsLike,
    int humidity,
    double windSpeed,
    int weatherCode,
    WeatherCondition condition,
    String description,
    bool isDay,
    double precipitation,
    int cloudCover,
  });
}

/// @nodoc
class __$$WeatherImplCopyWithImpl<$Res>
    extends _$WeatherCopyWithImpl<$Res, _$WeatherImpl>
    implements _$$WeatherImplCopyWith<$Res> {
  __$$WeatherImplCopyWithImpl(
    _$WeatherImpl _value,
    $Res Function(_$WeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? feelsLike = null,
    Object? humidity = null,
    Object? windSpeed = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? description = null,
    Object? isDay = null,
    Object? precipitation = null,
    Object? cloudCover = null,
  }) {
    return _then(
      _$WeatherImpl(
        temperature: null == temperature
            ? _value.temperature
            : temperature // ignore: cast_nullable_to_non_nullable
                  as double,
        feelsLike: null == feelsLike
            ? _value.feelsLike
            : feelsLike // ignore: cast_nullable_to_non_nullable
                  as double,
        humidity: null == humidity
            ? _value.humidity
            : humidity // ignore: cast_nullable_to_non_nullable
                  as int,
        windSpeed: null == windSpeed
            ? _value.windSpeed
            : windSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
        weatherCode: null == weatherCode
            ? _value.weatherCode
            : weatherCode // ignore: cast_nullable_to_non_nullable
                  as int,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as WeatherCondition,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isDay: null == isDay
            ? _value.isDay
            : isDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        precipitation: null == precipitation
            ? _value.precipitation
            : precipitation // ignore: cast_nullable_to_non_nullable
                  as double,
        cloudCover: null == cloudCover
            ? _value.cloudCover
            : cloudCover // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$WeatherImpl implements _Weather {
  const _$WeatherImpl({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.description,
    required this.isDay,
    required this.precipitation,
    required this.cloudCover,
  });

  @override
  final double temperature;
  @override
  final double feelsLike;
  @override
  final int humidity;
  @override
  final double windSpeed;
  @override
  final int weatherCode;
  @override
  final WeatherCondition condition;
  @override
  final String description;
  @override
  final bool isDay;
  @override
  final double precipitation;
  @override
  final int cloudCover;

  @override
  String toString() {
    return 'Weather(temperature: $temperature, feelsLike: $feelsLike, humidity: $humidity, windSpeed: $windSpeed, weatherCode: $weatherCode, condition: $condition, description: $description, isDay: $isDay, precipitation: $precipitation, cloudCover: $cloudCover)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.feelsLike, feelsLike) ||
                other.feelsLike == feelsLike) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.weatherCode, weatherCode) ||
                other.weatherCode == weatherCode) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isDay, isDay) || other.isDay == isDay) &&
            (identical(other.precipitation, precipitation) ||
                other.precipitation == precipitation) &&
            (identical(other.cloudCover, cloudCover) ||
                other.cloudCover == cloudCover));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    temperature,
    feelsLike,
    humidity,
    windSpeed,
    weatherCode,
    condition,
    description,
    isDay,
    precipitation,
    cloudCover,
  );

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      __$$WeatherImplCopyWithImpl<_$WeatherImpl>(this, _$identity);
}

abstract class _Weather implements Weather {
  const factory _Weather({
    required final double temperature,
    required final double feelsLike,
    required final int humidity,
    required final double windSpeed,
    required final int weatherCode,
    required final WeatherCondition condition,
    required final String description,
    required final bool isDay,
    required final double precipitation,
    required final int cloudCover,
  }) = _$WeatherImpl;

  @override
  double get temperature;
  @override
  double get feelsLike;
  @override
  int get humidity;
  @override
  double get windSpeed;
  @override
  int get weatherCode;
  @override
  WeatherCondition get condition;
  @override
  String get description;
  @override
  bool get isDay;
  @override
  double get precipitation;
  @override
  int get cloudCover;

  /// Create a copy of Weather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherImplCopyWith<_$WeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
