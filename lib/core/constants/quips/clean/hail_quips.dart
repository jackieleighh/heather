import '../../../../features/weather/domain/entities/temperature_tier.dart';

const hailQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'Hail in single digits. She is the final boss of weather. Stay inside immediately girl.',
    'Ice pellets at single digits. Do not go outside bestie.',
    'She is throwing ice at single digits. Warmest everything and stay in babe.',
    'Single digit hail. Puffiest coat if you absolutely must leave but please do not girl.',
  ],
  TemperatureTier.freezing: [
    'Freezing hail. Stay inside bestie.',
    'Below freezing and hailing. She chose drama and brought ammunition. Heaviest coat babe.',
    'Hail below freezing. Stay safe in your warmest layers girl.',
    'She is chucking ice in the cold. Warm boots on and get to shelter bestie.',
  ],
  TemperatureTier.jacketWeather: [
    'Hail at jacket weather. She really said this day was too nice. Stay inside girl.',
    'She brought ice to a casual day. Stay in bestie.',
    'Hail at cool temps. She added a plot twist nobody wanted. Rain boots and shelter babe.',
    'She turned a jacket weather day into a dodge ball game. With ice. Stay inside girl.',
  ],
  TemperatureTier.flannelWeather: [
    'Hail at mild temps. She snapped during the best weather. Stay inside bestie.',
    'She waited for perfect temps to throw ice. Cozy sweater and stay in babe.',
    'Mild and hailing. Get to shelter girl.',
    'She ruined a perfect day with ice pellets. Flannel on and stay inside bestie.',
  ],
  TemperatureTier.shortsWeather: [
    'Hail at shorts weather. She looked at bare legs and chose war. Get inside girl.',
    'Warm hail. She does not believe in proportional responses. Shelter immediately bestie.',
    'She is hailing in warm weather. Stay inside babe.',
    'Shorts weather hail. Get inside now girl.',
  ],
  TemperatureTier.scorcher: [
    'Hail on a scorcher. She combined every extreme. Get to shelter bestie.',
    'Scorching hail. She broke every rule in the weather handbook. Lightest clothes and stay inside babe.',
    'Hot ice falling from the sky. Stay inside girl.',
    'She did the impossible and made a scorcher worse. With ice. SPF and shelter bestie.',
  ],
};

const hailNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    "Hail in single digits at night. She's throwing ice rocks in the freezing dark. Stay inside in your warmest PJs girl.",
    'She skipped snowballs and went straight to ice pellets. Very animated villain energy. Blanket burrito babe.',
    "Single digit hail at night. She's giving the scary storm scene in every fairy tale. Do not go outside bestie.",
    'Freezing dark and hailing. She brought frozen ammunition and a bad attitude. Coziest layers and stay in girl.',
  ],
  TemperatureTier.freezing: [
    "Below freezing hail at night. She's giving Elsa in her villain era. Stay inside in every layer babe.",
    'Freezing and hailing in the dark. She added ice rocks to the misery. Warmest PJs and hot cocoa girl.',
    "Hail below freezing tonight. She's giving the ice curse scene in every fairy tale. Fuzzy socks bestie.",
    'She brought ice pellets to a freezing night because she loves drama. Warmest everything and stay in babe.',
  ],
  TemperatureTier.jacketWeather: [
    'Hail at jacket temps tonight. She turned a nice evening into a fairy tale ice scene. Rain boots and stay inside girl.',
    'She brought ice to a perfectly good jacket weather night. Overreacting queen. Stay inside in your hoodie bestie.',
    "Cool night hail. She's giving animated villain who ruins the party. Jacket on and take cover babe.",
    'Hail at jacket weather. She really said this night was too calm. Very ice witch energy girl.',
  ],
  TemperatureTier.flannelWeather: [
    'Mild night with hail. She sabotaged her own beautiful work. Very Disney villain plot twist energy bestie.',
    'Hail on a flannel night. She threw ice at the coziest weather possible. Classic fairy tale villain move babe.',
    "She's hailing at the perfect temp because she lives for chaos. Cozy sweater and stay inside girl.",
    'Flannel weather and hailing. She went full ice queen at the worst time. Cute PJs and stay in bestie.',
  ],
  TemperatureTier.shortsWeather: [
    'Warm hail at night. She looked at everyone relaxing and said not on my watch. Stay inside girl.',
    "Hail in shorts weather tonight. She's the friend at the slumber party who starts throwing ice cubes babe.",
    "She's throwing frozen pellets on a warm night. Very confused Disney villain energy bestie.",
    'Shorts weather hail. She thought this was an action movie not a beach episode. Stay inside girl.',
  ],
  TemperatureTier.scorcher: [
    'Hot hail at night. She combined every extreme into one chaotic masterpiece. Lightest PJs babe.',
    'Scorching and hailing. She broke the weather handbook and threw it at us. Stay inside girl.',
    "Hot ice falling from the dark sky. She's the plot twist that breaks the whole fairy tale bestie.",
    'Hail on a scorcher at night. She did the impossible and made a hot night worse. With ice. Legend babe.',
  ],
};
