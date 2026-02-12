enum TemperatureTier {
  singleDigits,
  freezing,
  jacketWeather,
  flannelWeather,
  shortsWeather,
  scorcher;

  static TemperatureTier fromTemperature(double tempF) {
    if (tempF < 15) return TemperatureTier.singleDigits;
    if (tempF < 32) return TemperatureTier.freezing;
    if (tempF < 50) return TemperatureTier.jacketWeather;
    if (tempF < 70) return TemperatureTier.flannelWeather;
    if (tempF < 90) return TemperatureTier.shortsWeather;
    return TemperatureTier.scorcher;
  }
}
