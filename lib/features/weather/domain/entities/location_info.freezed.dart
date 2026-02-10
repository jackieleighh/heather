// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocationInfo {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get cityName => throw _privateConstructorUsedError;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationInfoCopyWith<LocationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationInfoCopyWith<$Res> {
  factory $LocationInfoCopyWith(
    LocationInfo value,
    $Res Function(LocationInfo) then,
  ) = _$LocationInfoCopyWithImpl<$Res, LocationInfo>;
  @useResult
  $Res call({double latitude, double longitude, String cityName});
}

/// @nodoc
class _$LocationInfoCopyWithImpl<$Res, $Val extends LocationInfo>
    implements $LocationInfoCopyWith<$Res> {
  _$LocationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? cityName = null,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            cityName: null == cityName
                ? _value.cityName
                : cityName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationInfoImplCopyWith<$Res>
    implements $LocationInfoCopyWith<$Res> {
  factory _$$LocationInfoImplCopyWith(
    _$LocationInfoImpl value,
    $Res Function(_$LocationInfoImpl) then,
  ) = __$$LocationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude, String cityName});
}

/// @nodoc
class __$$LocationInfoImplCopyWithImpl<$Res>
    extends _$LocationInfoCopyWithImpl<$Res, _$LocationInfoImpl>
    implements _$$LocationInfoImplCopyWith<$Res> {
  __$$LocationInfoImplCopyWithImpl(
    _$LocationInfoImpl _value,
    $Res Function(_$LocationInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? cityName = null,
  }) {
    return _then(
      _$LocationInfoImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        cityName: null == cityName
            ? _value.cityName
            : cityName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LocationInfoImpl implements _LocationInfo {
  const _$LocationInfoImpl({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String cityName;

  @override
  String toString() {
    return 'LocationInfo(latitude: $latitude, longitude: $longitude, cityName: $cityName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationInfoImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.cityName, cityName) ||
                other.cityName == cityName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude, cityName);

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationInfoImplCopyWith<_$LocationInfoImpl> get copyWith =>
      __$$LocationInfoImplCopyWithImpl<_$LocationInfoImpl>(this, _$identity);
}

abstract class _LocationInfo implements LocationInfo {
  const factory _LocationInfo({
    required final double latitude,
    required final double longitude,
    required final String cityName,
  }) = _$LocationInfoImpl;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get cityName;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationInfoImplCopyWith<_$LocationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
