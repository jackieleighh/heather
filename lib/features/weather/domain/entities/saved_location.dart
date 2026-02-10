import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_location.freezed.dart';
part 'saved_location.g.dart';

@freezed
class SavedLocation with _$SavedLocation {
  const factory SavedLocation({
    required String id,
    required String name,
    required String country,
    required double latitude,
    required double longitude,
    String? admin1,
  }) = _SavedLocation;

  factory SavedLocation.fromJson(Map<String, dynamic> json) =>
      _$SavedLocationFromJson(json);
}
