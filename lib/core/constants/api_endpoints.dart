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
      'wind_speed_10m,uv_index,dew_point_2m,visibility,pressure_msl,'
      'wind_gusts_10m,wind_direction_10m'
      '&hourly=temperature_2m,precipitation_probability,weather_code,'
      'wind_speed_10m,uv_index,apparent_temperature,wind_gusts_10m,'
      'wind_direction_10m,relative_humidity_2m,surface_pressure'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,precipitation_probability_max,sunrise,sunset,'
      'uv_index_max'
      '&minutely_15=precipitation,rain,snowfall'
      '&forecast_minutely_15=24'
      '&temperature_unit=fahrenheit'
      '&wind_speed_unit=mph'
      '&timezone=auto'
      '&forecast_days=10';

  static String forecastBatch({
    required List<double> latitudes,
    required List<double> longitudes,
  }) =>
      '$weatherBase?latitude=${latitudes.join(",")}&longitude=${longitudes.join(",")}'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'is_day,precipitation,rain,snowfall,weather_code,cloud_cover,'
      'wind_speed_10m,uv_index,dew_point_2m,visibility,pressure_msl,'
      'wind_gusts_10m,wind_direction_10m'
      '&hourly=temperature_2m,precipitation_probability,weather_code,'
      'wind_speed_10m,uv_index,apparent_temperature,wind_gusts_10m,'
      'wind_direction_10m,relative_humidity_2m,surface_pressure'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,precipitation_probability_max,sunrise,sunset,'
      'uv_index_max'
      '&minutely_15=precipitation,rain,snowfall'
      '&forecast_minutely_15=24'
      '&temperature_unit=fahrenheit'
      '&wind_speed_unit=mph'
      '&timezone=auto'
      '&forecast_days=10';

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

  static const nexradBase =
      'https://radar-cache.heatherwiththeweather.workers.dev/cache/tile.py/1.0.0';

  static const historicalBase =
      'https://archive-api.open-meteo.com/v1/archive';

  static String historicalDaily({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
  }) =>
      '$historicalBase?latitude=$latitude&longitude=$longitude'
      '&start_date=$startDate&end_date=$endDate'
      '&daily=temperature_2m_max'
      '&temperature_unit=fahrenheit'
      '&timezone=auto';

  static String visiblePlanets({
    required double latitude,
    required double longitude,
  }) =>
      'https://api.visibleplanets.dev/v3?latitude=$latitude&longitude=$longitude&aboveHorizon=true';

  static const usnoBase = 'https://aa.usno.navy.mil/api';

  static String usnoOneDay({
    required String date,
    required double latitude,
    required double longitude,
    required num tzOffset,
  }) =>
      '$usnoBase/rstt/oneday?date=$date&coords=$latitude,$longitude&tz=$tzOffset';

  static String usnoMoonPhases({
    required String date,
    int nump = 8,
  }) =>
      '$usnoBase/moon/phases/date?date=$date&nump=$nump';

  static String nexradCurrent() => '$nexradBase/nexrad-n0q/{z}/{x}/{y}.png';

  static String nexradPast(int minutesAgo) {
    final padded = minutesAgo.toString().padLeft(2, '0');
    return '$nexradBase/nexrad-n0q-m${padded}m/{z}/{x}/{y}.png';
  }
}
