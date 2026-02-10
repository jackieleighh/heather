import '../../features/weather/domain/entities/weather_condition.dart';

class AppStrings {
  AppStrings._();

  static const appName = 'Heather';

  static const geminiPrompt =
      'You are Heather, a sharp-witted weather girl with Cher from Clueless '
      'energy meets Gen Z. You are NOT bubbly or cutesy. You are sarcastic, '
      'confident, and a little judgmental (lovingly). You give actual style '
      'and practical advice mixed with attitude - like whether to bring an '
      'umbrella, what to wear, or if they should just stay home. '
      'Generate ONE quip (max 20 words). No hashtags, no emojis. Just the quip.';

  static const Map<WeatherCondition, List<String>> fallbackQuips = {
    WeatherCondition.clear: [
      'Sunglasses. SPF. That one top you look hot in. You know the one.',
      'Not a cloud in sight. You literally have no excuse to cancel plans.',
      "It's gorgeous out. If you stay inside I'm judging you.",
      'Perfect weather to wear something you bought and never wore.',
      'The sun is doing its job. Now go do yours. But outside.',
      'Sunscreen or wrinkles. I know which one I picked.',
      "Clear skies, so there's literally nothing to complain about. Try anyway.",
      'Wear the short shorts. The weather is giving you permission.',
    ],
    WeatherCondition.cloudy: [
      'Overcast but not raining. Bring a jacket anyway, trust me.',
      "Layers. It's a layers kind of day. Don't fight it.",
      'Gloomy out so your outfit needs to do the heavy lifting.',
      "It could go either way. Toss an umbrella in your bag, I'm serious.",
      "The sun is taking a personal day. Can't relate but okay.",
      "Grey skies. Wear color unless you want to match the sky's depression.",
      "Hoodie weather. Not cute hoodie. Actual warmth hoodie. You'll thank me.",
      'The sky looks like it might start something. Be prepared.',
    ],
    WeatherCondition.rain: [
      "Umbrella. Non-negotiable. I don't want to hear about it later.",
      "It's raining. Your suede shoes stay home today. I mean it.",
      'Waterproof mascara or regret. Those are your two options.',
      'Rain boots or wet socks. This is not a difficult decision.',
      'Skip the blowout. The humidity is going to humble you regardless.',
      'Grab a rain jacket. Looking like a drowned rat is not a vibe.',
      "It's pouring. Cancel the outdoor plans. You're welcome.",
      'Wet outside. Bring an umbrella or accept your fate.',
    ],
    WeatherCondition.snow: [
      "It's snowing. Wear actual boots, not the cute ones.",
      'Layer up or freeze. Mother Nature is not negotiating today.',
      "Puffy jacket weather. Fashion died today and that's fine.",
      "Roads are going to be a mess. Leave early or don't leave at all.",
      'Hot coffee, warm coat, thick socks. In that order.',
      "It's freezing. If your coat isn't warm enough, stay home.",
      'Snow looks cute until you have to drive in it. Be careful.',
      'Wear a hat. Nobody cares about hat hair when it\'s this cold.',
    ],
    WeatherCondition.thunderstorm: [
      'Stay inside. I repeat. Stay inside.',
      "Thunder means nature is in a mood. Don't test her.",
      "If you hear lightning, that's your cue to cancel everything.",
      "It's literally storming. Your plans can wait. You cannot outrun this.",
      "Couch, blanket, movie. That's the only acceptable itinerary right now.",
      "Charging your phone in case the power goes out. You're welcome for the tip.",
      'Thunderstorm outside. The only thing you should grab is a blanket.',
      'Do not be a hero. Stay inside and look cute from your window.',
    ],
    WeatherCondition.fog: [
      'Can barely see anything. Drive slow and put your headlights on. Seriously.',
      'Foggy. Mysterious. Keep your high beams off though, babe.',
      'Visibility is garbage. Take it slow out there.',
      'The fog is thick. Honestly just work from home if you can.',
      "It's giving horror movie outside. Drive carefully or just don't.",
      'Leave early because you will be driving 20 under. Accept it.',
      "If you can't see the road, the road can't see you. Headlights on.",
      'Looking outside and seeing nothing. Much like my love life. But drive safe.',
    ],
    WeatherCondition.drizzle: [
      'It\'s sprinkling just enough to ruin your hair. Bring a hood.',
      'Light rain. Not enough for an umbrella, too much for nothing. Hat.',
      "Drizzling. Your leather jacket will survive but your blowout won't.",
      "It's that annoying almost-rain. Bring an umbrella just in case.",
      'A little mist never killed anyone but it will kill your straightening job.',
      'Not quite raining, not quite dry. Waterproof jacket. Done.',
      'Drizzle outside. The kind that makes you look slightly unhinged arriving anywhere.',
      "Pack an umbrella. It's giving rain but being passive-aggressive about it.",
    ],
  };

  static const List<String> hotQuips = [
    "It's giving actual heatstroke. Hydrate or die. Not being dramatic.",
    'SPF 50 minimum. Your future self will write you a thank-you note.',
    "Wear as little as legally possible. I don't make the rules.",
    "It's so hot the asphalt is basically lava. Protect your feet.",
    'Iced coffee. Not hot. I should not have to say this.',
    "Your makeup will melt off your face before noon. Setting spray or don't bother.",
    "Stay inside between 12 and 3 unless you enjoy being cooked alive.",
    'Hair up, shoulders out, water bottle full. That is the assignment.',
    "It's disgustingly hot. Linen is your best friend today.",
    "The heat index is a personal attack. Dress accordingly.",
  ];

  static const List<String> coldQuips = [
    "It's freezing. Like actually freezing. Dress like you believe it.",
    'Layer up. Then add one more layer. Trust the process.',
    "Your cute jacket is not warm enough. Wear the ugly puffy one.",
    "Exposed ankles in this weather? Absolutely not. Wear real socks.",
    "It's giving frostbite. Cover every square inch of skin you can.",
    "Hot drink in hand at all times. This is non-negotiable.",
    "If your coat doesn't go past your hips it's not doing its job.",
    'Thermal underwear. Nobody has to know. But you will be warm.',
    "Don't be a hero. Wear the hat, the scarf, and the gloves. All three.",
    "It's brutally cold. If you don't need to go out, simply don't.",
  ];
}
