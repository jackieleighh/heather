import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

final basemapStyleProvider = FutureProvider<Style>((ref) async {
  final reader = StyleReader(
    uri: 'https://tiles.openfreemap.org/styles/positron',
  );
  return reader.read();
});
