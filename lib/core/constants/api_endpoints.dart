class ApiEndpoints {
  ApiEndpoints._();

  static const weatherBase = 'https://api.open-meteo.com/v1/forecast';
  static const geocodingBase = 'https://geocoding-api.open-meteo.com/v1/search';

  static String forecast({
    required double latitude,
    required double longitude,
  }) =>
      '$weatherBase?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'is_day,precipitation,rain,snowfall,weather_code,cloud_cover,'
      'wind_speed_10m,uv_index'
      '&hourly=temperature_2m,precipitation_probability,weather_code,'
      'wind_speed_10m,uv_index'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,precipitation_probability_max,sunrise,sunset,'
      'uv_index_max'
      '&temperature_unit=fahrenheit'
      '&wind_speed_unit=mph'
      '&timezone=auto'
      '&forecast_days=7';

  static const airQualityBase =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  static String airQuality({
    required double latitude,
    required double longitude,
  }) =>
      '$airQualityBase?latitude=$latitude&longitude=$longitude'
      '&current=us_aqi';

  static const nwsAlertsBase = 'https://api.weather.gov/alerts/active';

  static String nwsAlerts({
    required double latitude,
    required double longitude,
  }) =>
      '$nwsAlertsBase?point=$latitude,$longitude';

  static String geocoding({
    required String query,
    int count = 10,
  }) =>
      '$geocodingBase?name=$query&count=$count&language=en&format=json';
}
