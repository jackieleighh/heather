import '../../../../features/weather/domain/entities/temperature_tier.dart';

const freezingRainQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'Freezing rain in single digits. Every surface is a trap. Stay inside girl.',
    'Ice rain at single digits. Do not leave the house. Warmest boots if you absolutely must bestie.',
    'She glazed the world like a fairy tale curse. Single digits and slippery. Every layer and stay in babe.',
    'Freezing rain this cold. Stay safe and stay inside girl.',
  ],
  TemperatureTier.freezing: [
    'Freezing rain. She iced everything. Warmest boots and stay safe bestie.',
    'She is coating everything in ice. Heavy coat and watch every single step babe.',
    'Below freezing ice rain. Gloves on and be so careful out there girl.',
    'Freezing rain. The sidewalk is a slip and slide and nobody signed up for this. Warm boots on bestie.',
  ],
  TemperatureTier.jacketWeather: [
    'Ice at jacket weather. Sneaky and slippery. Rain boots and careful steps girl.',
    'Freezing rain at cool temps. Watch your step in warm boots bestie.',
    'She is glazing everything at jacket weather. Jacket on and be careful out there babe.',
    'Ice at this temp is unexpected and unwelcome. Watch every step girl.',
  ],
  TemperatureTier.flannelWeather: [
    'Ice at mild temps. Something is very wrong. Warm boots on bestie.',
    'Freezing rain at flannel weather. Be careful in your boots babe.',
    'Mild air but the ground is an ice rink. Stay inside girl.',
    'The temp says flannel but the ice says stay inside. Trust the ice bestie.',
  ],
};

const freezingRainNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'The sidewalk is a slip and slide tonight. Do not leave the house girl.',
    "She's coating everything in ice in the freezing dark. Villain who loves crafts energy babe.",
    'Your driveway is an ice rink nobody auditioned for. Stay inside in your warmest PJs bestie.',
    'She turned the whole block into a glass sculpture. Pretty and deadly girl.',
  ],
  TemperatureTier.freezing: [
    "She's laminating the neighborhood in ice layer by layer. Very thorough babe.",
    'Freezing rain at night. She shellacked the whole city and went to bed girl.',
    'She said let me make the cold slippery too. Heaviest coat and warm boots bestie.',
    'Every surface is getting an ice glaze tonight. Do not go outside babe.',
  ],
  TemperatureTier.jacketWeather: [
    "Freezing rain at jacket temps. She's being dramatic for no reason girl.",
    "Ice forming on surfaces that have no business being icy. She's overperforming babe.",
    'She brought black ice to a jacket weather party. Read the room bestie.',
    "The sidewalk is a trap tonight. She set it up and she's watching girl.",
  ],
  TemperatureTier.flannelWeather: [
    'Freezing rain at mild temps. The math is not mathing tonight babe.',
    'She brought a winter weapon to a spring night. Read the room girl.',
    'Ice on a flannel night. The vibes are confused and so is the weather app bestie.',
    "She's not making sense and she doesn't care. Chaos princess energy babe.",
  ],
  TemperatureTier.shortsWeather: [
    'Freezing rain in warm temps. Physics left the chat and science is crying girl.',
    "She's breaking the laws of nature and looking unbothered doing it babe.",
    "Ice forming when it's warm out. The weather is having a full identity crisis bestie.",
    "She showed up to the wrong season with the wrong precipitation and she's owning it girl.",
  ],
  TemperatureTier.scorcher: [
    "Hot and icy at the same time. She's giving plot twist nobody asked for babe.",
    "Freezing rain in a scorcher. The forecast didn't study for the exam girl.",
    "She's serving hot and cold at the same time. Chaotic queen energy bestie.",
    "Ice in a heat wave. She's unhinged and she's not even sorry babe.",
  ],
};
