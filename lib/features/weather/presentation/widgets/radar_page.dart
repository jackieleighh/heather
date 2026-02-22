import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/cached_tile_provider.dart';
import '../../data/sources/rainviewer_remote_source.dart';
import '../providers/radar_provider.dart';

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
  bool _initialized = false;
  bool _holdingOnLast = false;

  final Map<String, Uint8List> _tileCache = {};
  final HttpClient _tileHttpClient = HttpClient();
  MarkerLayer get _locationMarker => MarkerLayer(
    markers: [
      Marker(
        point: LatLng(widget.latitude, widget.longitude),
        width: 16,
        height: 16,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
    final manifestAsync = ref.watch(rainViewerManifestProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 26, 16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(right: 44),
              child: SizedBox(
                height: 62,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Radar',
                    style: GoogleFonts.quicksand(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Radar map
            Expanded(
              child: _MapCard(
                child: manifestAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.cream,
                      strokeWidth: 3,
                    ),
                  ),
                  error: (_, _) => Center(
                    child: Text(
                      'Radar unavailable',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  data: (manifest) {
                    _initializePlayback(manifest.frames.length);
                    final frame = manifest.frames[_currentFrameIndex];
                    final radarTileUrl =
                        '${manifest.host}${frame.path}/256/{z}/{x}/{y}/1/0_0.png';

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                widget.latitude,
                                widget.longitude,
                              ),
                              initialZoom: 7.0,
                              minZoom: 3.0,
                              maxZoom: 12.0,
                              backgroundColor: Colors.transparent,
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              Opacity(
                                opacity: 0.45,
                                child: TileLayer(
                                  urlTemplate:
                                      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  retinaMode:
                                      MediaQuery.of(context).devicePixelRatio >
                                      1.0,
                                ),
                              ),
                              Opacity(
                                opacity: 0.7,
                                child: TileLayer(
                                  key: ValueKey(frame.path),
                                  urlTemplate: radarTileUrl,
                                  tileProvider: CachedRadarTileProvider(
                                    cache: _tileCache,
                                    httpClient: _tileHttpClient,
                                  ),
                                ),
                              ),
                              _locationMarker,
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: _ControlBar(
                              frame: frame,
                              frameCount: manifest.frames.length,
                              currentIndex: _currentFrameIndex,
                              nowIndex: manifest.nowIndex,
                              isPlaying: _isPlaying,
                              formatRelativeTime: _formatRelativeTime,
                              onSliderChanged: (value) => _onSliderChanged(
                                value,
                                manifest.frames.length,
                              ),
                              onPlayPause: () =>
                                  _togglePlayback(manifest.frames.length),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.midnightPurple.withValues(alpha: 0.45),
      ),
      padding: const EdgeInsets.fromLTRB(12, 4, 6, 0),
      child: Row(
        children: [
          Text(
            timeLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
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
                      data: SliderThemeData(
                        activeTrackColor: AppColors.cream.withValues(
                          alpha: 0.8,
                        ),
                        inactiveTrackColor: AppColors.cream.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: AppColors.cream,
                        overlayColor: AppColors.cream.withValues(alpha: 0.1),
                        trackHeight: 1.5,
                        thumbShape: const RoundSliderThumbShape(
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
              color: AppColors.cream.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final Widget child;

  const _MapCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cream.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          // Subtle tint overlay to blend with app palette
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.teal.withValues(alpha: 0.04),
                      AppColors.vibrantPurple.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Subtle edge fade
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _EdgeFadePainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgeFadePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const fade = 18.0;
    const edgeColor = Color(0x18808895);
    const clear = Color(0x00808895);

    // Top
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, fade),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [edgeColor, clear],
        ).createShader(Rect.fromLTWH(0, 0, size.width, fade)),
    );
    // Bottom
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - fade, size.width, fade),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [edgeColor, clear],
        ).createShader(Rect.fromLTWH(0, size.height - fade, size.width, fade)),
    );
    // Left
    canvas.drawRect(
      Rect.fromLTWH(0, 0, fade, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [edgeColor, clear],
        ).createShader(Rect.fromLTWH(0, 0, fade, size.height)),
    );
    // Right
    canvas.drawRect(
      Rect.fromLTWH(size.width - fade, 0, fade, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [edgeColor, clear],
        ).createShader(Rect.fromLTWH(size.width - fade, 0, fade, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
