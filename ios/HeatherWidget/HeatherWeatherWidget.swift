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
            guard let response = await WeatherFetcher.fetch(latitude: lat, longitude: lon) else {
                let entry = WeatherEntry(date: Date(), data: cached, isPlaceholder: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
                return
            }

            let now = Date()
            let calendar = Calendar.current
            let condition = WeatherFetcher.conditionName(from: response.current.weather_code)
            let description = WeatherFetcher.description(from: response.current.weather_code)
            let temp = response.current.temperature_2m

            // Parse all hourly times upfront
            let isoFmt = ISO8601DateFormatter()
            isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let fallbackFmt = DateFormatter()
            fallbackFmt.dateFormat = "yyyy-MM-dd'T'HH:mm"

            var hourlyDates: [Date] = []
            if let hourly = response.hourly {
                hourlyDates = hourly.time.map { timeStr in
                    isoFmt.date(from: timeStr) ?? fallbackFmt.date(from: timeStr) ?? .distantPast
                }
            }

            // Generate timeline entries every 30 minutes for the next 3 hours.
            // Each entry slides the hourly window forward and picks a fresh quip,
            // so the widget stays visually current even if WidgetKit delays the
            // next getTimeline call.
            var entries: [WeatherEntry] = []
            let entryCount = 6
            let intervalMinutes = 30

            for i in 0..<entryCount {
                let entryDate = calendar.date(byAdding: .minute, value: i * intervalMinutes, to: now)!

                // Determine day/night for this entry's time
                let entryIsDay: Bool
                if let sunrise = response.daily.sunrise?.first,
                   let sunset = response.daily.sunset?.first,
                   let sunriseDate = isoFmt.date(from: sunrise) ?? fallbackFmt.date(from: sunrise),
                   let sunsetDate = isoFmt.date(from: sunset) ?? fallbackFmt.date(from: sunset) {
                    entryIsDay = entryDate >= sunriseDate && entryDate < sunsetDate
                } else {
                    entryIsDay = response.current.is_day == 1
                }

                let gradientColors = WidgetGradients.colors(for: condition, tempF: temp, isDay: entryIsDay)
                let quip = WidgetQuips.pickQuip(condition: condition, tempF: temp) ?? cached.quip

                // Slide the hourly window to start at this entry's time
                var hourlyEntries: [HourlyEntry]? = nil
                if let hourly = response.hourly {
                    var startIdx = 0
                    for (j, date) in hourlyDates.enumerated() {
                        if date >= entryDate {
                            startIdx = j
                            break
                        }
                    }
                    let endIdx = min(startIdx + 6, hourly.time.count)
                    if startIdx < endIdx {
                        hourlyEntries = (startIdx..<endIdx).map { j in
                            HourlyEntry(
                                time: hourly.time[j],
                                temperature: Int(hourly.temperature_2m[j].rounded()),
                                weatherCode: hourly.weather_code[j]
                            )
                        }
                    }
                }

                let data = WeatherData(
                    temperature: Int(temp.rounded()),
                    feelsLike: Int(response.current.apparent_temperature.rounded()),
                    high: Int(response.daily.temperature_2m_max[0].rounded()),
                    low: Int(response.daily.temperature_2m_min[0].rounded()),
                    conditionName: condition,
                    description: description,
                    isDay: entryIsDay,
                    humidity: response.current.relative_humidity_2m,
                    windSpeed: Int(response.current.wind_speed_10m.rounded()),
                    uvIndex: Int(response.current.uv_index.rounded()),
                    quip: quip,
                    persona: cached.persona,
                    cityName: cached.cityName,
                    latitude: lat,
                    longitude: lon,
                    lastUpdated: ISO8601DateFormatter().string(from: entryDate),
                    gradientColors: gradientColors,
                    hourly: hourlyEntries,
                    sunrise: response.daily.sunrise?.first,
                    sunset: response.daily.sunset?.first,
                    uvIndexMax: response.daily.uv_index_max?.first.map { Int($0.rounded()) }
                )

                entries.append(WeatherEntry(date: entryDate, data: data, isPlaceholder: false))
            }

            // Save the first (current) entry for snapshot fallback
            if let first = entries.first {
                WeatherData.save(first.data)
            }

            // Use .atEnd so WidgetKit requests a fresh timeline as soon as
            // all entries have been displayed, rather than waiting for a
            // budget-throttled .after() window.
            completion(Timeline(entries: entries, policy: .atEnd))
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
        .contentMarginsDisabled()
    }
}
