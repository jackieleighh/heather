import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      final placeInfo = await _getPlaceInfo(
        position.latitude,
        position.longitude,
      );

      return LocationInfo(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: placeInfo.cityName,
        countryCode: placeInfo.countryCode,
      );
    } catch (e) {
      if (e is LocationException) rethrow;
      throw LocationException(
        e.toString(),
        sassyMessage: "Yikes! Can't find you, babe. Make sure location is on.",
      );
    }
  }

  static const _keyCityName = 'last_city_name';
  static const _keyCountryCode = 'last_country_code';
  static const _keyCityLat = 'last_city_lat';
  static const _keyCityLon = 'last_city_lon';

  /// ~10 km threshold for reusing cached city name.
  static const _cacheDistanceThreshold = 10000.0;

  Future<({String cityName, String? countryCode})> _getPlaceInfo(
    double lat,
    double lon,
  ) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final cityName = place.locality?.isNotEmpty == true
            ? place.locality!
            : place.subAdministrativeArea ?? place.administrativeArea;
        if (cityName != null && cityName.isNotEmpty) {
          await _cacheCityName(cityName, place.isoCountryCode, lat, lon);
          return (cityName: cityName, countryCode: place.isoCountryCode);
        }
      }
    } catch (_) {}

    // Reverse geocoding failed or returned no useful name — try cache.
    return _getCachedCityName(lat, lon);
  }

  Future<void> _cacheCityName(
    String cityName,
    String? countryCode,
    double lat,
    double lon,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCityName, cityName);
    if (countryCode != null) {
      await prefs.setString(_keyCountryCode, countryCode);
    }
    await prefs.setDouble(_keyCityLat, lat);
    await prefs.setDouble(_keyCityLon, lon);
  }

  Future<({String cityName, String? countryCode})> _getCachedCityName(
    double lat,
    double lon,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString(_keyCityName);
      final cachedLat = prefs.getDouble(_keyCityLat);
      final cachedLon = prefs.getDouble(_keyCityLon);

      if (cachedName != null && cachedLat != null && cachedLon != null) {
        final distance = Geolocator.distanceBetween(
          lat,
          lon,
          cachedLat,
          cachedLon,
        );
        if (distance <= _cacheDistanceThreshold) {
          return (
            cityName: cachedName,
            countryCode: prefs.getString(_keyCountryCode),
          );
        }
      }
    } catch (_) {}
    return (cityName: 'Current Location', countryCode: null);
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

    // "whileInUse" is sufficient for foreground weather loading.
    // "always" upgrades for background widgets should be prompted contextually,
    // not on every launch (requestPermission blocks on a system dialog).
  }
}
