import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import 'quips/sunny_quips.dart';
import 'quips/mostly_sunny_quips.dart';
import 'quips/partly_cloudy_quips.dart';
import 'quips/overcast_quips.dart';
import 'quips/foggy_quips.dart';
import 'quips/drizzle_quips.dart';
import 'quips/rain_quips.dart';
import 'quips/heavy_rain_quips.dart';
import 'quips/freezing_rain_quips.dart';
import 'quips/snow_quips.dart';
import 'quips/blizzard_quips.dart';
import 'quips/thunderstorm_quips.dart';
import 'quips/hail_quips.dart';
import 'quips/unknown_quips.dart';

class HeatherQuips {
  HeatherQuips._();

  static final quips = <WeatherCondition, Map<TemperatureTier, List<String>>>{
    WeatherCondition.sunny: sunnyQuips,
    WeatherCondition.mostlySunny: mostlySunnyQuips,
    WeatherCondition.partlyCloudy: partlyCloudyQuips,
    WeatherCondition.overcast: overcastQuips,
    WeatherCondition.foggy: foggyQuips,
    WeatherCondition.drizzle: drizzleQuips,
    WeatherCondition.rain: rainQuips,
    WeatherCondition.heavyRain: heavyRainQuips,
    WeatherCondition.freezingRain: freezingRainQuips,
    WeatherCondition.snow: snowQuips,
    WeatherCondition.blizzard: blizzardQuips,
    WeatherCondition.thunderstorm: thunderstormQuips,
    WeatherCondition.hail: hailQuips,
    WeatherCondition.unknown: unknownQuips,
  };

  static final explicitQuips =
      <WeatherCondition, Map<TemperatureTier, List<String>>>{
    WeatherCondition.sunny: sunnyExplicitQuips,
    WeatherCondition.mostlySunny: mostlySunnyExplicitQuips,
    WeatherCondition.partlyCloudy: partlyCloudyExplicitQuips,
    WeatherCondition.overcast: overcastExplicitQuips,
    WeatherCondition.foggy: foggyExplicitQuips,
    WeatherCondition.drizzle: drizzleExplicitQuips,
    WeatherCondition.rain: rainExplicitQuips,
    WeatherCondition.heavyRain: heavyRainExplicitQuips,
    WeatherCondition.freezingRain: freezingRainExplicitQuips,
    WeatherCondition.snow: snowExplicitQuips,
    WeatherCondition.blizzard: blizzardExplicitQuips,
    WeatherCondition.thunderstorm: thunderstormExplicitQuips,
    WeatherCondition.hail: hailExplicitQuips,
    WeatherCondition.unknown: unknownExplicitQuips,
  };
}
