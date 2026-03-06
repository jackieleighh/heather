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
    return results.map((r) => r.toEntity()).toList();
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
  @JsonKey(name: 'population')
  final int? population;

  const GeocodingResultModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
    this.population,
  });

  factory GeocodingResultModel.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodingResultModelToJson(this);

  SavedLocation toEntity() => SavedLocation(
        id: '${latitude}_$longitude',
        name: name,
        country: country ?? '',
        latitude: latitude,
        longitude: longitude,
        admin1: admin1,
      );
}
