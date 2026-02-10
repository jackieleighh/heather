// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyWeather {
  DateTime get date => throw _privateConstructorUsedError;
  double get temperatureMax => throw _privateConstructorUsedError;
  double get temperatureMin => throw _privateConstructorUsedError;
  int get weatherCode => throw _privateConstructorUsedError;
  WeatherCondition get condition => throw _privateConstructorUsedError;
  double get precipitationSum => throw _privateConstructorUsedError;
  int get precipitationProbabilityMax => throw _privateConstructorUsedError;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyWeatherCopyWith<DailyWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyWeatherCopyWith<$Res> {
  factory $DailyWeatherCopyWith(
    DailyWeather value,
    $Res Function(DailyWeather) then,
  ) = _$DailyWeatherCopyWithImpl<$Res, DailyWeather>;
  @useResult
  $Res call({
    DateTime date,
    double temperatureMax,
    double temperatureMin,
    int weatherCode,
    WeatherCondition condition,
    double precipitationSum,
    int precipitationProbabilityMax,
  });
}

/// @nodoc
class _$DailyWeatherCopyWithImpl<$Res, $Val extends DailyWeather>
    implements $DailyWeatherCopyWith<$Res> {
  _$DailyWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? temperatureMax = null,
    Object? temperatureMin = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? precipitationSum = null,
    Object? precipitationProbabilityMax = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            temperatureMax: null == temperatureMax
                ? _value.temperatureMax
                : temperatureMax // ignore: cast_nullable_to_non_nullable
                      as double,
            temperatureMin: null == temperatureMin
                ? _value.temperatureMin
                : temperatureMin // ignore: cast_nullable_to_non_nullable
                      as double,
            weatherCode: null == weatherCode
                ? _value.weatherCode
                : weatherCode // ignore: cast_nullable_to_non_nullable
                      as int,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as WeatherCondition,
            precipitationSum: null == precipitationSum
                ? _value.precipitationSum
                : precipitationSum // ignore: cast_nullable_to_non_nullable
                      as double,
            precipitationProbabilityMax: null == precipitationProbabilityMax
                ? _value.precipitationProbabilityMax
                : precipitationProbabilityMax // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyWeatherImplCopyWith<$Res>
    implements $DailyWeatherCopyWith<$Res> {
  factory _$$DailyWeatherImplCopyWith(
    _$DailyWeatherImpl value,
    $Res Function(_$DailyWeatherImpl) then,
  ) = __$$DailyWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    double temperatureMax,
    double temperatureMin,
    int weatherCode,
    WeatherCondition condition,
    double precipitationSum,
    int precipitationProbabilityMax,
  });
}

/// @nodoc
class __$$DailyWeatherImplCopyWithImpl<$Res>
    extends _$DailyWeatherCopyWithImpl<$Res, _$DailyWeatherImpl>
    implements _$$DailyWeatherImplCopyWith<$Res> {
  __$$DailyWeatherImplCopyWithImpl(
    _$DailyWeatherImpl _value,
    $Res Function(_$DailyWeatherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? temperatureMax = null,
    Object? temperatureMin = null,
    Object? weatherCode = null,
    Object? condition = null,
    Object? precipitationSum = null,
    Object? precipitationProbabilityMax = null,
  }) {
    return _then(
      _$DailyWeatherImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        temperatureMax: null == temperatureMax
            ? _value.temperatureMax
            : temperatureMax // ignore: cast_nullable_to_non_nullable
                  as double,
        temperatureMin: null == temperatureMin
            ? _value.temperatureMin
            : temperatureMin // ignore: cast_nullable_to_non_nullable
                  as double,
        weatherCode: null == weatherCode
            ? _value.weatherCode
            : weatherCode // ignore: cast_nullable_to_non_nullable
                  as int,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as WeatherCondition,
        precipitationSum: null == precipitationSum
            ? _value.precipitationSum
            : precipitationSum // ignore: cast_nullable_to_non_nullable
                  as double,
        precipitationProbabilityMax: null == precipitationProbabilityMax
            ? _value.precipitationProbabilityMax
            : precipitationProbabilityMax // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DailyWeatherImpl implements _DailyWeather {
  const _$DailyWeatherImpl({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.condition,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
  });

  @override
  final DateTime date;
  @override
  final double temperatureMax;
  @override
  final double temperatureMin;
  @override
  final int weatherCode;
  @override
  final WeatherCondition condition;
  @override
  final double precipitationSum;
  @override
  final int precipitationProbabilityMax;

  @override
  String toString() {
    return 'DailyWeather(date: $date, temperatureMax: $temperatureMax, temperatureMin: $temperatureMin, weatherCode: $weatherCode, condition: $condition, precipitationSum: $precipitationSum, precipitationProbabilityMax: $precipitationProbabilityMax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyWeatherImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.temperatureMax, temperatureMax) ||
                other.temperatureMax == temperatureMax) &&
            (identical(other.temperatureMin, temperatureMin) ||
                other.temperatureMin == temperatureMin) &&
            (identical(other.weatherCode, weatherCode) ||
                other.weatherCode == weatherCode) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.precipitationSum, precipitationSum) ||
                other.precipitationSum == precipitationSum) &&
            (identical(
                  other.precipitationProbabilityMax,
                  precipitationProbabilityMax,
                ) ||
                other.precipitationProbabilityMax ==
                    precipitationProbabilityMax));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    temperatureMax,
    temperatureMin,
    weatherCode,
    condition,
    precipitationSum,
    precipitationProbabilityMax,
  );

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyWeatherImplCopyWith<_$DailyWeatherImpl> get copyWith =>
      __$$DailyWeatherImplCopyWithImpl<_$DailyWeatherImpl>(this, _$identity);
}

abstract class _DailyWeather implements DailyWeather {
  const factory _DailyWeather({
    required final DateTime date,
    required final double temperatureMax,
    required final double temperatureMin,
    required final int weatherCode,
    required final WeatherCondition condition,
    required final double precipitationSum,
    required final int precipitationProbabilityMax,
  }) = _$DailyWeatherImpl;

  @override
  DateTime get date;
  @override
  double get temperatureMax;
  @override
  double get temperatureMin;
  @override
  int get weatherCode;
  @override
  WeatherCondition get condition;
  @override
  double get precipitationSum;
  @override
  int get precipitationProbabilityMax;

  /// Create a copy of DailyWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyWeatherImplCopyWith<_$DailyWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
