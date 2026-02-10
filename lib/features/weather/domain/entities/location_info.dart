import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_info.freezed.dart';

@freezed
class LocationInfo with _$LocationInfo {
  const factory LocationInfo({
    required double latitude,
    required double longitude,
    required String cityName,
  }) = _LocationInfo;
}
