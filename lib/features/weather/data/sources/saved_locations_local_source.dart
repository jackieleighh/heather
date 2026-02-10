import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/saved_location.dart';

class SavedLocationsLocalSource {
  static const _key = 'saved_locations';

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

  Future<void> addLocation(SavedLocation location) async {
    final locations = await getLocations();
    if (locations.any((l) => l.id == location.id)) return;
    locations.add(location);
    await saveLocations(locations);
  }

  Future<void> removeLocation(String id) async {
    final locations = await getLocations();
    locations.removeWhere((l) => l.id == id);
    await saveLocations(locations);
  }
}
