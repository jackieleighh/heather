import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
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

  @override
  void dispose() {
    _playbackTimer?.cancel();
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
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
            // Map
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: manifestAsync.when(
                  loading: () => Container(
                    color: AppColors.cream.withValues(alpha: 0.25),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cream,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  error: (_, _) => Container(
                    color: AppColors.cream.withValues(alpha: 0.25),
                    child: Center(
                      child: Text(
                        'Radar unavailable',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  data: (manifest) {
                    _initializePlayback(manifest.frames.length);
                    final frame = manifest.frames[_currentFrameIndex];
                    final radarTileUrl =
                        '${manifest.host}${frame.path}/256/{z}/{x}/{y}/6/0_0.png';

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                widget.latitude,
                                widget.longitude,
                              ),
                              initialZoom: 7.0,
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag.all &
                                    ~InteractiveFlag.rotate,
                              ),
                            ),
                            children: [
                              // Light CartoDB base tiles
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                retinaMode:
                                    MediaQuery.of(context).devicePixelRatio >
                                    1.0,
                              ),
                              // RainViewer radar overlay
                              Opacity(
                                opacity: 0.6,
                                child: TileLayer(
                                  key: ValueKey(frame.path),
                                  urlTemplate: radarTileUrl,
                                ),
                              ),
                              // Location marker
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      widget.latitude,
                                      widget.longitude,
                                    ),
                                    width: 16,
                                    height: 16,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.cream,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Control bar
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45)),
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                timeLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            // Slider + now indicator + play button
            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Slider's track is inset by the overlay radius (24px each side)
                      const trackPadding = 24.0;
                      final trackWidth =
                          constraints.maxWidth - trackPadding * 2;
                      final nowFraction = frameCount > 1
                          ? nowIndex / (frameCount - 1)
                          : 0.5;
                      final nowX =
                          trackPadding + nowFraction * trackWidth;

                      return Stack(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor:
                                  Colors.white.withValues(alpha: 0.85),
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.25),
                              thumbColor: Colors.white,
                              overlayColor:
                                  Colors.white.withValues(alpha: 0.15),
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: currentIndex.toDouble(),
                              min: 0,
                              max: (frameCount - 1).toDouble(),
                              divisions: frameCount - 1,
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
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.7),
                                    borderRadius:
                                        BorderRadius.circular(1),
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
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 28,
                  ),
                ),
              ],
            ),
            // "Now" label under slider right end
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Text(
                        'Now',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
