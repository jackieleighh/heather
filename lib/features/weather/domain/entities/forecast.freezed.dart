// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forecast.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Forecast {
  Weather get current => throw _privateConstructorUsedError;
  List<HourlyWeather> get hourly => throw _privateConstructorUsedError;
  List<DailyWeather> get daily => throw _privateConstructorUsedError;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForecastCopyWith<Forecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForecastCopyWith<$Res> {
  factory $ForecastCopyWith(Forecast value, $Res Function(Forecast) then) =
      _$ForecastCopyWithImpl<$Res, Forecast>;
  @useResult
  $Res call({
    Weather current,
    List<HourlyWeather> hourly,
    List<DailyWeather> daily,
  });

  $WeatherCopyWith<$Res> get current;
}

/// @nodoc
class _$ForecastCopyWithImpl<$Res, $Val extends Forecast>
    implements $ForecastCopyWith<$Res> {
  _$ForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? hourly = null,
    Object? daily = null,
  }) {
    return _then(
      _value.copyWith(
            current: null == current
                ? _value.current
                : current // ignore: cast_nullable_to_non_nullable
                      as Weather,
            hourly: null == hourly
                ? _value.hourly
                : hourly // ignore: cast_nullable_to_non_nullable
                      as List<HourlyWeather>,
            daily: null == daily
                ? _value.daily
                : daily // ignore: cast_nullable_to_non_nullable
                      as List<DailyWeather>,
          )
          as $Val,
    );
  }

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeatherCopyWith<$Res> get current {
    return $WeatherCopyWith<$Res>(_value.current, (value) {
      return _then(_value.copyWith(current: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ForecastImplCopyWith<$Res>
    implements $ForecastCopyWith<$Res> {
  factory _$$ForecastImplCopyWith(
    _$ForecastImpl value,
    $Res Function(_$ForecastImpl) then,
  ) = __$$ForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Weather current,
    List<HourlyWeather> hourly,
    List<DailyWeather> daily,
  });

  @override
  $WeatherCopyWith<$Res> get current;
}

/// @nodoc
class __$$ForecastImplCopyWithImpl<$Res>
    extends _$ForecastCopyWithImpl<$Res, _$ForecastImpl>
    implements _$$ForecastImplCopyWith<$Res> {
  __$$ForecastImplCopyWithImpl(
    _$ForecastImpl _value,
    $Res Function(_$ForecastImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? current = null,
    Object? hourly = null,
    Object? daily = null,
  }) {
    return _then(
      _$ForecastImpl(
        current: null == current
            ? _value.current
            : current // ignore: cast_nullable_to_non_nullable
                  as Weather,
        hourly: null == hourly
            ? _value._hourly
            : hourly // ignore: cast_nullable_to_non_nullable
                  as List<HourlyWeather>,
        daily: null == daily
            ? _value._daily
            : daily // ignore: cast_nullable_to_non_nullable
                  as List<DailyWeather>,
      ),
    );
  }
}

/// @nodoc

class _$ForecastImpl implements _Forecast {
  const _$ForecastImpl({
    required this.current,
    required final List<HourlyWeather> hourly,
    required final List<DailyWeather> daily,
  }) : _hourly = hourly,
       _daily = daily;

  @override
  final Weather current;
  final List<HourlyWeather> _hourly;
  @override
  List<HourlyWeather> get hourly {
    if (_hourly is EqualUnmodifiableListView) return _hourly;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourly);
  }

  final List<DailyWeather> _daily;
  @override
  List<DailyWeather> get daily {
    if (_daily is EqualUnmodifiableListView) return _daily;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daily);
  }

  @override
  String toString() {
    return 'Forecast(current: $current, hourly: $hourly, daily: $daily)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForecastImpl &&
            (identical(other.current, current) || other.current == current) &&
            const DeepCollectionEquality().equals(other._hourly, _hourly) &&
            const DeepCollectionEquality().equals(other._daily, _daily));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    current,
    const DeepCollectionEquality().hash(_hourly),
    const DeepCollectionEquality().hash(_daily),
  );

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForecastImplCopyWith<_$ForecastImpl> get copyWith =>
      __$$ForecastImplCopyWithImpl<_$ForecastImpl>(this, _$identity);
}

abstract class _Forecast implements Forecast {
  const factory _Forecast({
    required final Weather current,
    required final List<HourlyWeather> hourly,
    required final List<DailyWeather> daily,
  }) = _$ForecastImpl;

  @override
  Weather get current;
  @override
  List<HourlyWeather> get hourly;
  @override
  List<DailyWeather> get daily;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForecastImplCopyWith<_$ForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
