import '../../../features/weather/domain/entities/weather_alert.dart';

enum AlertQuipCategory {
  tornado,
  hurricane,
  thunderstorm,
  winterStorm,
  flood,
  heat,
  wind,
  fire,
  fallback;

  /// Maps an NWS event name + severity to a category.
  /// Returns `null` when the alert is not extreme or severe.
  static AlertQuipCategory? fromEvent(String event, AlertSeverity severity) {
    if (severity != AlertSeverity.extreme && severity != AlertSeverity.severe) {
      return null;
    }
    final lower = event.toLowerCase();
    if (lower.contains('tornado')) return tornado;
    if (lower.contains('hurricane') || lower.contains('tropical')) {
      return hurricane;
    }
    if (lower.contains('thunderstorm')) return thunderstorm;
    if (lower.contains('winter storm') ||
        lower.contains('blizzard') ||
        lower.contains('ice storm')) {
      return winterStorm;
    }
    if (lower.contains('flood') || lower.contains('flash')) return flood;
    if (lower.contains('heat')) return heat;
    if (lower.contains('wind') ||
        lower.contains('dust storm') ||
        lower.contains('derecho')) {
      return wind;
    }
    if (lower.contains('fire') || lower.contains('red flag')) return fire;
    return fallback;
  }
}

const alertCleanQuips = <AlertQuipCategory, List<String>>{
  AlertQuipCategory.tornado: [
    'Tornado warning in your area. This is not a drill bestie. Get to your safe room right now.',
    'She just threw a tornado at you. Lowest floor interior room now babe.',
    'Tornado alert is active. Heather is begging you to get to shelter right now girl.',
    'Tornado warning. Get away from windows and get to your safe room immediately bestie.',
  ],
  AlertQuipCategory.hurricane: [
    'Hurricane alert is active. Board up hunker down and do not go outside bestie.',
    "She's sending a whole hurricane your way. This is serious babe. Shelter and supplies now.",
    'Hurricane warning in effect. Stay far from windows and follow evacuation orders girl.',
    'A hurricane is coming and she means business. Stock up and stay inside bestie.',
  ],
  AlertQuipCategory.thunderstorm: [
    "Severe thunderstorm warning. She's not just being dramatic she's being dangerous. Stay inside bestie.",
    'Severe thunderstorm alert is active. Stay away from windows and get indoors now babe.',
    'She upgraded from dramatic to dangerous. Severe thunderstorm warning. Shelter now girl.',
    'Severe thunderstorm in your area. This is not the fun kind of storm. Get inside bestie.',
  ],
  AlertQuipCategory.winterStorm: [
    'Winter storm warning is active. Stock up stay inside and do not drive bestie.',
    "She's sending a winter storm and she's not sorry about it. Stay home and stay warm babe.",
    "Winter storm alert. Roads are going to be a nightmare. Stay inside girl.",
    "Winter storm warning. She's burying everything in snow and ice. Stay home bestie.",
  ],
  AlertQuipCategory.flood: [
    'Flood warning is active. Do not drive through standing water. Turn around bestie.',
    "She's flooding your area and she's not done. Move to higher ground if you need to babe.",
    'Flash flood alert. Water rises faster than you think. Stay off the roads girl.',
    'Flood warning in effect. Turn around don\'t drown bestie.',
  ],
  AlertQuipCategory.heat: [
    'Extreme heat warning. Stay hydrated stay in shade and check on your people bestie.',
    "She's trying to melt you. Extreme heat alert. Water shade and AC are your best friends babe.",
    'Dangerous heat in your area. Limit time outside and drink more water than you think you need girl.',
    "Heat emergency is active. She's not playing. Stay cool and stay hydrated bestie.",
  ],
  AlertQuipCategory.wind: [
    'High wind warning is active. Secure loose objects and stay away from trees bestie.',
    "She's throwing everything that isn't nailed down. Extreme wind alert babe. Stay inside.",
    'Dangerous winds in your area. This is not a cute breeze. Stay indoors girl.',
    "Wind warning active. She's rearranging the neighborhood. Stay inside bestie.",
  ],
  AlertQuipCategory.fire: [
    'Fire weather alert is active. Follow evacuation orders immediately if given bestie.',
    'Red flag warning. Extreme fire danger in your area. Be ready to evacuate babe.',
    'Wildfire conditions are critical. Have your go bag ready and follow all orders girl.',
    "Fire weather warning. She's making conditions dangerous. Stay alert and be ready to move bestie.",
  ],
  AlertQuipCategory.fallback: [
    'A severe weather alert is active in your area. Stay safe and stay aware bestie.',
    "Extreme weather warning. She's not messing around. Follow local guidance babe.",
    'Severe alert in effect. Pay attention to local authorities and stay safe girl.',
    'Dangerous weather is active. Keep your phone charged and stay aware bestie.',
  ],
};

const alertExplicitQuips = <AlertQuipCategory, List<String>>{
  AlertQuipCategory.tornado: [
    'There is a fucking tornado warning. Get to your safe room right now girl.',
    "She's throwing a whole goddamn tornado at you. Lowest floor interior room. Go. Now babe.",
    "Tornado warning. This is literally the one time I'm not joking. Get to shelter now girl.",
    'A fucking tornado. Get away from windows get to the lowest floor and do not fuck around right now bestie.',
  ],
  AlertQuipCategory.hurricane: [
    'There is a fucking hurricane alert. Board up hunker down and do not go outside girl.',
    "She sent a whole ass hurricane. This is not the time to be brave babe. Stay inside.",
    'Hurricane warning. Get your shit together get away from windows and follow evacuation orders girl.',
    "A fucking hurricane is headed your way. Stock up stay inside and do not fuck around bestie.",
  ],
  AlertQuipCategory.thunderstorm: [
    "Severe thunderstorm warning. She's not fucking around this time. Get inside now girl.",
    'Severe thunderstorm alert is up. Stay the fuck away from windows babe.',
    'She went from dramatic to actually dangerous. Severe thunderstorm. Get inside now girl.',
    'Severe thunderstorm warning. This is not the cute kind. Get your ass inside bestie.',
  ],
  AlertQuipCategory.winterStorm: [
    'Winter storm warning. Do not drive. Do not be a hero. Stay the fuck inside girl.',
    "She's sending a goddamn blizzard. Stock up and do not leave your house babe.",
    'Winter storm alert. The roads are going to be absolute shit. Stay inside girl.',
    "Ice storm warning. She's coating everything in ice like a psycho. Stay home bestie.",
  ],
  AlertQuipCategory.flood: [
    "Flood warning. Do not drive through that water. I don't care how shallow it looks. Turn the fuck around girl.",
    "She's flooding everything. Move to higher ground if needed and stay off the damn roads babe.",
    'Flash flood alert. That water will sweep your car away. Do not fuck with it girl.',
    'Flood warning. Seriously do not be the person who drives into floodwater. Turn around bestie.',
  ],
  AlertQuipCategory.heat: [
    "Extreme heat warning. She's literally trying to cook you. Stay inside and hydrate girl.",
    "Dangerous heat alert. Drink water like it's your goddamn job and stay in the AC babe.",
    "She's throwing a heat emergency at you. Stay inside and drink water. Lots of fucking water girl.",
    'Extreme heat warning. Do not be outside unless you absolutely have to. She will end you bestie.',
  ],
  AlertQuipCategory.wind: [
    "High wind warning. She's yeeting everything that isn't bolted down. Stay inside girl.",
    'Extreme wind alert. She will literally throw a trampoline at your house. Stay inside babe.',
    "Dangerous winds. She's out there rearranging the whole neighborhood. Do not go outside girl.",
    'Wind warning. She is pissed and she is throwing shit. Stay the fuck inside bestie.',
  ],
  AlertQuipCategory.fire: [
    'Fire weather alert. If they say evacuate you fucking evacuate girl.',
    'Red flag warning. Extreme fire danger. Have your shit packed and be ready to go babe.',
    'Wildfire conditions are critical. Do not fuck around with this. Be ready to move girl.',
    "Fire weather warning. She's making it dangerous out there. Stay alert and grab your go bag bestie.",
  ],
  AlertQuipCategory.fallback: [
    'Severe weather alert in your area. Pay attention and stay the fuck safe girl.',
    "Extreme weather warning. She's not playing. Follow local guidance babe.",
    "Severe alert active. Listen to the authorities and don't do anything stupid girl.",
    'Dangerous weather going on. Keep your phone charged and stay fucking aware bestie.',
  ],
};
