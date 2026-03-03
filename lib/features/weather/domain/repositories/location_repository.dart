import '../entities/saved_location.dart';

abstract class LocationRepository {
  Future<List<SavedLocation>> getSavedLocations();
  Future<bool> saveLocation(SavedLocation location);
  Future<void> removeLocation(String id);
  Future<List<SavedLocation>> searchLocations(String query);
}
