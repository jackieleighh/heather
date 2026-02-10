import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/saved_location.dart';

part 'geocoding_response_model.g.dart';

@JsonSerializable()
class GeocodingResponseModel {
  @JsonKey(defaultValue: [])
  final List<GeocodingResultModel> results;

  const GeocodingResponseModel({required this.results});

  factory GeocodingResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodingResponseModelToJson(this);

  List<SavedLocation> toEntities() {
    return results
        .map((r) => SavedLocation(
              id: '${r.latitude}_${r.longitude}',
              name: r.name,
              country: r.country ?? '',
              latitude: r.latitude,
              longitude: r.longitude,
              admin1: r.admin1,
            ))
        .toList();
  }
}

@JsonSerializable()
class GeocodingResultModel {
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'latitude')
  final double latitude;
  @JsonKey(name: 'longitude')
  final double longitude;
  @JsonKey(name: 'country')
  final String? country;
  @JsonKey(name: 'admin1')
  final String? admin1;

  const GeocodingResultModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  factory GeocodingResultModel.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodingResultModelToJson(this);
}
