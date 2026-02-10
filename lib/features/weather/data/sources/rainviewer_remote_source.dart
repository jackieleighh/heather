import 'package:dio/dio.dart';

class RadarFrame {
  final int time;
  final String path;

  const RadarFrame({required this.time, required this.path});
}

class RainViewerManifest {
  final String host;
  final List<RadarFrame> frames;
  final int nowIndex; // index of the "now" frame (last past frame)

  const RainViewerManifest({
    required this.host,
    required this.frames,
    required this.nowIndex,
  });
}

class RainViewerRemoteSource {
  final Dio dio;

  RainViewerRemoteSource({required this.dio});

  Future<RainViewerManifest> fetchManifest() async {
    final response = await dio.get<Map<String, dynamic>>(
      'https://api.rainviewer.com/public/weather-maps.json',
    );

    final data = response.data!;
    final host = data['host'] as String;
    final radar = data['radar'] as Map<String, dynamic>;
    final past = radar['past'] as List<dynamic>;

    final allPastFrames = past
        .map((frame) => RadarFrame(
              time: frame['time'] as int,
              path: frame['path'] as String,
            ))
        .toList();

    if (allPastFrames.isEmpty) {
      throw Exception('No radar frames available');
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Show past 2 hours of radar data
    const pastSpan = 7200;
    final pastFrames = allPastFrames
        .where((f) => f.time >= now - pastSpan)
        .toList();
    if (pastFrames.isEmpty) {
      pastFrames.add(allPastFrames.last);
    }

    final nowIndex = pastFrames.length - 1;

    return RainViewerManifest(
      host: host,
      frames: pastFrames,
      nowIndex: nowIndex,
    );
  }
}
