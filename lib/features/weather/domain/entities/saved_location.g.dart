// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedLocationImpl _$$SavedLocationImplFromJson(Map<String, dynamic> json) =>
    _$SavedLocationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
    );

Map<String, dynamic> _$$SavedLocationImplToJson(_$SavedLocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'admin1': instance.admin1,
    };
