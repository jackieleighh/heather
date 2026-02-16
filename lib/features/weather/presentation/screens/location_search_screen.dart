import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heather/features/weather/presentation/widgets/logo_overlay.dart';

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
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 54, 0),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.cream,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Add Location',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.quicksand(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cream,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: _isFocused
                            ? AppColors.cream.withValues(alpha: 0.95)
                            : AppColors.cream.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: _isFocused ? 0.3 : 0.15,
                            ),
                            blurRadius: _isFocused ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(color: AppColors.deepPurple),
                        decoration: InputDecoration(
                          hintText: 'Search for a city...',
                          hintStyle: TextStyle(
                            color: AppColors.deepPurple.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.deepPurple.withValues(alpha: 0.5),
                          ),
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _SearchResults(query: _query)),
                ],
              ),
            ),
            const LogoOverlay(),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerStatefulWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  List<SavedLocation> _lastResults = [];

  @override
  Widget build(BuildContext context) {
    final trimmed = widget.query.trim();

    if (trimmed.length < 2) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Center(
          key: const ValueKey('hint'),
          child: Text(
            'Type a city name to search',
            style: TextStyle(color: AppColors.cream.withValues(alpha: 0.4)),
          ),
        ),
      );
    }

    final results = ref.watch(locationSearchProvider(trimmed));

    return results.when(
      loading: () {
        // Keep showing previous results with a loading bar instead of a spinner
        if (_lastResults.isNotEmpty) {
          return _buildList(_lastResults, loading: true);
        }
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.cream,
            strokeWidth: 3,
          ),
        );
      },
      error: (e, _) => Center(
        child: Text(
          'Yikes! Something went wrong.',
          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
        ),
      ),
      data: (locations) {
        _lastResults = locations;
        if (locations.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Center(
              key: const ValueKey('empty'),
              child: Text(
                'No results found. Try a different search?',
                style:
                    TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
              ),
            ),
          );
        }
        return _buildList(locations);
      },
    );
  }

  Widget _buildList(List<SavedLocation> locations, {bool loading = false}) {
    return Column(
      children: [
        if (loading)
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const LinearProgressIndicator(
              color: AppColors.cream,
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
          ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            itemCount: locations.length,
            itemBuilder: (context, index) =>
                _LocationTile(location: locations[index]),
          ),
        ),
      ],
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
        color: AppColors.cream.withValues(alpha: 0.8),
      ),
      title: Text(
        location.name,
        style: const TextStyle(
          color: AppColors.cream,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(color: AppColors.cream.withValues(alpha: 0.6)),
            )
          : null,
      onTap: () async {
        await ref.read(savedLocationsProvider.notifier).addLocation(location);
        if (context.mounted) Navigator.of(context).maybePop(true);
      },
    );
  }
}
