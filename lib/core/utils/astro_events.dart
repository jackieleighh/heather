import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Zodiac season
// ---------------------------------------------------------------------------

const _zodiacSigns = [
  (month: 1, day: 20, sign: 'Aquarius'),
  (month: 2, day: 19, sign: 'Pisces'),
  (month: 3, day: 20, sign: 'Aries'),
  (month: 4, day: 20, sign: 'Taurus'),
  (month: 5, day: 21, sign: 'Gemini'),
  (month: 6, day: 21, sign: 'Cancer'),
  (month: 7, day: 22, sign: 'Leo'),
  (month: 8, day: 23, sign: 'Virgo'),
  (month: 9, day: 23, sign: 'Libra'),
  (month: 10, day: 23, sign: 'Scorpio'),
  (month: 11, day: 22, sign: 'Sagittarius'),
  (month: 12, day: 22, sign: 'Capricorn'),
];

String currentZodiac(DateTime date) {
  for (var i = _zodiacSigns.length - 1; i >= 0; i--) {
    final z = _zodiacSigns[i];
    if (date.month > z.month ||
        (date.month == z.month && date.day >= z.day)) {
      return z.sign;
    }
  }
  // Before Jan 20 → Capricorn
  return 'Capricorn';
}

// ---------------------------------------------------------------------------
// Mercury retrograde
// ---------------------------------------------------------------------------

/// Hardcoded Mercury retrograde periods (start–end inclusive).
/// Covers 2025–2027; extend as needed.
const _mercuryRetrogrades = [
  // 2025
  (start: (y: 2025, m: 3, d: 15), end: (y: 2025, m: 4, d: 7)),
  (start: (y: 2025, m: 7, d: 18), end: (y: 2025, m: 8, d: 11)),
  (start: (y: 2025, m: 11, d: 9), end: (y: 2025, m: 11, d: 29)),
  // 2026
  (start: (y: 2026, m: 2, d: 26), end: (y: 2026, m: 3, d: 20)),
  (start: (y: 2026, m: 6, d: 29), end: (y: 2026, m: 7, d: 23)),
  (start: (y: 2026, m: 10, d: 24), end: (y: 2026, m: 11, d: 13)),
  // 2027
  (start: (y: 2027, m: 2, d: 9), end: (y: 2027, m: 3, d: 3)),
  (start: (y: 2027, m: 6, d: 10), end: (y: 2027, m: 7, d: 4)),
  (start: (y: 2027, m: 10, d: 7), end: (y: 2027, m: 10, d: 28)),
];

DateTime _d(({int y, int m, int d}) r) => DateTime(r.y, r.m, r.d);

({DateTime end})? mercuryRetrograde(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  for (final r in _mercuryRetrogrades) {
    final start = _d(r.start);
    final end = _d(r.end);
    if (!day.isBefore(start) && !day.isAfter(end)) {
      return (end: end);
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Meteor showers
// ---------------------------------------------------------------------------

class MeteorShower {
  final String name;
  final int peakMonth;
  final int peakDay;
  final int windowDays; // ± days from peak to be considered "active"
  final int zhr; // approximate zenith hourly rate

  const MeteorShower({
    required this.name,
    required this.peakMonth,
    required this.peakDay,
    this.windowDays = 2,
    required this.zhr,
  });
}

const _showers = [
  MeteorShower(name: 'Quadrantids', peakMonth: 1, peakDay: 3, windowDays: 1, zhr: 120),
  MeteorShower(name: 'Lyrids', peakMonth: 4, peakDay: 22, windowDays: 2, zhr: 18),
  MeteorShower(name: 'Eta Aquariids', peakMonth: 5, peakDay: 6, windowDays: 3, zhr: 50),
  MeteorShower(name: 'Delta Aquariids', peakMonth: 7, peakDay: 30, windowDays: 2, zhr: 25),
  MeteorShower(name: 'Perseids', peakMonth: 8, peakDay: 12, windowDays: 3, zhr: 100),
  MeteorShower(name: 'Draconids', peakMonth: 10, peakDay: 8, windowDays: 1, zhr: 10),
  MeteorShower(name: 'Orionids', peakMonth: 10, peakDay: 21, windowDays: 2, zhr: 20),
  MeteorShower(name: 'Leonids', peakMonth: 11, peakDay: 17, windowDays: 2, zhr: 15),
  MeteorShower(name: 'Geminids', peakMonth: 12, peakDay: 14, windowDays: 2, zhr: 150),
  MeteorShower(name: 'Ursids', peakMonth: 12, peakDay: 22, windowDays: 1, zhr: 10),
];

/// Returns the active meteor shower (nearest to peak) if within range, or null.
MeteorShower? activeMeteorShower(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  MeteorShower? best;
  int bestDist = 999;

  for (final s in _showers) {
    final peak = DateTime(date.year, s.peakMonth, s.peakDay);
    final diff = day.difference(peak).inDays.abs();
    if (diff <= s.windowDays && diff < bestDist) {
      best = s;
      bestDist = diff;
    }
  }
  return best;
}

/// Returns whether the peak is today (±0 days).
bool isMeteorShowerPeakTonight(DateTime date, MeteorShower shower) {
  final day = DateTime(date.year, date.month, date.day);
  final peak = DateTime(date.year, shower.peakMonth, shower.peakDay);
  return day.difference(peak).inDays.abs() == 0;
}

// ---------------------------------------------------------------------------
// Supermoon detection
// ---------------------------------------------------------------------------

/// Anomalistic month: time between successive perigees (~27.55 days).
const _anomalisticMonth = 27.554551;

/// A known perigee: Jan 10, 2026 (approximate).
final _referencePerigee = DateTime.utc(2026, 1, 10);

/// Returns true if [fullMoonDate] is within ~1.5 days of a lunar perigee,
/// which produces a "supermoon" (moon appears ~7% larger / ~15% brighter).
bool isSupermoon(DateTime fullMoonDate) {
  final daysSinceRef =
      fullMoonDate.toUtc().difference(_referencePerigee).inHours / 24.0;
  final cyclePosition = daysSinceRef % _anomalisticMonth;
  // Distance from nearest perigee (0 or full cycle)
  final distFromPerigee = cyclePosition < _anomalisticMonth / 2
      ? cyclePosition
      : _anomalisticMonth - cyclePosition;
  return distFromPerigee < 1.5;
}

// ---------------------------------------------------------------------------
// Moon distance (perigee / apogee)
// ---------------------------------------------------------------------------

/// Approximate distance from Earth to the Moon in km for [date].
/// Uses sinusoidal interpolation between perigee (~356,500 km) and
/// apogee (~406,700 km) based on the anomalistic month cycle.
double moonDistanceKm(DateTime date) {
  const perigeeKm = 356500.0;
  const apogeeKm = 406700.0;
  const midKm = (perigeeKm + apogeeKm) / 2;
  const ampKm = (apogeeKm - perigeeKm) / 2;

  final daysSinceRef =
      date.toUtc().difference(_referencePerigee).inHours / 24.0;
  final cyclePosition = (daysSinceRef % _anomalisticMonth) / _anomalisticMonth;
  // 0 = perigee (minimum distance), 0.5 = apogee (maximum distance)
  return midKm + ampKm * math.cos(2 * math.pi * cyclePosition);
}

/// Returns "Near perigee" / "Near apogee" when the Moon is within 10%
/// of either extreme, or null otherwise.
String? moonDistanceLabel(DateTime date) {
  final daysSinceRef =
      date.toUtc().difference(_referencePerigee).inHours / 24.0;
  final cyclePosition =
      ((daysSinceRef % _anomalisticMonth) / _anomalisticMonth) % 1.0;
  // 0 = perigee, 0.5 = apogee
  if (cyclePosition <= 0.10 || cyclePosition >= 0.90) return 'Near perigee';
  if (cyclePosition >= 0.40 && cyclePosition <= 0.60) return 'Near apogee';
  return null;
}

// ---------------------------------------------------------------------------
// Aggregate: pick the highest-priority event for the moon card
// ---------------------------------------------------------------------------

class AstroEvent {
  final String label;
  final String? icon;
  final int? zhr;

  const AstroEvent(this.label, {this.icon, this.zhr});
}

/// Returns the highest-priority astronomical event active on [date], if any.
///
/// Priority: Mercury retrograde > meteor shower > supermoon.
AstroEvent? activeAstroEvent(DateTime date, {DateTime? nextFullMoonDate}) {
  // 1. Mercury retrograde
  final retro = mercuryRetrograde(date);
  if (retro != null) {
    final endMonth = retro.end.month;
    final endDay = retro.end.day;
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return AstroEvent(
      '\u263F Retrograde until ${monthNames[endMonth]} $endDay',
    );
  }

  // 2. Meteor shower
  final shower = activeMeteorShower(date);
  if (shower != null) {
    final isPeak = isMeteorShowerPeakTonight(date, shower);
    final label = isPeak
        ? '${shower.name} peak tonight!'
        : '${shower.name} active';
    return AstroEvent('\u2604 $label', zhr: shower.zhr);
  }

  // 3. Supermoon (check if next full moon is a supermoon)
  if (nextFullMoonDate != null && isSupermoon(nextFullMoonDate)) {
    final daysUntil =
        DateTime(nextFullMoonDate.year, nextFullMoonDate.month, nextFullMoonDate.day)
            .difference(DateTime(date.year, date.month, date.day))
            .inDays;
    if (daysUntil <= 7) {
      final monthNames = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final label = daysUntil == 0
          ? 'Supermoon tonight!'
          : 'Supermoon ${monthNames[nextFullMoonDate.month]} ${nextFullMoonDate.day}';
      return AstroEvent(label);
    }
  }

  return null;
}
