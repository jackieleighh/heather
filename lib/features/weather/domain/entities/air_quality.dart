class AirQuality {
  final int aqi;
  final double? pm25;
  final double? pm10;
  final double? ozone;
  final double? no2;
  final double? so2;
  final double? co;

  const AirQuality({
    required this.aqi,
    this.pm25,
    this.pm10,
    this.ozone,
    this.no2,
    this.so2,
    this.co,
  });
}
