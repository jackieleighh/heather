import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/rainviewer_remote_source.dart';

final rainViewerManifestProvider = FutureProvider<RainViewerManifest>((ref) {
  final source = RainViewerRemoteSource(dio: Dio());
  return source.fetchManifest();
});
