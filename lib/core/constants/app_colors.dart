import 'dart:ui';

class AppColors {
  AppColors._();

  // --- Hero colors ---
  static const magenta = Color(0xFFb50060);
  static const royalBlue = Color(0xFF2563EB);

  // --- Night foundations ---
  static const pitchBlack = Color(0xFF050308);
  static const midnightPurple = Color(0xFF0F0716);
  static const deepPurple = Color(0xFF2E1065);
  static const darkIndigo = Color(0xFF1E1B4B);
  static const darkTeal = Color(0xFF186880);
  static const darkMagenta = Color(0xFFA82058);

  // --- Night bottom accents ---
  static const nightPurple = Color(0xFF400898);
  static const nightBlue = Color(0xFF1830A0);
  static const nightBlueTeal = Color(0xFF186090);
  static const nightGreenTeal = Color(0xFF086040);
  static const nightCoral = Color(0xFF960819);
  static const nightMagenta = Color(0xFF96006b);

  // --- Light / muted ---
  static const palePurple = Color(0xFFEDE9FE);
  static const mutedTeal = Color(0xFF60B8C0);
  static const cream = Color(0xFFFAFAFA);

  // --- Cold tier ---
  static const frostLavender = Color(0xFF7060D0);
  static const coldIndigo = Color(0xFF312E81);

  // --- Sunny day (Electric & Vivid) ---
  static const sunnyElectricBlue = Color(0xFF70A8FF);
  static const sunnyBrightCerulean = Color(0xFF80A8F8);
  static const sunnyVividViolet = Color(0xFF9888F8);
  static const sunnyElectricBlueWarm = Color(0xFF70B0FF);
  static const sunnyCeruleanAqua = Color(0xFF70B8F8);
  static const sunnyElectricAqua = Color(0xFF70D8F8);
  static const sunnyVividTeal = Color(0xFF38C0A0);
  static const sunnyElectricGold = Color(0xFFF0D838);
  static const sunnyVividTangerine = Color(0xFFF08028);
  static const sunnyHotMagenta = Color(0xFFD80070);

  // --- Scorcher tier (night gradients) ---
  static const burntOrange = Color(0xFFF06A0A);
  static const orangeRed = Color(0xFFB91C1C);

  // --- Overcast day ---
  static const overcastTeal = Color(0xFF387898);
  static const overcastSage = Color(0xFF689A50);
  static const overcastMauve = Color(0xFF7454A2);
  static const overcastWisteria = Color(0xFF6858B8);
  static const overcastSkyBlue = Color(0xFF5C8AC0);
  static const overcastBrightViolet = Color(0xFF5454B8);
  static const overcastBrightLilac = Color(0xFF727AC0);
  static const overcastBrightLavender = Color(0xFF9A8AC8);
  static const overcastBrightWisteria = Color(0xFF6454B8);
  static const overcastBrightBlue = Color(0xFF4C6CC0);
  static const overcastBrightIce = Color(0xFF6298D0);
  static const softOvercastGold = Color(0xFFD8C038);
  static const softOvercastOrange = Color(0xFFC07018);
  static const softOrange = Color(0xFFD87420);
  static const softRose = Color(0xFFC84068);

  // --- Drizzle day (Soft Cloud, Punchy Accent) ---
  static const drizzleCloudBlue = Color(0xFF6888D0);
  static const drizzleCloudViolet = Color(0xFF6878C0);
  static const drizzlePunchyLavender = Color(0xFF8878D8);
  static const drizzleCloudPeriwinkle = Color(0xFF5888C8);
  static const drizzlePunchyCyan = Color(0xFF60A8E0);
  static const drizzleCloudMid = Color(0xFF5090C0);
  static const drizzlePunchyTeal = Color(0xFF48C0A8);
  static const drizzleCloudTeal = Color(0xFF48A8B0);
  static const drizzlePunchyGold = Color(0xFFE0C020);
  static const drizzlePunchyTangerine = Color(0xFFF09030);
  static const drizzlePunchyRose = Color(0xFFE84880);

  // --- Rain day (between drizzle & storm) ---
  static const rainBlue = Color(0xFF5878C4);
  static const rainViolet = Color(0xFF5C70B8);
  static const rainLavender = Color(0xFF8074D0);
  static const rainPeriwinkle = Color(0xFF5080C0);
  static const rainCyan = Color(0xFF5CA0DC);
  static const rainMid = Color(0xFF4C88B8);
  static const rainTeal = Color(0xFF44B8A0);
  static const rainMidTeal = Color(0xFF489CA8);
  static const rainGold = Color(0xFFDCBC20);
  static const rainTangerine = Color(0xFFEC8830);
  static const rainRose = Color(0xFFE4487C);

  // --- Heavy rain day (Stormy Blue, Still Fun) ---
  static const stormBlue = Color(0xFF3C5CB0);
  static const stormViolet = Color(0xFF445CA8);
  static const stormRichLavender = Color(0xFF6C64C0);
  static const stormPeriwinkle = Color(0xFF3C6CB0);
  static const stormRichCyan = Color(0xFF4C8CD0);
  static const stormMid = Color(0xFF3C74A8);
  static const stormRichTeal = Color(0xFF34A490);
  static const stormTeal = Color(0xFF3C8498);
  static const stormRichGold = Color(0xFFCCAC18);
  static const stormRichTangerine = Color(0xFFDC7428);
  static const stormRichRose = Color(0xFFD43C70);

  // --- Snow day ---
  static const brightSkyPeriwinkle = Color(0xFF7890D0);
  static const brightFrostLavender = Color(0xFF8070D8);
  static const brightFrostBlue = Color(0xFF60A8D0);
  static const brightIcyBlue = Color(0xFF68B8E8);
  static const brightWarmSkyBlue = Color(0xFF4088B8);
  static const brightAzure = Color(0xFF38A8D8);

  // --- Pre-computed cream alpha variants (avoid per-frame allocations) ---
  static const cream95 = Color(0xF2FAFAFA); // alpha 0.95
  static const cream90 = Color(0xE6FAFAFA); // alpha 0.9
  static const cream85 = Color(0xD9FAFAFA); // alpha 0.85
  static const cream80 = Color(0xCCFAFAFA); // alpha 0.8
  static const cream75 = Color(0xBFFAFAFA); // alpha 0.75
  static const cream70 = Color(0xB3FAFAFA); // alpha 0.7
  static const cream60 = Color(0x99FAFAFA); // alpha 0.6
  static const cream55 = Color(0x8CFAFAFA); // alpha 0.55
  static const cream50 = Color(0x80FAFAFA); // alpha 0.5
  static const cream45 = Color(0x73FAFAFA); // alpha 0.45
  static const cream40 = Color(0x66FAFAFA); // alpha 0.4
  static const cream35 = Color(0x59FAFAFA); // alpha 0.35
  static const cream30 = Color(0x4DFAFAFA); // alpha 0.3
  static const cream25 = Color(0x40FAFAFA); // alpha 0.25
  static const cream22 = Color(0x38FAFAFA); // alpha 0.22
  static const cream20 = Color(0x33FAFAFA); // alpha 0.2
  static const cream18 = Color(0x2EFAFAFA); // alpha 0.18
  static const cream15 = Color(0x26FAFAFA); // alpha 0.15
  static const cream12 = Color(0x1FFAFAFA); // alpha 0.12
  static const cream10 = Color(0x1AFAFAFA); // alpha 0.1
  static const cream08 = Color(0x14FAFAFA); // alpha 0.08
  static const cream06 = Color(0x0FFAFAFA); // alpha 0.06
  static const cream03 = Color(0x08FAFAFA); // alpha 0.03
  static const cream02 = Color(0x05FAFAFA); // alpha 0.02

  // --- Pre-computed black alpha variants ---
  static const black30 = Color(0x4D000000); // alpha 0.3
  static const black12 = Color(0x1F000000); // alpha 0.12
}
