import SwiftUI
import WidgetKit

// MARK: - Widget Background Gallery
//
// WidgetKit previews — one per condition, 12 timeline entries each
// (6 day tiers then 6 night tiers). Scrub the Xcode preview timeline
// to browse all gradient + effect overlay combinations.
//
// City name shows the temperature tier, description shows Day/Night.

// MARK: - Helpers

private let tiers: [(name: String, tempF: Int)] = [
    ("Single Digits", 5), ("Freezing", 25), ("Jacket", 40),
    ("Flannel", 60), ("Shorts", 80), ("Scorcher", 100),
]

/// Builds one gallery timeline entry.
private func ge(_ condition: String, _ tempF: Int, _ isDay: Bool, _ tierName: String) -> WeatherEntry {
    let colors = WidgetGradients.colors(for: condition, tempF: Double(tempF), isDay: isDay)
    let data = WeatherData(
        temperature: tempF,
        feelsLike: tempF,
        high: tempF + 5,
        low: tempF - 5,
        conditionName: condition,
        description: "\(tierName) \(isDay ? "Day" : "Night")",
        isDay: isDay,
        humidity: 50,
        windSpeed: 8,
        uvIndex: 3,
        quip: "\(condition) — \(tierName)",
        persona: "heather",
        cityName: tierName,
        latitude: 34.05,
        longitude: -118.24,
        lastUpdated: "2026-01-01T12:00:00",
        gradientColors: colors,
        hourly: nil,
        sunrise: nil,
        sunset: nil,
        uvIndexMax: nil,
        utcOffsetSeconds: nil,
        sunriseEpoch: nil,
        sunsetEpoch: nil,
        precipLabel: nil,
        alertLabel: nil,
        alertSeverity: nil,
        widgetSummary: nil,
        summaryIsDay: nil,
        moonPhase: nil,
        moonIllumination: nil,
        timelineSegments: nil,
        hasPrecipInTimeline: nil
    )
    return WeatherEntry(date: Date(), data: data, isPlaceholder: false)
}

// MARK: - Previews

#Preview("sunny", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("sunny", 5, true, "Single Digits")
    ge("sunny", 25, true, "Freezing")
    ge("sunny", 40, true, "Jacket")
    ge("sunny", 60, true, "Flannel")
    ge("sunny", 80, true, "Shorts")
    ge("sunny", 100, true, "Scorcher")
    ge("sunny", 5, false, "Single Digits")
    ge("sunny", 25, false, "Freezing")
    ge("sunny", 40, false, "Jacket")
    ge("sunny", 60, false, "Flannel")
    ge("sunny", 80, false, "Shorts")
    ge("sunny", 100, false, "Scorcher")
}

#Preview("mostlySunny", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("mostlySunny", 5, true, "Single Digits")
    ge("mostlySunny", 25, true, "Freezing")
    ge("mostlySunny", 40, true, "Jacket")
    ge("mostlySunny", 60, true, "Flannel")
    ge("mostlySunny", 80, true, "Shorts")
    ge("mostlySunny", 100, true, "Scorcher")
    ge("mostlySunny", 5, false, "Single Digits")
    ge("mostlySunny", 25, false, "Freezing")
    ge("mostlySunny", 40, false, "Jacket")
    ge("mostlySunny", 60, false, "Flannel")
    ge("mostlySunny", 80, false, "Shorts")
    ge("mostlySunny", 100, false, "Scorcher")
}

#Preview("partlyCloudy", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("partlyCloudy", 5, true, "Single Digits")
    ge("partlyCloudy", 25, true, "Freezing")
    ge("partlyCloudy", 40, true, "Jacket")
    ge("partlyCloudy", 60, true, "Flannel")
    ge("partlyCloudy", 80, true, "Shorts")
    ge("partlyCloudy", 100, true, "Scorcher")
    ge("partlyCloudy", 5, false, "Single Digits")
    ge("partlyCloudy", 25, false, "Freezing")
    ge("partlyCloudy", 40, false, "Jacket")
    ge("partlyCloudy", 60, false, "Flannel")
    ge("partlyCloudy", 80, false, "Shorts")
    ge("partlyCloudy", 100, false, "Scorcher")
}

#Preview("overcast", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("overcast", 5, true, "Single Digits")
    ge("overcast", 25, true, "Freezing")
    ge("overcast", 40, true, "Jacket")
    ge("overcast", 60, true, "Flannel")
    ge("overcast", 80, true, "Shorts")
    ge("overcast", 100, true, "Scorcher")
    ge("overcast", 5, false, "Single Digits")
    ge("overcast", 25, false, "Freezing")
    ge("overcast", 40, false, "Jacket")
    ge("overcast", 60, false, "Flannel")
    ge("overcast", 80, false, "Shorts")
    ge("overcast", 100, false, "Scorcher")
}

#Preview("foggy", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("foggy", 5, true, "Single Digits")
    ge("foggy", 25, true, "Freezing")
    ge("foggy", 40, true, "Jacket")
    ge("foggy", 60, true, "Flannel")
    ge("foggy", 80, true, "Shorts")
    ge("foggy", 100, true, "Scorcher")
    ge("foggy", 5, false, "Single Digits")
    ge("foggy", 25, false, "Freezing")
    ge("foggy", 40, false, "Jacket")
    ge("foggy", 60, false, "Flannel")
    ge("foggy", 80, false, "Shorts")
    ge("foggy", 100, false, "Scorcher")
}

#Preview("drizzle", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("drizzle", 5, true, "Single Digits")
    ge("drizzle", 25, true, "Freezing")
    ge("drizzle", 40, true, "Jacket")
    ge("drizzle", 60, true, "Flannel")
    ge("drizzle", 80, true, "Shorts")
    ge("drizzle", 100, true, "Scorcher")
    ge("drizzle", 5, false, "Single Digits")
    ge("drizzle", 25, false, "Freezing")
    ge("drizzle", 40, false, "Jacket")
    ge("drizzle", 60, false, "Flannel")
    ge("drizzle", 80, false, "Shorts")
    ge("drizzle", 100, false, "Scorcher")
}

#Preview("rain", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("rain", 5, true, "Single Digits")
    ge("rain", 25, true, "Freezing")
    ge("rain", 40, true, "Jacket")
    ge("rain", 60, true, "Flannel")
    ge("rain", 80, true, "Shorts")
    ge("rain", 100, true, "Scorcher")
    ge("rain", 5, false, "Single Digits")
    ge("rain", 25, false, "Freezing")
    ge("rain", 40, false, "Jacket")
    ge("rain", 60, false, "Flannel")
    ge("rain", 80, false, "Shorts")
    ge("rain", 100, false, "Scorcher")
}

#Preview("heavyRain", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("heavyRain", 5, true, "Single Digits")
    ge("heavyRain", 25, true, "Freezing")
    ge("heavyRain", 40, true, "Jacket")
    ge("heavyRain", 60, true, "Flannel")
    ge("heavyRain", 80, true, "Shorts")
    ge("heavyRain", 100, true, "Scorcher")
    ge("heavyRain", 5, false, "Single Digits")
    ge("heavyRain", 25, false, "Freezing")
    ge("heavyRain", 40, false, "Jacket")
    ge("heavyRain", 60, false, "Flannel")
    ge("heavyRain", 80, false, "Shorts")
    ge("heavyRain", 100, false, "Scorcher")
}

#Preview("freezingRain", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("freezingRain", 5, true, "Single Digits")
    ge("freezingRain", 25, true, "Freezing")
    ge("freezingRain", 40, true, "Jacket")
    ge("freezingRain", 60, true, "Flannel")
    ge("freezingRain", 80, true, "Shorts")
    ge("freezingRain", 100, true, "Scorcher")
    ge("freezingRain", 5, false, "Single Digits")
    ge("freezingRain", 25, false, "Freezing")
    ge("freezingRain", 40, false, "Jacket")
    ge("freezingRain", 60, false, "Flannel")
    ge("freezingRain", 80, false, "Shorts")
    ge("freezingRain", 100, false, "Scorcher")
}

#Preview("snow", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("snow", 5, true, "Single Digits")
    ge("snow", 25, true, "Freezing")
    ge("snow", 40, true, "Jacket")
    ge("snow", 60, true, "Flannel")
    ge("snow", 80, true, "Shorts")
    ge("snow", 100, true, "Scorcher")
    ge("snow", 5, false, "Single Digits")
    ge("snow", 25, false, "Freezing")
    ge("snow", 40, false, "Jacket")
    ge("snow", 60, false, "Flannel")
    ge("snow", 80, false, "Shorts")
    ge("snow", 100, false, "Scorcher")
}

#Preview("blizzard", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("blizzard", 5, true, "Single Digits")
    ge("blizzard", 25, true, "Freezing")
    ge("blizzard", 40, true, "Jacket")
    ge("blizzard", 60, true, "Flannel")
    ge("blizzard", 80, true, "Shorts")
    ge("blizzard", 100, true, "Scorcher")
    ge("blizzard", 5, false, "Single Digits")
    ge("blizzard", 25, false, "Freezing")
    ge("blizzard", 40, false, "Jacket")
    ge("blizzard", 60, false, "Flannel")
    ge("blizzard", 80, false, "Shorts")
    ge("blizzard", 100, false, "Scorcher")
}

#Preview("thunderstorm", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("thunderstorm", 5, true, "Single Digits")
    ge("thunderstorm", 25, true, "Freezing")
    ge("thunderstorm", 40, true, "Jacket")
    ge("thunderstorm", 60, true, "Flannel")
    ge("thunderstorm", 80, true, "Shorts")
    ge("thunderstorm", 100, true, "Scorcher")
    ge("thunderstorm", 5, false, "Single Digits")
    ge("thunderstorm", 25, false, "Freezing")
    ge("thunderstorm", 40, false, "Jacket")
    ge("thunderstorm", 60, false, "Flannel")
    ge("thunderstorm", 80, false, "Shorts")
    ge("thunderstorm", 100, false, "Scorcher")
}

#Preview("hail", as: .systemSmall) {
    HeatherWeatherWidget()
} timeline: {
    ge("hail", 5, true, "Single Digits")
    ge("hail", 25, true, "Freezing")
    ge("hail", 40, true, "Jacket")
    ge("hail", 60, true, "Flannel")
    ge("hail", 80, true, "Shorts")
    ge("hail", 100, true, "Scorcher")
    ge("hail", 5, false, "Single Digits")
    ge("hail", 25, false, "Freezing")
    ge("hail", 40, false, "Jacket")
    ge("hail", 60, false, "Flannel")
    ge("hail", 80, false, "Shorts")
    ge("hail", 100, false, "Scorcher")
}
