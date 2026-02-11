import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/location_repository_impl.dart';
import '../../data/sources/geocoding_remote_source.dart';
import '../../data/sources/saved_locations_local_source.dart';
import '../../domain/entities/saved_location.dart';
import 'weather_provider.dart';

final locationRepositoryProvider = Provider<LocationRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LocationRepositoryImpl(
    geocodingSource: GeocodingRemoteSource(dio: apiClient.weatherClient),
    localSource: SavedLocationsLocalSource(),
  );
});

final savedLocationsProvider =
    StateNotifierProvider<SavedLocationsNotifier, List<SavedLocation>>((ref) {
  return SavedLocationsNotifier(
    repository: ref.watch(locationRepositoryProvider),
  );
});

class SavedLocationsNotifier extends StateNotifier<List<SavedLocation>> {
  final LocationRepositoryImpl repository;

  SavedLocationsNotifier({required this.repository}) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await repository.getSavedLocations();
  }

  Future<void> addLocation(SavedLocation location) async {
    await repository.saveLocation(location);
    state = await repository.getSavedLocations();
  }

  Future<void> removeLocation(String id) async {
    await repository.removeLocation(id);
    state = await repository.getSavedLocations();
  }

  Future<void> reorderLocations(int oldIndex, int newIndex) async {
    final locations = [...state];
    if (newIndex > oldIndex) newIndex--;
    final item = locations.removeAt(oldIndex);
    locations.insert(newIndex, item);
    state = locations;
    await repository.reorderLocations(locations);
  }
}

final locationSearchProvider =
    FutureProvider.family<List<SavedLocation>, String>((ref, query) async {
  if (query.trim().length < 2) return [];
  final repository = ref.watch(locationRepositoryProvider);
  return repository.searchLocations(query);
});
