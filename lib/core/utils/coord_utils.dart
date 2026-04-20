/// Round to 3 decimal places (~111m precision) to avoid GPS micro-drift
/// creating duplicate provider instances and cache entries.
({double lat, double lon}) roundCoords(({double lat, double lon}) c) => (
  lat: (c.lat * 1000).roundToDouble() / 1000,
  lon: (c.lon * 1000).roundToDouble() / 1000,
);
