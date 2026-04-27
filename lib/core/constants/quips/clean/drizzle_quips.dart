import '../../../../features/weather/domain/entities/temperature_tier.dart';

const drizzleQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    "Drizzle in single digits. She can't even commit to snow. Stay inside bestie.",
    'Misting at single digits. Annoying and freezing. Every layer you own and stay in girl.',
    'Single digit drizzle. The laziest most disrespectful weather combo. Puffiest coat and stay put babe.',
    'Drizzle this cold is just rude. Blanket burrito and fuzzy socks bestie.',
  ],
  TemperatureTier.freezing: [
    'Freezing drizzle. Too lazy to snow too petty to stop. Heaviest coat on girl.',
    'Below freezing and misting. She chose the most annoying option. Scarf and gloves babe.',
    'Freezing and drizzly. Watch your step out there because this could ice over. Warm boots on bestie.',
    'She is misting below freezing. Layer up and stay dry girl.',
  ],
  TemperatureTier.jacketWeather: [
    'Cool and drizzly. Grab your jacket and a cute umbrella babe.',
    'Drizzle at jacket weather. Hoodie up and go enjoy the moody vibes bestie.',
    'Light mist and cool air. She turned the day into something cozy. Jacket and rain boots on girl.',
    'Drizzly and cool. The kind of weather that makes you want a warm drink. Light layers babe.',
    'Cool drizzle. Jacket and umbrella and you are good to go bestie.',
  ],
  TemperatureTier.flannelWeather: [
    'Mild drizzle. Flannel and a cute umbrella and you are set babe.',
    'Drizzly flannel weather. She added mist to perfection. Cozy sweater and rain boots girl.',
    'She is misting at the perfect temp. The kind of day that feels like a storybook. Cute boots bestie.',
    'Light rain and mild. Flannel on and grab your umbrella just in case babe.',
    'Drizzly and mild. The world looks soft and dewy. Warm sweater on girl.',
  ],
  TemperatureTier.shortsWeather: [
    'Warm drizzle. She is just giving you a gentle spritz. Sandals on and keep going bestie.',
    "Drizzly and warm. Don't even bother going inside. Shorts on girl.",
    'Warm mist on bare legs. It actually feels amazing. Sundress babe.',
    'She added a light spritz to a perfect day. Free spa treatment. Shorts on bestie.',
  ],
  TemperatureTier.scorcher: [
    "Scorching drizzle. She made steam. That's not rain that's a sauna. Lightest clothes girl.",
    'Hot drizzle. She brought a spray bottle to a wildfire. Hat and SPF bestie.',
    'Drizzle on a scorcher. Somehow more humid now. Water bottle in hand babe.',
    'Scorching and misting. The rain evaporates before it lands. Hydrate and find shade girl.',
  ],
};

const drizzleNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    "Light rain in single digits. She's barely trying and still making us miserable. Every layer babe.",
    "She's misting us in the freezing dark. Passive aggressive sprinkler energy. Fuzzy socks on girl.",
    "A drizzle in single digits. She can't even commit to real rain or real cruelty bestie.",
    "Cold drizzle at night. She's giving Cinderella before the fairy godmother showed up. Stay inside babe.",
  ],
  TemperatureTier.freezing: [
    "Freezing drizzle in the dark. She's half-effort misery and it's working. Heaviest coat girl.",
    "She's crying softly in below freezing temps. Scarf and gloves on babe.",
    "Light rain and freezing. She's spritzing us with ice water for fun. Hot cocoa and stay in bestie.",
    "Below freezing with a light drizzle. She's the villain who whispers. Scarier honestly girl.",
  ],
  TemperatureTier.jacketWeather: [
    "Cool drizzle tonight. She's giving rainy fairy tale opening credits energy. Jacket on babe.",
    "Light rain and jacket weather. She's being cute about it for once girl.",
    'She turned the night into a gentle car wash nobody asked for. Grab a jacket bestie.',
    "Cool light rain. If this were a movie you'd be the main character walking through it babe.",
    'Cool drizzle at night. Very Olivia Rodrigo driving through the rain at midnight energy. Jacket on girl.',
    'Light rain and jacket weather. The kind of night where the rain makes everything sparkle babe.',
    'She is misting the city like a fancy skincare routine. Cool enough for a jacket gorgeous enough for a walk bestie.',
  ],
  TemperatureTier.flannelWeather: [
    "Mild drizzle at night. She's giving lo-fi beats and blanket energy girl.",
    'Cozy slumber party night vibes. Flannel on and listen to the rain bestie.',
    "She's doing gentle rain on a mild night. This is her apology for last week babe.",
    "Flannel weather and light rain. She's serenading us through the windows girl.",
    'Flannel weather drizzle. She is giving gentle rain on the window while you drift off energy babe.',
    'Light rain mild night. Very Ariel watching rain hit the ocean from her grotto vibes girl.',
    'Mild drizzle at night. The kind that makes you want to crack a window and just listen bestie.',
  ],
  TemperatureTier.shortsWeather: [
    "Warm drizzle tonight. She's the soft epilogue after a long day babe.",
    'Light warm rain. Streets are glowing and everything is a movie. Go be in it girl.',
    "She's giving summer rain princess energy. Twirl in it bestie.",
    'Warm drizzle. The kind of rain Disney characters dance in babe.',
    'Warm light rain at night. She is misting us like expensive produce and honestly we feel pampered girl.',
    'Drizzly and warm. Very dancing in the rain under string lights energy babe.',
    'Warm night drizzle. She turned the streetlights into little starbursts. Everything is a movie set bestie.',
  ],
  TemperatureTier.scorcher: [
    "Hot drizzle. She's misting us in a sauna. Lightest PJs and fan on girl.",
    "She's adding moisture to the oven. Stay hydrated at this point babe.",
    'Scorching with a light drizzle. She put us in a crockpot and called it weather bestie.',
    "Hot and drizzling. The air feels like soup and honestly we're the ingredients girl.",
  ],
};
