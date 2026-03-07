import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_limits.dart';
import '../../domain/entities/saved_location.dart';

class SavedLocationsLocalSource {
  static const _key = 'saved_locations';

  /// Reads saved locations from an already-resolved [SharedPreferences].
  static List<SavedLocation> readSync(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SavedLocation>> getLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLocations(List<SavedLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(locations.map((l) => l.toJson()).toList());
    await prefs.setString(_key, json);
  }

  /// Returns `true` if the location was added, `false` if the limit was reached
  /// or the location already exists.
  Future<bool> addLocation(SavedLocation location) async {
    final locations = await getLocations();
    if (locations.any((l) => l.id == location.id)) return false;
    if (locations.length >= maxSavedLocations) return false;
    locations.add(location);
    await saveLocations(locations);
    return true;
  }

  Future<void> removeLocation(String id) async {
    final locations = await getLocations();
    locations.removeWhere((l) => l.id == id);
    await saveLocations(locations);
  }
}
