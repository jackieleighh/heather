import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../sources/geocoding_remote_source.dart';
import '../sources/saved_locations_local_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final GeocodingRemoteSource geocodingSource;
  final SavedLocationsLocalSource localSource;

  LocationRepositoryImpl({
    required this.geocodingSource,
    required this.localSource,
  });

  @override
  Future<List<SavedLocation>> getSavedLocations() {
    return localSource.getLocations();
  }

  @override
  Future<void> saveLocation(SavedLocation location) {
    return localSource.addLocation(location);
  }

  @override
  Future<void> removeLocation(String id) {
    return localSource.removeLocation(id);
  }

  @override
  Future<List<SavedLocation>> searchLocations(String query) {
    return geocodingSource.searchLocations(query);
  }

  Future<void> reorderLocations(List<SavedLocation> locations) {
    return localSource.saveLocations(locations);
  }
}
