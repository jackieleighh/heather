import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/cached_tile_provider.dart';
import '../../data/sources/nexrad_radar_source.dart';
import '../providers/basemap_style_provider.dart';
import '../providers/radar_provider.dart';
import 'pulsing_dots.dart';

/// Cached text styles.
const _radarHeaderStyle = TextStyle(fontFamily: 'Figtree',
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: AppColors.cream,
);
const _radarErrorStyle = TextStyle(fontFamily: 'Quicksand',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.cream70,
);
const _radarTimeLabelStyle = TextStyle(fontFamily: 'Quicksand',
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: AppColors.cream,
);

class RadarPage extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;

  const RadarPage({super.key, required this.latitude, required this.longitude});

  @override
  ConsumerState<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends ConsumerState<RadarPage> {
  int _currentFrameIndex = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;
  Timer? _refreshTimer;
  bool _initialized = false;
  bool _holdingOnLast = false;

  final LruTileCache _tileCache = LruTileCache(maxEntries: 50);
  final HttpClient _tileHttpClient = HttpClient();

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      ref.invalidate(radarManifestProvider);
    });
  }

  MarkerLayer get _locationMarker => MarkerLayer(
    markers: [
      Marker(
        point: LatLng(widget.latitude, widget.longitude),
        width: 16,
        height: 16,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black30,
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _refreshTimer?.cancel();
    _tileCache.clear();
    _tileHttpClient.close();
    super.dispose();
  }

  void _initializePlayback(int frameCount) {
    if (!_initialized && frameCount > 0) {
      _initialized = true;
      _currentFrameIndex = 0;
    }
  }

  void _togglePlayback(int frameCount) {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startTimer(frameCount);
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _startTimer(int frameCount) {
    _playbackTimer?.cancel();
    _holdingOnLast = false;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      setState(() {
        if (_holdingOnLast) {
          _holdingOnLast = false;
          _currentFrameIndex = 0;
        } else if (_currentFrameIndex >= frameCount - 1) {
          _holdingOnLast = true;
        } else {
          _currentFrameIndex++;
        }
      });
    });
  }

  void _onSliderChanged(double value, int frameCount) {
    if (_isPlaying) {
      _playbackTimer?.cancel();
      setState(() {
        _isPlaying = false;
      });
    }
    setState(() {
      _currentFrameIndex = value.round();
    });
  }

  String _formatRelativeTime(int unixTimestamp) {
    final now = DateTime.now();
    final frameTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    final diff = now.difference(frameTime);

    if (diff.inMinutes.abs() < 5) return 'Now';

    if (diff.isNegative) {
      // Future frame
      final futureDiff = frameTime.difference(now);
      final hours = futureDiff.inHours;
      final minutes = futureDiff.inMinutes % 60;

      if (hours > 0 && minutes > 0) {
        return 'in ${hours}h ${minutes}m';
      } else if (hours > 0) {
        return 'in ${hours}h';
      } else {
        return 'in ${minutes}m';
      }
    }

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m ago';
    } else if (hours > 0) {
      return '${hours}h ago';
    } else {
      return '${minutes}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleAsync = ref.watch(basemapStyleProvider);
    final manifestAsync = ref.watch(radarManifestProvider);
    final safeArea = MediaQuery.of(context).padding;

    final isLoading = styleAsync.isLoading || manifestAsync.isLoading;
    final hasError = styleAsync.hasError || manifestAsync.hasError;

    return Stack(
      children: [
        // 1. Full-bleed map or loading/error state
        if (isLoading)
          const Center(child: PulsingDots(color: AppColors.cream))
        else if (hasError)
          const Center(
            child: Text('Radar unavailable', style: _radarErrorStyle),
          )
        else
          Builder(
            builder: (context) {
              final style = styleAsync.value!;
              final manifest = manifestAsync.value!;
              _initializePlayback(manifest.frames.length);
              final frame = manifest.frames[_currentFrameIndex];

              return Stack(
                children: [
                  // Full-bleed map
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.latitude,
                        widget.longitude,
                      ),
                      initialZoom: 7.0,
                      minZoom: 3.0,
                      maxZoom: 10.0,
                      backgroundColor: Colors.transparent,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom |
                            InteractiveFlag.pinchMove,
                      ),
                    ),
                    children: [
                      Opacity(
                        opacity: 0.4,
                        child: VectorTileLayer(
                          tileProviders: style.providers,
                          theme: style.theme,
                          sprites: style.sprites,
                          maximumZoom: 14,
                          layerMode: VectorTileLayerMode.vector,
                        ),
                      ),
                      Opacity(
                        opacity: 0.7,
                        child: TileLayer(
                          key: ValueKey(frame.tileUrlTemplate),
                          urlTemplate: frame.tileUrlTemplate,
                          tileProvider: CachedRadarTileProvider(
                            cache: _tileCache,
                            httpClient: _tileHttpClient,
                          ),
                        ),
                      ),
                      _locationMarker,
                    ],
                  ),

                  // 2. Top edge gradient
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.cream06, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Bottom edge gradient
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.cream06, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Left button (location) frosted glass background
                  Positioned(
                    top: safeArea.top + (Platform.isIOS ? -4 : 8),
                    left: 16,
                    child: IgnorePointer(
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cream06,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cream08),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Right button (settings) frosted glass background
                  Positioned(
                    top: safeArea.top + (Platform.isIOS ? -4 : 8),
                    right: 16,
                    child: IgnorePointer(
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.cream06,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cream08),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 6. Radar title (matches other page headers)
                  Positioned(
                    top: safeArea.top,
                    right: 70,
                    height: 62,
                    child: const Center(
                      child: Text('Radar', style: _radarHeaderStyle),
                    ),
                  ),

                  // 7. Frosted glass control bar
                  Positioned(
                    bottom: safeArea.bottom + 16,
                    left: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cream06,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cream08),
                          ),
                          child: _ControlBar(
                            frame: frame,
                            frameCount: manifest.frames.length,
                            currentIndex: _currentFrameIndex,
                            nowIndex: manifest.nowIndex,
                            isPlaying: _isPlaying,
                            formatRelativeTime: _formatRelativeTime,
                            onSliderChanged: (value) =>
                                _onSliderChanged(
                                  value,
                                  manifest.frames.length,
                                ),
                            onPlayPause: () =>
                                _togglePlayback(manifest.frames.length),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ControlBar extends StatelessWidget {
  final RadarFrame frame;
  final int frameCount;
  final int currentIndex;
  final int nowIndex;
  final bool isPlaying;
  final String Function(int) formatRelativeTime;
  final ValueChanged<double> onSliderChanged;
  final VoidCallback onPlayPause;

  const _ControlBar({
    required this.frame,
    required this.frameCount,
    required this.currentIndex,
    required this.nowIndex,
    required this.isPlaying,
    required this.formatRelativeTime,
    required this.onSliderChanged,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = formatRelativeTime(frame.time);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 6, 0),
      child: Row(
        children: [
          Text(timeLabel, style: _radarTimeLabelStyle),
          const SizedBox(width: 4),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const trackPadding = 14.0;
                final trackWidth = constraints.maxWidth - trackPadding * 2;
                final nowFraction = frameCount > 1
                    ? nowIndex / (frameCount - 1)
                    : 0.5;
                final nowX = trackPadding + nowFraction * trackWidth;

                return Stack(
                  children: [
                    SliderTheme(
                      data: const SliderThemeData(
                        activeTrackColor: AppColors.cream80,
                        inactiveTrackColor: AppColors.cream20,
                        thumbColor: AppColors.cream,
                        overlayColor: AppColors.cream10,
                        trackHeight: 1.5,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 4,
                        ),
                      ),
                      child: Slider(
                        value: currentIndex.toDouble(),
                        min: 0,
                        max: (frameCount - 1).toDouble(),
                        divisions: frameCount > 1 ? frameCount - 1 : null,
                        onChanged: onSliderChanged,
                      ),
                    ),
                    // "Now" indicator
                    Positioned(
                      left: nowX - 1,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          GestureDetector(
            onTap: onPlayPause,
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.cream80,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
