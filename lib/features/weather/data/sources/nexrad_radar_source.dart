import '../../../../core/constants/api_endpoints.dart';

class RadarFrame {
  final int time;
  final String tileUrlTemplate;

  const RadarFrame({required this.time, required this.tileUrlTemplate});
}

class RadarManifest {
  final List<RadarFrame> frames;
  final int nowIndex;

  const RadarManifest({required this.frames, required this.nowIndex});
}

class NexradRadarSource {
  RadarManifest buildManifest() {
    final now = DateTime.now();
    final frames = <RadarFrame>[];

    // Past frames: 50, 45, 40, ..., 5 minutes ago
    for (int m = 50; m >= 5; m -= 5) {
      frames.add(RadarFrame(
        time: now.subtract(Duration(minutes: m)).millisecondsSinceEpoch ~/ 1000,
        tileUrlTemplate: ApiEndpoints.nexradPast(m),
      ));
    }

    // Current frame
    frames.add(RadarFrame(
      time: now.millisecondsSinceEpoch ~/ 1000,
      tileUrlTemplate: ApiEndpoints.nexradCurrent(),
    ));

    return RadarManifest(frames: frames, nowIndex: frames.length - 1);
  }
}
