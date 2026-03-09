enum TemperatureTier {
  singleDigits,
  freezing,
  jacketWeather,
  flannelWeather,
  shortsWeather,
  scorcher;

  static TemperatureTier fromTemperature(double tempF) {
    // Round so the tier matches the displayed temperature (e.g. 69.7 → 70 → shorts).
    final t = tempF.roundToDouble();
    if (t < 15) return TemperatureTier.singleDigits;
    if (t < 32) return TemperatureTier.freezing;
    if (t < 50) return TemperatureTier.jacketWeather;
    if (t < 70) return TemperatureTier.flannelWeather;
    if (t < 90) return TemperatureTier.shortsWeather;
    return TemperatureTier.scorcher;
  }
}
