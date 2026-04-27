import '../../../features/weather/domain/entities/weather_alert.dart';

enum AlertQuipCategory {
  tornado,
  hurricane,
  thunderstorm,
  winterStorm,
  flood,
  heat,
  wind,
  fire,
  fallback;

  /// Maps an NWS event name + severity to a category.
  /// Returns `null` when the alert is not extreme or severe.
  static AlertQuipCategory? fromEvent(String event, AlertSeverity severity) {
    if (severity != AlertSeverity.extreme && severity != AlertSeverity.severe) {
      return null;
    }
    final lower = event.toLowerCase();
    if (lower.contains('tornado')) return tornado;
    if (lower.contains('hurricane') || lower.contains('tropical')) {
      return hurricane;
    }
    if (lower.contains('thunderstorm')) return thunderstorm;
    if (lower.contains('winter storm') ||
        lower.contains('blizzard') ||
        lower.contains('ice storm')) {
      return winterStorm;
    }
    if (lower.contains('flood') || lower.contains('flash')) return flood;
    if (lower.contains('heat')) return heat;
    if (lower.contains('wind') ||
        lower.contains('dust storm') ||
        lower.contains('derecho')) {
      return wind;
    }
    if (lower.contains('fire') || lower.contains('red flag')) return fire;
    return fallback;
  }
}
