// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeatherState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      Forecast forecast,
      LocationInfo location,
      String quip,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherStateCopyWith<$Res> {
  factory $WeatherStateCopyWith(
    WeatherState value,
    $Res Function(WeatherState) then,
  ) = _$WeatherStateCopyWithImpl<$Res, WeatherState>;
}

/// @nodoc
class _$WeatherStateCopyWithImpl<$Res, $Val extends WeatherState>
    implements $WeatherStateCopyWith<$Res> {
  _$WeatherStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$WeatherStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'WeatherState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      Forecast forecast,
      LocationInfo location,
      String quip,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements WeatherState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Forecast forecast, LocationInfo location, String quip});

  $ForecastCopyWith<$Res> get forecast;
  $LocationInfoCopyWith<$Res> get location;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$WeatherStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forecast = null,
    Object? location = null,
    Object? quip = null,
  }) {
    return _then(
      _$LoadedImpl(
        forecast: null == forecast
            ? _value.forecast
            : forecast // ignore: cast_nullable_to_non_nullable
                  as Forecast,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationInfo,
        quip: null == quip
            ? _value.quip
            : quip // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ForecastCopyWith<$Res> get forecast {
    return $ForecastCopyWith<$Res>(_value.forecast, (value) {
      return _then(_value.copyWith(forecast: value));
    });
  }

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationInfoCopyWith<$Res> get location {
    return $LocationInfoCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value));
    });
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({
    required this.forecast,
    required this.location,
    required this.quip,
  });

  @override
  final Forecast forecast;
  @override
  final LocationInfo location;
  @override
  final String quip;

  @override
  String toString() {
    return 'WeatherState.loaded(forecast: $forecast, location: $location, quip: $quip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.forecast, forecast) ||
                other.forecast == forecast) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.quip, quip) || other.quip == quip));
  }

  @override
  int get hashCode => Object.hash(runtimeType, forecast, location, quip);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      Forecast forecast,
      LocationInfo location,
      String quip,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(forecast, location, quip);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(forecast, location, quip);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(forecast, location, quip);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements WeatherState {
  const factory _Loaded({
    required final Forecast forecast,
    required final LocationInfo location,
    required final String quip,
  }) = _$LoadedImpl;

  Forecast get forecast;
  LocationInfo get location;
  String get quip;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$WeatherStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'WeatherState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(
      Forecast forecast,
      LocationInfo location,
      String quip,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, LocationInfo location, String quip)?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements WeatherState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of WeatherState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LocationForecastState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(Forecast forecast, String quip) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, String quip)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, String quip)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LocationLoading value) loading,
    required TResult Function(_LocationLoaded value) loaded,
    required TResult Function(_LocationError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LocationLoading value)? loading,
    TResult? Function(_LocationLoaded value)? loaded,
    TResult? Function(_LocationError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LocationLoading value)? loading,
    TResult Function(_LocationLoaded value)? loaded,
    TResult Function(_LocationError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationForecastStateCopyWith<$Res> {
  factory $LocationForecastStateCopyWith(
    LocationForecastState value,
    $Res Function(LocationForecastState) then,
  ) = _$LocationForecastStateCopyWithImpl<$Res, LocationForecastState>;
}

/// @nodoc
class _$LocationForecastStateCopyWithImpl<
  $Res,
  $Val extends LocationForecastState
>
    implements $LocationForecastStateCopyWith<$Res> {
  _$LocationForecastStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LocationLoadingImplCopyWith<$Res> {
  factory _$$LocationLoadingImplCopyWith(
    _$LocationLoadingImpl value,
    $Res Function(_$LocationLoadingImpl) then,
  ) = __$$LocationLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LocationLoadingImplCopyWithImpl<$Res>
    extends _$LocationForecastStateCopyWithImpl<$Res, _$LocationLoadingImpl>
    implements _$$LocationLoadingImplCopyWith<$Res> {
  __$$LocationLoadingImplCopyWithImpl(
    _$LocationLoadingImpl _value,
    $Res Function(_$LocationLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LocationLoadingImpl implements _LocationLoading {
  const _$LocationLoadingImpl();

  @override
  String toString() {
    return 'LocationForecastState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LocationLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(Forecast forecast, String quip) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, String quip)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, String quip)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LocationLoading value) loading,
    required TResult Function(_LocationLoaded value) loaded,
    required TResult Function(_LocationError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LocationLoading value)? loading,
    TResult? Function(_LocationLoaded value)? loaded,
    TResult? Function(_LocationError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LocationLoading value)? loading,
    TResult Function(_LocationLoaded value)? loaded,
    TResult Function(_LocationError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _LocationLoading implements LocationForecastState {
  const factory _LocationLoading() = _$LocationLoadingImpl;
}

/// @nodoc
abstract class _$$LocationLoadedImplCopyWith<$Res> {
  factory _$$LocationLoadedImplCopyWith(
    _$LocationLoadedImpl value,
    $Res Function(_$LocationLoadedImpl) then,
  ) = __$$LocationLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Forecast forecast, String quip});

  $ForecastCopyWith<$Res> get forecast;
}

/// @nodoc
class __$$LocationLoadedImplCopyWithImpl<$Res>
    extends _$LocationForecastStateCopyWithImpl<$Res, _$LocationLoadedImpl>
    implements _$$LocationLoadedImplCopyWith<$Res> {
  __$$LocationLoadedImplCopyWithImpl(
    _$LocationLoadedImpl _value,
    $Res Function(_$LocationLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? forecast = null, Object? quip = null}) {
    return _then(
      _$LocationLoadedImpl(
        forecast: null == forecast
            ? _value.forecast
            : forecast // ignore: cast_nullable_to_non_nullable
                  as Forecast,
        quip: null == quip
            ? _value.quip
            : quip // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ForecastCopyWith<$Res> get forecast {
    return $ForecastCopyWith<$Res>(_value.forecast, (value) {
      return _then(_value.copyWith(forecast: value));
    });
  }
}

/// @nodoc

class _$LocationLoadedImpl implements _LocationLoaded {
  const _$LocationLoadedImpl({required this.forecast, required this.quip});

  @override
  final Forecast forecast;
  @override
  final String quip;

  @override
  String toString() {
    return 'LocationForecastState.loaded(forecast: $forecast, quip: $quip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationLoadedImpl &&
            (identical(other.forecast, forecast) ||
                other.forecast == forecast) &&
            (identical(other.quip, quip) || other.quip == quip));
  }

  @override
  int get hashCode => Object.hash(runtimeType, forecast, quip);

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationLoadedImplCopyWith<_$LocationLoadedImpl> get copyWith =>
      __$$LocationLoadedImplCopyWithImpl<_$LocationLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(Forecast forecast, String quip) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(forecast, quip);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, String quip)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(forecast, quip);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, String quip)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(forecast, quip);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LocationLoading value) loading,
    required TResult Function(_LocationLoaded value) loaded,
    required TResult Function(_LocationError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LocationLoading value)? loading,
    TResult? Function(_LocationLoaded value)? loaded,
    TResult? Function(_LocationError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LocationLoading value)? loading,
    TResult Function(_LocationLoaded value)? loaded,
    TResult Function(_LocationError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _LocationLoaded implements LocationForecastState {
  const factory _LocationLoaded({
    required final Forecast forecast,
    required final String quip,
  }) = _$LocationLoadedImpl;

  Forecast get forecast;
  String get quip;

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationLoadedImplCopyWith<_$LocationLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LocationErrorImplCopyWith<$Res> {
  factory _$$LocationErrorImplCopyWith(
    _$LocationErrorImpl value,
    $Res Function(_$LocationErrorImpl) then,
  ) = __$$LocationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$LocationErrorImplCopyWithImpl<$Res>
    extends _$LocationForecastStateCopyWithImpl<$Res, _$LocationErrorImpl>
    implements _$$LocationErrorImplCopyWith<$Res> {
  __$$LocationErrorImplCopyWithImpl(
    _$LocationErrorImpl _value,
    $Res Function(_$LocationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$LocationErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LocationErrorImpl implements _LocationError {
  const _$LocationErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'LocationForecastState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationErrorImplCopyWith<_$LocationErrorImpl> get copyWith =>
      __$$LocationErrorImplCopyWithImpl<_$LocationErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function(Forecast forecast, String quip) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function(Forecast forecast, String quip)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function(Forecast forecast, String quip)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LocationLoading value) loading,
    required TResult Function(_LocationLoaded value) loaded,
    required TResult Function(_LocationError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LocationLoading value)? loading,
    TResult? Function(_LocationLoaded value)? loaded,
    TResult? Function(_LocationError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LocationLoading value)? loading,
    TResult Function(_LocationLoaded value)? loaded,
    TResult Function(_LocationError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _LocationError implements LocationForecastState {
  const factory _LocationError(final String message) = _$LocationErrorImpl;

  String get message;

  /// Create a copy of LocationForecastState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationErrorImplCopyWith<_$LocationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
