import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/saved_location.dart';
import '../providers/location_provider.dart';

class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.chartreuse, AppColors.vibrantPurple, AppColors.magenta],
          ),
        ),
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Location',
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _query.trim().length < 2
                  ? _HintView()
                  : _SearchResults(query: _query),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _HintView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Search for a city to add to your locations.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(locationSearchProvider(query));

    return results.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
      error: (e, _) => Center(
        child: Text(
          'Something went wrong, bestie.',
          style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
        ),
      ),
      data: (locations) {
        if (locations.isEmpty) {
          return Center(
            child: Text(
              'No results found. Try a different search?',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          itemCount: locations.length,
          itemBuilder: (context, index) => _LocationTile(
            location: locations[index],
          ),
        );
      },
    );
  }
}

class _LocationTile extends ConsumerWidget {
  final SavedLocation location;

  const _LocationTile({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = [
      if (location.admin1 != null && location.admin1!.isNotEmpty)
        location.admin1!,
      if (location.country.isNotEmpty) location.country,
    ].join(', ');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.location_on_outlined,
        color: Colors.black.withValues(alpha: 0.8),
      ),
      title: Text(
        location.name,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
            )
          : null,
      onTap: () {
        ref.read(savedLocationsProvider.notifier).addLocation(location);
        Navigator.of(context).maybePop();
      },
    );
  }
}
