// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocoding_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeocodingResponseModel _$GeocodingResponseModelFromJson(
  Map<String, dynamic> json,
) => GeocodingResponseModel(
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => GeocodingResultModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$GeocodingResponseModelToJson(
  GeocodingResponseModel instance,
) => <String, dynamic>{'results': instance.results};

GeocodingResultModel _$GeocodingResultModelFromJson(
  Map<String, dynamic> json,
) => GeocodingResultModel(
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  country: json['country'] as String?,
  admin1: json['admin1'] as String?,
);

Map<String, dynamic> _$GeocodingResultModelToJson(
  GeocodingResultModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'country': instance.country,
  'admin1': instance.admin1,
};
