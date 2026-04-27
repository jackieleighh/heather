import '../../../../features/weather/domain/entities/temperature_tier.dart';

const overcastQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'Gray sky single digits. She chose misery and committed. Stay inside in your PJs girl.',
    'Overcast and freezing cold. Every layer you own and do not leave the house bestie.',
    'No sun no warmth no mercy. Blanket burrito and fuzzy socks babe.',
    'Full cloud cover in single digits. She is in her villain era. Warmest everything and stay in girl.',
  ],
  TemperatureTier.freezing: [
    'Gray and freezing. The clouds came for the sun and won. Heaviest coat and earmuffs bestie.',
    'Overcast below freezing. She blocked the sun and froze the air. Scarf and gloves babe.',
    'Below freezing under a gray blanket. Warm boots and hot cocoa kind of day girl.',
    'She covered the sky and froze everything. Full winter gear no exceptions bestie.',
    'Grey and below freezing. The kind of day you watch from inside with a warm drink babe.',
  ],
  TemperatureTier.jacketWeather: [
    'Overcast and cool. Coffee shop weather honestly. Cute jacket and a warm drink girl.',
    'Gray sky jacket weather. Moody and cozy. Hoodie on and go wander bestie.',
    'The clouds took over but the temp is cute. Denim jacket on babe.',
    'Grey skies and cool. The kind of day a good jacket makes perfect. Light layers girl.',
    'Overcast jacket weather. The sky went full grey but the temp stayed reasonable. Hoodie on bestie.',
  ],
  TemperatureTier.flannelWeather: [
    'Overcast and mild. Soft lighting from the sky. Flannel on and go be cozy bestie.',
    'Gray skies at this temp hit different. Coziest sweater on and go for a walk babe.',
    'The clouds are a vibe and the temp is perfect. Best fall outfit on girl.',
    "Overcast flannel weather. She didn't need the sun to be perfect and she proved it bestie.",
    'Grey but mild. Very fairy tale afternoon energy. Cute boots and a light scarf babe.',
  ],
  TemperatureTier.shortsWeather: [
    'Warm and overcast. No sunburn no squinting just vibes. Shorts on babe.',
    'Overcast shorts weather. She blocked the sun but kept the warmth. Strategic queen. Sandals on bestie.',
    'Gray sky warm air. Sundress on and go enjoy it. No sunscreen stress today girl.',
    'She blocked the sun but kept the heat. The clouds are just a filter. Shorts on babe.',
    'Warm under grey skies. Like a cozy warm hug from the sky. Tank top girl.',
  ],
  TemperatureTier.scorcher: [
    'Overcast scorcher. She sealed the heat in like a pressure cooker. Lightest clothes and hydrate girl.',
    'Gray and scorching. She trapped us under a hot blanket. Water bottle and hat on bestie.',
    'She covered the sky and cranked the heat. Lightest outfit and stay cool babe.',
    'Overcast and melting. The clouds are a lid on a boiling pot. Hydrate immediately girl.',
    'Grey and hot. She invented the outdoor sauna. Lightest clothes on and drink water bestie.',
  ],
};

const overcastNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    "No stars no warmth no mercy. She's channeling the Snow Queen tonight. Every layer girl.",
    'She shut the whole sky down and cranked the cold. So on brand for her honestly babe.',
    "Full cloud cover in single digits. She's giving Narnia eternal winter energy. Blanket burrito bestie.",
    'She hid every star and froze everything. Villain behavior but make it atmospheric girl.',
  ],
  TemperatureTier.freezing: [
    'Dimmed the lights and the thermostat. Below freezing under clouds babe.',
    'Deleted the stars. Turned the temp to punishment. Classic her girl.',
    'That scene before the curse breaks. Bundle up bestie.',
    "No stars no warmth. She's committed to this mood babe.",
    'Grey ceiling in a dungeon energy. Heaviest coat and scarf bestie.',
    'Nothing to look at. Nothing to feel good about. Warm boots girl.',
  ],
  TemperatureTier.jacketWeather: [
    'She threw a blanket over the sky. Cozy mystery energy. Jacket on girl.',
    "Overcast and cool. She's giving loading screen vibes but the temp is manageable babe.",
    'She said stars are overrated tonight. Jacket weather disagrees but here we are bestie.',
    'Cloud ceiling all night. She put the sky on do not disturb girl.',
    'Overcast and cool. She put the sky on airplane mode but the temp is still texting back babe.',
    'Grey ceiling jacket weather. Very walking through a fairy tale town at midnight energy bestie.',
  ],
  TemperatureTier.flannelWeather: [
    "Full cloud cover but the temp is a dream. She's giving cozy without the view babe.",
    'Stars are cancelled but the vibes are immaculate. Flannel on girl.',
    'She turned the lights off but nailed the thermostat. Mixed reviews but mostly positive bestie.',
    'Overcast and mild. The sky is taking a personal day but the temp is covering her shift babe.',
    'Overcast and mild. She turned the sky into a weighted blanket. Honestly kind of soothing girl.',
    'Grey sky flannel night. Very falling asleep in a cozy cottage while it is quiet outside energy babe.',
    'She hid the stars but nailed the temp. Prioritizing comfort over aesthetics. Respect bestie.',
    'Mild overcast night. The kind where you open the window and just listen to the quiet girl.',
  ],
  TemperatureTier.shortsWeather: [
    "Warm under full cloud cover. She said you don't need stars when it's this nice. Fair point girl.",
    "The sky is fully off but the temp is fully on. She's got range bestie.",
    'She deleted the stars and cranked the warmth. Priorities girl.',
    "Warm overcast night. She's giving sleepy princess vibes without the drama babe.",
    'Warm grey night. She said no stars just vibes. Minimalist queen energy babe.',
    'Overcast and warm. The clouds are a cozy lid on a perfect temperature evening bestie.',
  ],
  TemperatureTier.scorcher: [
    "She trapped the heat under a cloud ceiling. We're being slow cooked girl.",
    'No stars no breeze no apology. She meant every degree of this. Lightest PJs babe.',
    "Overcast and scorching. She's giving pressure cooker energy tonight bestie.",
    "She sealed the sky and turned up the heat. We didn't consent to this babe.",
    'Grey sky trapping all the heat like a lid on a pot. She is literally cooking us tonight. Fan on girl.',
  ],
};
