enum TemperatureTier {
  singleDigits,
  freezing,
  prettyCold,
  flannelWeather,
  shortsWeather,
  scorcher;

  static TemperatureTier fromTemperature(double tempF) {
    if (tempF < 15) return TemperatureTier.singleDigits;
    if (tempF < 32) return TemperatureTier.freezing;
    if (tempF < 45) return TemperatureTier.prettyCold;
    if (tempF < 65) return TemperatureTier.flannelWeather;
    if (tempF < 85) return TemperatureTier.shortsWeather;
    return TemperatureTier.scorcher;
  }
}
