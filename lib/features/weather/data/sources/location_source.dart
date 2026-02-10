import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/location_info.dart';

class LocationSource {
  Future<LocationInfo> getCurrentLocation() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw const LocationException(
        'Location permission denied',
        sassyMessage:
            "Babe, I can't tell you the weather if I don't know "
            'where you are! Enable location, pretty please?',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final cityName = await _getCityName(
        position.latitude,
        position.longitude,
      );

      return LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        e.toString(),
        sassyMessage: "Can't find you, bestie! Make sure location is on.",
      );
    }
  }

  Future<String> _getCityName(double lat, double lon) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality?.isNotEmpty == true
            ? place.locality!
            : place.subAdministrativeArea ?? place.administrativeArea ?? '???';
      }
    } catch (_) {}
    return '???';
  }

  Future<bool> _checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
