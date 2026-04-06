import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/moon_phase.dart';

class UsnoPhaseTransition {
  final DateTime date;
  final String phase;

  const UsnoPhaseTransition({required this.date, required this.phase});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'phase': phase,
  };

  factory UsnoPhaseTransition.fromJson(Map<String, dynamic> json) =>
      UsnoPhaseTransition(
        date: DateTime.parse(json['date'] as String),
        phase: json['phase'] as String,
      );
}

class UsnoMoonData {
  final String curPhase;
  final double fracIllum;
  final List<UsnoPhaseTransition> transitions;

  const UsnoMoonData({
    required this.curPhase,
    required this.fracIllum,
    this.transitions = const [],
  });

  /// First upcoming Full Moon from the transitions list.
  DateTime? get nextFullMoon {
    final now = DateTime.now();
    for (final t in transitions) {
      if (t.phase == 'Full Moon' && t.date.isAfter(now)) return t.date;
    }
    return null;
  }

  /// First upcoming New Moon from the transitions list.
  DateTime? get nextNewMoon {
    final now = DateTime.now();
    for (final t in transitions) {
      if (t.phase == 'New Moon' && t.date.isAfter(now)) return t.date;
    }
    return null;
  }

  /// Cycle fraction (0–1) for a given [date], interpolated from USNO
  /// phase transitions. 0 = new moon, 0.5 = full moon.
  double fractionForDate(DateTime date) {
    if (transitions.length < 2) {
      return _fractionFromIllum(fracIllum, usnoPhaseToEnum(curPhase));
    }

    int beforeIdx = -1;
    for (int i = 0; i < transitions.length; i++) {
      if (!transitions[i].date.isAfter(date)) {
        beforeIdx = i;
      }
    }

    if (beforeIdx < 0) return _transitionFraction(transitions.first.phase);
    if (beforeIdx >= transitions.length - 1) {
      return _transitionFraction(transitions.last.phase);
    }

    final before = transitions[beforeIdx];
    final after = transitions[beforeIdx + 1];

    final startFrac = _transitionFraction(before.phase);
    var endFrac = _transitionFraction(after.phase);
    if (endFrac <= startFrac) endFrac += 1.0;

    final totalHours = after.date.difference(before.date).inHours.toDouble();
    final elapsed = date.difference(before.date).inHours.toDouble();
    final progress =
        totalHours > 0 ? (elapsed / totalHours).clamp(0.0, 1.0) : 0.0;

    return (startFrac + progress * (endFrac - startFrac)) % 1.0;
  }

  /// Illumination percentage (0–100) for a given [date].
  double illuminationForDate(DateTime date) {
    final frac = fractionForDate(date);
    return (1 - math.cos(2 * math.pi * frac)) / 2 * 100;
  }

  /// Moon phase for a given [date].
  MoonPhase phaseForDate(DateTime date) =>
      phaseFromFraction(fractionForDate(date));

  static double _transitionFraction(String phase) => switch (phase) {
    'New Moon' => 0.0,
    'First Quarter' => 0.25,
    'Full Moon' => 0.5,
    'Last Quarter' => 0.75,
    _ => 0.0,
  };

  static double _fractionFromIllum(double illumPercent, MoonPhase? phase) {
    final illum = (illumPercent / 100).clamp(0.0, 1.0);
    final halfFrac =
        math.acos((1 - 2 * illum).clamp(-1.0, 1.0)) / (2 * math.pi);
    const waningPhases = {
      MoonPhase.fullMoon,
      MoonPhase.waningGibbous,
      MoonPhase.thirdQuarter,
      MoonPhase.waningCrescent,
    };
    return (phase != null && waningPhases.contains(phase))
        ? 1 - halfFrac
        : halfFrac;
  }

  Map<String, dynamic> toJson() => {
    'curPhase': curPhase,
    'fracIllum': fracIllum,
    'transitions': transitions.map((t) => t.toJson()).toList(),
  };

  factory UsnoMoonData.fromJson(Map<String, dynamic> json) => UsnoMoonData(
    curPhase: json['curPhase'] as String,
    fracIllum: (json['fracIllum'] as num).toDouble(),
    transitions: (json['transitions'] as List<dynamic>?)
            ?.map((t) =>
                UsnoPhaseTransition.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

final moonDataProvider = FutureProvider<UsnoMoonData?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const cacheKey = 'cached_moon_global';
  const cacheTsKey = 'cached_moon_global_ts';

  final cachedJson = prefs.getString(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  UsnoMoonData? cachedData;
  if (cachedJson != null) {
    try {
      cachedData = UsnoMoonData.fromJson(
        jsonDecode(cachedJson) as Map<String, dynamic>,
      );
    } catch (_) {}
  }

  // Return cached value if <30 min old
  if (cachedData != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(minutes: 30).inMilliseconds) {
      return cachedData;
    }
  }

  try {
    final nowUtc = DateTime.now().toUtc();
    final dateStr = '${nowUtc.year}-${nowUtc.month}-${nowUtc.day}';

    // Fetch phases starting 35 days ago to cover the current lunar cycle
    final phasesStart = nowUtc.subtract(const Duration(days: 35));
    final phasesDateStr =
        '${phasesStart.year}-${phasesStart.month}-${phasesStart.day}';

    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10);

    final results = await Future.wait([
      dio.get(ApiEndpoints.usnoOneDay(
        date: dateStr,
        latitude: 0,
        longitude: 0,
        tzOffset: 0,
      )),
      dio.get(ApiEndpoints.usnoMoonPhases(date: phasesDateStr, nump: 16)),
    ]);

    final oneDayData =
        (results[0].data as Map<String, dynamic>)['properties']['data']
            as Map<String, dynamic>;
    final phasesData =
        (results[1].data as Map<String, dynamic>)['phasedata']
            as List<dynamic>;

    final curPhase = oneDayData['curphase'] as String;
    final fracStr = oneDayData['fracillum'] as String;
    final fracIllum = double.tryParse(fracStr.replaceAll('%', '')) ?? 0;

    final transitions = phasesData
        .map((p) => UsnoPhaseTransition(
              date: DateTime(
                  p['year'] as int, p['month'] as int, p['day'] as int),
              phase: p['phase'] as String,
            ))
        .toList();

    final data = UsnoMoonData(
      curPhase: curPhase,
      fracIllum: fracIllum,
      transitions: transitions,
    );

    await prefs.setString(cacheKey, jsonEncode(data.toJson()));
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return data;
  } catch (_) {
    // Only return cached data if it's less than 24 hours old
    if (cachedData != null && cachedTs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
      if (age < const Duration(hours: 24).inMilliseconds) {
        return cachedData;
      }
    }
    return null;
  }
});
