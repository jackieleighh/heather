import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: AppColors.magenta,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
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
                          IconButton(
                            onPressed: () => context.push('/settings'),
                            icon: Icon(
                              Icons.settings_outlined,
                              color: AppColors.cream.withValues(alpha: 0.6),
                              size: 24,
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
                  if (_query.trim().length >= 2)
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

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(locationSearchProvider(query));

    return results.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.cream),
      ),
      error: (e, _) => Center(
        child: Text(
          'Yikes! Something went wrong.',
          style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
        ),
      ),
      data: (locations) {
        if (locations.isEmpty) {
          return Center(
            child: Text(
              'No results found. Try a different search?',
              style: TextStyle(color: AppColors.cream.withValues(alpha: 0.7)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          itemCount: locations.length,
          itemBuilder: (context, index) =>
              _LocationTile(location: locations[index]),
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
      onTap: () {
        ref.read(savedLocationsProvider.notifier).addLocation(location);
        Navigator.of(context).maybePop();
      },
    );
  }
}
