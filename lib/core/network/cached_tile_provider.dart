import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

/// A [TileProvider] backed by an external in-memory cache.
///
/// The cache [Map] is owned by the caller (e.g. widget state) so it survives
/// across [TileLayer] rebuilds when scrubbing between radar frames.
class CachedRadarTileProvider extends TileProvider {
  final Map<String, Uint8List> cache;
  final HttpClient httpClient;

  CachedRadarTileProvider({
    required this.cache,
    required this.httpClient,
  });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _CachedRadarImageProvider(
      url: getTileUrl(coordinates, options),
      cache: cache,
      httpClient: httpClient,
    );
  }
}

class _CachedRadarImageProvider
    extends ImageProvider<_CachedRadarImageProvider> {
  final String url;
  final Map<String, Uint8List> cache;
  final HttpClient httpClient;

  const _CachedRadarImageProvider({
    required this.url,
    required this.cache,
    required this.httpClient,
  });

  @override
  ImageStreamCompleter loadImage(
    _CachedRadarImageProvider key,
    ImageDecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _loadTile(decode),
        scale: 1,
        debugLabel: url,
      );

  Future<ui.Codec> _loadTile(ImageDecoderCallback decode) async {
    // Serve from cache if available.
    final cached = cache[url];
    if (cached != null) {
      return decode(await ui.ImmutableBuffer.fromUint8List(cached));
    }

    // Fetch from network.
    try {
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        return _transparent(decode);
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      cache[url] = bytes;
      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (_) {
      return _transparent(decode);
    }
  }

  /// Returns a 1x1 transparent PNG so the map renders without gaps.
  Future<ui.Codec> _transparent(ImageDecoderCallback decode) async => decode(
        await ui.ImmutableBuffer.fromUint8List(TileProvider.transparentImage),
      );

  @override
  SynchronousFuture<_CachedRadarImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) =>
      SynchronousFuture(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _CachedRadarImageProvider && url == other.url);

  @override
  int get hashCode => url.hashCode;
}
