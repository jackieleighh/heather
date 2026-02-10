// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavedLocation _$SavedLocationFromJson(Map<String, dynamic> json) {
  return _SavedLocation.fromJson(json);
}

/// @nodoc
mixin _$SavedLocation {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get admin1 => throw _privateConstructorUsedError;

  /// Serializes this SavedLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedLocationCopyWith<SavedLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedLocationCopyWith<$Res> {
  factory $SavedLocationCopyWith(
    SavedLocation value,
    $Res Function(SavedLocation) then,
  ) = _$SavedLocationCopyWithImpl<$Res, SavedLocation>;
  @useResult
  $Res call({
    String id,
    String name,
    String country,
    double latitude,
    double longitude,
    String? admin1,
  });
}

/// @nodoc
class _$SavedLocationCopyWithImpl<$Res, $Val extends SavedLocation>
    implements $SavedLocationCopyWith<$Res> {
  _$SavedLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? admin1 = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            admin1: freezed == admin1
                ? _value.admin1
                : admin1 // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SavedLocationImplCopyWith<$Res>
    implements $SavedLocationCopyWith<$Res> {
  factory _$$SavedLocationImplCopyWith(
    _$SavedLocationImpl value,
    $Res Function(_$SavedLocationImpl) then,
  ) = __$$SavedLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String country,
    double latitude,
    double longitude,
    String? admin1,
  });
}

/// @nodoc
class __$$SavedLocationImplCopyWithImpl<$Res>
    extends _$SavedLocationCopyWithImpl<$Res, _$SavedLocationImpl>
    implements _$$SavedLocationImplCopyWith<$Res> {
  __$$SavedLocationImplCopyWithImpl(
    _$SavedLocationImpl _value,
    $Res Function(_$SavedLocationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? country = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? admin1 = freezed,
  }) {
    return _then(
      _$SavedLocationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        admin1: freezed == admin1
            ? _value.admin1
            : admin1 // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedLocationImpl implements _SavedLocation {
  const _$SavedLocationImpl({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  factory _$SavedLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedLocationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String country;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? admin1;

  @override
  String toString() {
    return 'SavedLocation(id: $id, name: $name, country: $country, latitude: $latitude, longitude: $longitude, admin1: $admin1)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedLocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.admin1, admin1) || other.admin1 == admin1));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, country, latitude, longitude, admin1);

  /// Create a copy of SavedLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedLocationImplCopyWith<_$SavedLocationImpl> get copyWith =>
      __$$SavedLocationImplCopyWithImpl<_$SavedLocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedLocationImplToJson(this);
  }
}

abstract class _SavedLocation implements SavedLocation {
  const factory _SavedLocation({
    required final String id,
    required final String name,
    required final String country,
    required final double latitude,
    required final double longitude,
    final String? admin1,
  }) = _$SavedLocationImpl;

  factory _SavedLocation.fromJson(Map<String, dynamic> json) =
      _$SavedLocationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get country;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get admin1;

  /// Create a copy of SavedLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedLocationImplCopyWith<_$SavedLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
