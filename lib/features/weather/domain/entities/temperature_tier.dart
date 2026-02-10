enum TemperatureTier {
  freezing,
  prettyCold,
  flannelWeather,
  shortsWeather,
  scorcher;

  static TemperatureTier fromTemperature(double tempF) {
    if (tempF < 32) return TemperatureTier.freezing;
    if (tempF < 50) return TemperatureTier.prettyCold;
    if (tempF < 70) return TemperatureTier.flannelWeather;
    if (tempF < 85) return TemperatureTier.shortsWeather;
    return TemperatureTier.scorcher;
  }
}
