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
