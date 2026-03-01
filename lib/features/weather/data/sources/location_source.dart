import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/location_info.dart';

class LocationSource {
  Future<LocationInfo> getCurrentLocation() async {
    await _ensurePermission();

    try {
      // Try last known position first (instant, works well on emulators)
      var position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
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
        sassyMessage: "Yikes! Can't find you, babe. Make sure location is on.",
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

  Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationPermissionException(
        'Location services disabled',
        sassyMessage:
            'Babe, your location is turned off! '
            'Go to Settings and turn it on so Heather can find you.',
        isServiceDisabled: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Location permission permanently denied',
        sassyMessage:
            "Babe, I can't tell you the weather if I don't know "
            'where you are! Go to Settings and enable location for Heather.',
      );
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      throw const LocationPermissionException(
        'Location permission denied',
        sassyMessage:
            "Babe, I can't tell you the weather if I don't know "
            'where you are! Enable location, please?',
      );
    }

    // Try to upgrade to "always" for background widget updates
    if (permission == LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
      // If denied, whileInUse still works for foreground — no error needed
    }
  }
}
