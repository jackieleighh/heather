import '../../../../features/weather/domain/entities/temperature_tier.dart';

const rainQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'Rain in single digits. She chose the cruelest combo. Stay inside in every layer bestie.',
    'Pouring at single digits. Do not go outside. Fuzzy socks and a warm blanket girl.',
    'She picked rain and single digits. Stay in your blanket burrito babe.',
    'Rain this cold is a personal attack. Puffiest coat if you must go out bestie.',
  ],
  TemperatureTier.freezing: [
    'Below freezing rain. She really went for maximum drama today. Heaviest coat girl.',
    'Rain and freezing. Warm boots and scarf. Do not leave without full winter gear bestie.',
    'Freezing rain. She woke up and chose misery for everyone. Heavy coat and gloves babe.',
    'She combined cold and wet. Heavy coat scarf and waterproof boots girl.',
    'Cold rain. Do not leave without your heaviest coat and something waterproof bestie.',
  ],
  TemperatureTier.jacketWeather: [
    'Rainy and cool. Grab your umbrella and your cutest rain boots bestie.',
    'Rain at jacket weather. Jacket and umbrella and you are set babe.',
    "She's raining at jacket temp. Cute umbrella on and splash through some puddles girl.",
    'Cool and rainy. Rain boots and your cutest umbrella. Go enjoy the moody vibes bestie.',
    'Rainy and jacket weather. The kind of day a good raincoat was made for babe.',
  ],
  TemperatureTier.flannelWeather: [
    'Rain at this temp. Cozy sweater on and watch it from the window with a warm drink girl.',
    'She is raining at the perfect temp. Hot chocolate and your coziest flannel bestie.',
    'Mild and rainy. She understood the cozy assignment. Cute boots on babe.',
    'Rainy flannel weather. The kind of day that makes you want to bake something girl.',
    'Mild rain. Curl up in your warmest sweater or grab an umbrella and go splash around bestie.',
  ],
  TemperatureTier.shortsWeather: [
    'Warm rain. The kind you dance in. Sandals on and go enjoy it girl.',
    'Rainy and warm. Every puddle is an invitation. Go jump in one bestie.',
    'Warm enough to stand in her and smile. Free therapy from the sky. Shorts on babe.',
    "She is raining warm. Sundress and sandals and don't even worry about it girl.",
  ],
  TemperatureTier.scorcher: [
    'Rain on a scorcher. She is fighting the heat with water. Lightest clothes girl.',
    'Hot rain. Relief is dramatic and wet and we are grateful. Shorts on bestie.',
    'She is hosing down everything and honestly everyone needed this. Sandals on babe.',
    'Scorching rain. The sky is sweating and crying at the same time. Honestly relatable. Stay hydrated girl.',
  ],
};

const rainNightQuips = <TemperatureTier, List<String>>{
  TemperatureTier.singleDigits: [
    'Rain and single digits in the dark. She chose the villain arc tonight. Stay inside girl.',
    "She's sobbing in the cold and taking us all down with her. Blanket burrito babe.",
    "Freezing rain at night. She's giving Bambi sad scene energy times a thousand bestie.",
    "Cold pouring rain in the dark. She snapped and didn't look back. Warmest PJs girl.",
  ],
  TemperatureTier.freezing: [
    'Below freezing and pouring. She went full send on the misery tonight. Hot cocoa babe.',
    "Freezing rain after dark. She's giving tragic ballad energy and we're the audience girl.",
    "She's raining like she's getting paid overtime. Below freezing too. Committed queen bestie.",
    'Rain and freezing temps. The streets are glossy and everything is miserable. Heaviest coat babe.',
    'Below freezing rain in the dark. She is giving tragic princess locked in a tower during a storm energy babe.',
    'Freezing night rain. Very dramatic scene where the hero almost gives up but does not. Stay inside bestie.',
    'Rain and freezing at night. She wrote the saddest Taylor Swift bridge and made us live in it girl.',
  ],
  TemperatureTier.jacketWeather: [
    "Rainy cool night. She's performing and the streetlights are her stage lighting girl.",
    'Steady rain and jacket weather. The sound alone is free therapy babe.',
    "She's washing the city and charging us for the show. Jacket on bestie.",
    "Cool rainy night. She's giving main character looking out the window energy girl.",
    'Cool rainy night. Very Raya searching through the rain at midnight energy. Jacket and tea babe.',
    'Rain at jacket weather. She is giving cozy mystery where you solve the case from bed girl.',
    'Night rain and cool air. The kind that sounds like a lullaby if lullabies had bass drops bestie.',
    'Cool and rainy tonight. She is giving Sabrina Carpenter music video shot in the rain babe.',
  ],
  TemperatureTier.flannelWeather: [
    'Mild rain at night. Crack the window and let her soundtrack in babe.',
    "Rainy flannel night. She tucked us in with rain sounds. Didn't ask. Needed it girl.",
    "She's serenading us through the windows. Cozy sweater and hot cocoa bestie.",
    "Mild night with steady rain. She's giving rainy night in a cottage babe.",
    'Rainy mild night. Crack the window and let her sing you to sleep girl.',
    'Flannel weather rain at night. Very reading by lamplight with rain on the glass vibes babe.',
    'She is doing her rain thing at the perfect temp. This is the ASMR we needed bestie.',
    'Mild rainy night. The kind where you fall asleep to the sound and wake up feeling healed girl.',
  ],
  TemperatureTier.shortsWeather: [
    'Warm rain at night. She wants you outside getting dramatic. Light clothes babe.',
    'She wants us outside getting soaked. Warm enough to consider it honestly girl.',
    "Warm rainy night. Go stand in it like you're in a music video bestie.",
    "She's being cinematic and warm. We're living in her movie tonight girl.",
    'Warm rainy night. Very slow dancing alone in the living room with the windows open energy babe.',
    'Rain and warm at night. She wants us outside being dramatic. She might be right bestie.',
    'Warm night rain. The puddles are reflecting the streetlights like tiny mirrors. She is an artist girl.',
  ],
  TemperatureTier.scorcher: [
    "Hot rain. She's trying to cool us down and failing. A for effort babe.",
    'Scorching and pouring. She said let me steam you like a dumpling girl.',
    'Hot wet rain at night. This is not the spa day we ordered bestie.',
    "Raining and still scorching. She's power washing us with warm water babe.",
    'Hot night rain. She is pressure washing us with warm water and calling it atmosphere. Fan on bestie.',
  ],
};
