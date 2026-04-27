import '../../../../features/weather/domain/entities/temperature_tier.dart';

const unknownQuips = <TemperatureTier, List<String>>{
  TemperatureTier.flannelWeather: [
    "Can't tell what she is doing but the temp is cute. Flannel on and dress for anything girl.",
    'Mystery weather at a nice temp. Layer up just in case bestie.',
    'Unknown vibes but the temp is flannel weather so honestly who cares. Cozy sweater on babe.',
    'She is being unreadable but mild. Cute boots on and layer up for anything girl.',
  ],
};

const unknownNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.flannelWeather: [
    "Weather unknown tonight. She's giving fairy tale mystery fog energy. Layer up for anything babe.",
    'The forecast cannot read her tonight. Very enchanted forest vibes. Dress for surprises girl.',
    "Unknown conditions after dark. She's being mysterious like a Disney princess before the reveal. Cozy layers bestie.",
    "She's giving mystery weather and main character energy. Layer up and expect the unexpected babe.",
  ],
};
