import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';

final historicalAvgProvider =
    FutureProvider.family<double?, ({double lat, double lon})>(
        (ref, coords) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheKey = 'cached_hist_avg_${coords.lat}_${coords.lon}';
  final cacheTsKey = 'cached_hist_avg_ts_${coords.lat}_${coords.lon}';

  final cachedAvg = prefs.getDouble(cacheKey);
  final cachedTs = prefs.getInt(cacheTsKey);

  // Return cached value if <24 hours old
  if (cachedAvg != null && cachedTs != null) {
    final age = DateTime.now().millisecondsSinceEpoch - cachedTs;
    if (age < const Duration(hours: 24).inMilliseconds) {
      return cachedAvg;
    }
  }

  try {
    final now = DateTime.now();
    final endDate = now.subtract(const Duration(days: 5));
    final startDate = DateTime(now.year - 10, now.month, now.day);

    final response = await Dio().get(
      ApiEndpoints.historicalDaily(
        latitude: coords.lat,
        longitude: coords.lon,
        startDate:
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        endDate:
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List)
        .map((e) => (e as num?)?.toDouble())
        .toList();

    // Filter for same day-of-year (±3 days) across all years
    final todayDoy = _dayOfYear(now);
    var sum = 0.0;
    var count = 0;
    for (var i = 0; i < times.length; i++) {
      if (maxTemps[i] == null) continue;
      final date = DateTime.parse(times[i]);
      final doy = _dayOfYear(date);
      final diff = (doy - todayDoy).abs();
      // Handle year wrap (e.g. Jan 1 vs Dec 31)
      if (diff <= 3 || diff >= 362) {
        sum += maxTemps[i]!;
        count++;
      }
    }

    if (count == 0) return cachedAvg;

    final avg = sum / count;

    // Cache the result
    await prefs.setDouble(cacheKey, avg);
    await prefs.setInt(cacheTsKey, DateTime.now().millisecondsSinceEpoch);

    return avg;
  } catch (_) {
    // Return stale cache on failure
    return cachedAvg;
  }
});

int _dayOfYear(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
}
