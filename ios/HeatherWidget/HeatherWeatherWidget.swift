import SwiftUI
import WidgetKit

struct WeatherEntry: TimelineEntry {
    let date: Date
    let data: WeatherData
    let isPlaceholder: Bool
}

struct HeatherWeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), data: .placeholder, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let data = WeatherData.load() ?? .placeholder
        let entry = WeatherEntry(date: Date(), data: data, isPlaceholder: context.isPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let cached = WeatherData.load() ?? .placeholder

        guard let lat = cached.latitude, let lon = cached.longitude else {
            let entry = WeatherEntry(date: Date(), data: cached, isPlaceholder: false)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            return
        }

        Task {
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

            guard let response = await WeatherFetcher.fetch(latitude: lat, longitude: lon) else {
                let entry = WeatherEntry(date: Date(), data: cached, isPlaceholder: false)
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
                return
            }

            let isDay = response.current.is_day == 1
            let condition = WeatherFetcher.conditionName(from: response.current.weather_code)
            let description = WeatherFetcher.description(from: response.current.weather_code)
            let temp = response.current.temperature_2m
            let gradientColors = WidgetGradients.colors(for: condition, tempF: temp, isDay: isDay)

            let freshQuip = WidgetQuips.pickQuip(condition: condition, tempF: temp) ?? cached.quip

            // Build next-8-hours hourly entries
            var hourlyEntries: [HourlyEntry]? = nil
            if let hourly = response.hourly {
                let now = Date()
                let isoFmt = ISO8601DateFormatter()
                isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let fallbackFmt = DateFormatter()
                fallbackFmt.dateFormat = "yyyy-MM-dd'T'HH:mm"

                // Find the first hour >= now, then take 8
                var startIdx = 0
                for (i, timeStr) in hourly.time.enumerated() {
                    if let d = isoFmt.date(from: timeStr) ?? fallbackFmt.date(from: timeStr), d >= now {
                        startIdx = i
                        break
                    }
                }
                let endIdx = min(startIdx + 8, hourly.time.count)
                if startIdx < endIdx {
                    hourlyEntries = (startIdx..<endIdx).map { i in
                        HourlyEntry(
                            time: hourly.time[i],
                            temperature: Int(hourly.temperature_2m[i].rounded()),
                            weatherCode: hourly.weather_code[i]
                        )
                    }
                }
            }

            let fresh = WeatherData(
                temperature: Int(temp.rounded()),
                feelsLike: Int(response.current.apparent_temperature.rounded()),
                high: Int(response.daily.temperature_2m_max[0].rounded()),
                low: Int(response.daily.temperature_2m_min[0].rounded()),
                conditionName: condition,
                description: description,
                isDay: isDay,
                humidity: response.current.relative_humidity_2m,
                windSpeed: Int(response.current.wind_speed_10m.rounded()),
                uvIndex: Int(response.current.uv_index.rounded()),
                quip: freshQuip,
                persona: cached.persona,
                cityName: cached.cityName,
                latitude: lat,
                longitude: lon,
                lastUpdated: ISO8601DateFormatter().string(from: Date()),
                gradientColors: gradientColors,
                hourly: hourlyEntries,
                sunrise: response.daily.sunrise?.first,
                sunset: response.daily.sunset?.first,
                uvIndexMax: response.daily.uv_index_max?.first.map { Int($0.rounded()) }
            )

            WeatherData.save(fresh)

            let entry = WeatherEntry(date: Date(), data: fresh, isPlaceholder: false)
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }
}

struct HeatherWeatherWidget: Widget {
    let kind = "HeatherWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatherWeatherProvider()) { entry in
            HeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Heather Weather")
        .description("Your sassy weather at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
