import '../../features/weather/domain/entities/temperature_tier.dart';
import '../../features/weather/domain/entities/weather_condition.dart';
import 'quips/clean/blizzard_quips.dart';
import 'quips/clean/drizzle_quips.dart';
import 'quips/clean/foggy_quips.dart';
import 'quips/clean/freezing_rain_quips.dart';
import 'quips/clean/hail_quips.dart';
import 'quips/clean/heavy_rain_quips.dart';
import 'quips/clean/mostly_sunny_quips.dart';
import 'quips/clean/overcast_quips.dart';
import 'quips/clean/partly_cloudy_quips.dart';
import 'quips/clean/rain_quips.dart';
import 'quips/clean/snow_quips.dart';
import 'quips/clean/sunny_quips.dart';
import 'quips/clean/thunderstorm_quips.dart';
import 'quips/clean/unknown_quips.dart';
import 'quips/explicit/blizzard_quips.dart';
import 'quips/explicit/drizzle_quips.dart';
import 'quips/explicit/foggy_quips.dart';
import 'quips/explicit/freezing_rain_quips.dart';
import 'quips/explicit/hail_quips.dart';
import 'quips/explicit/heavy_rain_quips.dart';
import 'quips/explicit/mostly_sunny_quips.dart';
import 'quips/explicit/overcast_quips.dart';
import 'quips/explicit/partly_cloudy_quips.dart';
import 'quips/explicit/rain_quips.dart';
import 'quips/explicit/snow_quips.dart';
import 'quips/explicit/sunny_quips.dart';
import 'quips/explicit/thunderstorm_quips.dart';
import 'quips/explicit/unknown_quips.dart';

class HeatherNightQuips {
  HeatherNightQuips._();

  static const quips = <WeatherCondition, Map<TemperatureTier, List<String>>>{
    WeatherCondition.sunny: sunnyNightQuips,
    WeatherCondition.mostlySunny: mostlySunnyNightQuips,
    WeatherCondition.partlyCloudy: partlyCloudyNightQuips,
    WeatherCondition.overcast: overcastNightQuips,
    WeatherCondition.foggy: foggyNightQuips,
    WeatherCondition.drizzle: drizzleNightQuips,
    WeatherCondition.rain: rainNightQuips,
    WeatherCondition.heavyRain: heavyRainNightQuips,
    WeatherCondition.freezingRain: freezingRainNightQuips,
    WeatherCondition.snow: snowNightQuips,
    WeatherCondition.blizzard: blizzardNightQuips,
    WeatherCondition.thunderstorm: thunderstormNightQuips,
    WeatherCondition.hail: hailNightQuips,
    WeatherCondition.unknown: unknownNightQuips,
  };
  static const explicitQuips =
      <WeatherCondition, Map<TemperatureTier, List<String>>>{
        WeatherCondition.sunny: sunnyExplicitNightQuips,
        WeatherCondition.mostlySunny: mostlySunnyExplicitNightQuips,
        WeatherCondition.partlyCloudy: partlyCloudyExplicitNightQuips,
        WeatherCondition.overcast: overcastExplicitNightQuips,
        WeatherCondition.foggy: foggyExplicitNightQuips,
        WeatherCondition.drizzle: drizzleExplicitNightQuips,
        WeatherCondition.rain: rainExplicitNightQuips,
        WeatherCondition.heavyRain: heavyRainExplicitNightQuips,
        WeatherCondition.freezingRain: freezingRainExplicitNightQuips,
        WeatherCondition.snow: snowExplicitNightQuips,
        WeatherCondition.blizzard: blizzardExplicitNightQuips,
        WeatherCondition.thunderstorm: thunderstormExplicitNightQuips,
        WeatherCondition.hail: hailExplicitNightQuips,
        WeatherCondition.unknown: unknownExplicitNightQuips,
      };
}
