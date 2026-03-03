import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/nexrad_radar_source.dart';

final radarManifestProvider = FutureProvider<RadarManifest>((ref) async {
  return NexradRadarSource().buildManifest();
});
