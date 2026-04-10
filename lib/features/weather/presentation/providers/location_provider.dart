import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/sources/geocoding_remote_source.dart';
import '../../data/sources/saved_locations_local_source.dart';
import '../../domain/entities/saved_location.dart';

final locationRepositoryProvider = Provider<LocationRepositoryImpl>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LocationRepositoryImpl(
    geocodingSource: GeocodingRemoteSource(dio: apiClient.weatherClient),
    localSource: SavedLocationsLocalSource(),
  );
});

// Seed provider: holds pre-read saved locations for instant display
final savedLocationsSeedProvider =
    StateProvider<List<SavedLocation>?>((_) => null);

final savedLocationsProvider =
    StateNotifierProvider<SavedLocationsNotifier, List<SavedLocation>>((ref) {
  final seed = ref.read(savedLocationsSeedProvider);
  // Defer clearing seed to avoid modifying another provider during initialization
  Future.microtask(() => ref.read(savedLocationsSeedProvider.notifier).state = null);

  return SavedLocationsNotifier(
    repository: ref.watch(locationRepositoryProvider),
    seed: seed,
  );
});

class SavedLocationsNotifier extends StateNotifier<List<SavedLocation>> {
  final LocationRepositoryImpl repository;

  SavedLocationsNotifier({
    required this.repository,
    List<SavedLocation>? seed,
  }) : super(seed ?? []) {
    _load();
  }

  Future<void> _load() async {
    state = await repository.getSavedLocations();
  }

  /// Returns `true` if added, `false` if the limit was reached.
  Future<bool> addLocation(SavedLocation location) async {
    final added = await repository.saveLocation(location);
    if (added) {
      state = await repository.getSavedLocations();
    }
    return added;
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
    FutureProvider.autoDispose.family<List<SavedLocation>, String>((ref, query) async {
  if (query.trim().length < 2) return [];

  // Debounce: wait 300ms. With autoDispose, if the query changes during
  // this delay the old provider instance is disposed and this result is
  // discarded automatically.
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (cancelled) return [];

  final repository = ref.watch(locationRepositoryProvider);
  return repository.searchLocations(query);
});
