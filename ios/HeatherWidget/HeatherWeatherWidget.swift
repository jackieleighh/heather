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
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
            return
        }

        // Check if cached data (pushed from Dart) is fresh enough to skip the API call.
        // The Dart background task refreshes every ~14 min, so if lastUpdated is
        // within 14 minutes we can trust the cached data and avoid a double-fetch.
        let cachedIsFresh: Bool = {
            let updatedStr = cached.lastUpdated
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm",
            ]
            var updatedDate: Date?
            for fmt in formats {
                let df = DateFormatter()
                df.dateFormat = fmt
                df.locale = Locale(identifier: "en_US_POSIX")
                if let d = df.date(from: updatedStr) {
                    updatedDate = d
                    break
                }
            }
            if updatedDate == nil {
                let iso = ISO8601DateFormatter()
                iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                updatedDate = iso.date(from: updatedStr)
            }
            guard let date = updatedDate else { return false }
            return Date().timeIntervalSince(date) < 14 * 60
        }()

        Task {
            // Use cached data if it's fresh; only fetch from Open-Meteo as a fallback
            let response: OpenMeteoResponse?
            if cachedIsFresh {
                response = nil  // Skip API call — we'll build entries from cached data
            } else {
                response = await WeatherFetcher.fetch(latitude: lat, longitude: lon)
            }

            // If cache is stale AND the fetch failed, fall back to cached data
            if !cachedIsFresh && response == nil {
                let entry = WeatherEntry(date: Date(), data: cached, isPlaceholder: false)
                let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
                return
            }

            let now = Date()
            let calendar = Calendar.current

            // When using fresh cached data, build entries from it directly.
            // When we fetched from the API, parse the response as before.
            if cachedIsFresh {
                // Build timeline entries from cached Dart-pushed data
                var entries: [WeatherEntry] = []
                let entryCount = 24
                let intervalMinutes = 15

                // Use the weather location's timezone for parsing time strings.
                let locationTZ = cached.locationTimeZone

                // Parse cached hourly times for sliding window.
                // Prefer epoch timestamps (timezone-independent) when available.
                var hourlyDates: [Date] = []
                if let hourly = cached.hourly {
                    hourlyDates = hourly.map { entry in
                        entry.absoluteDate(locationTZ: locationTZ)
                    }
                }

                // Use time-stable quip (changes every ~3 hours, not every push)
                let batchQuip = WidgetQuips.pickQuip(
                    condition: cached.conditionName,
                    tempF: Double(cached.temperature)
                ) ?? cached.quip

                for i in 0..<entryCount {
                    let entryDate = calendar.date(byAdding: .minute, value: i * intervalMinutes, to: now)!

                    // Slide hourly window for this entry.
                    // Only slide when we have reliable timezone info (epoch or utcOffsetSeconds).
                    // Without timezone info, hourly dates are parsed in device timezone which
                    // may differ from the weather location, causing wrong window selection.
                    var slidHourly: [HourlyEntry]? = nil
                    let hasTimezoneInfo = cached.utcOffsetSeconds != nil ||
                        cached.hourly?.first?.epoch != nil
                    if let hourly = cached.hourly, !hourlyDates.isEmpty, hasTimezoneInfo {
                        var startIdx = 0
                        for (j, date) in hourlyDates.enumerated() {
                            if date >= entryDate {
                                startIdx = j
                                break
                            }
                        }
                        let endIdx = min(startIdx + 6, hourly.count)
                        if startIdx < endIdx {
                            slidHourly = Array(hourly[startIdx..<endIdx])
                        }
                    } else if let hourly = cached.hourly {
                        // No timezone info: Dart already filtered hourly to start at the
                        // current location hour, so just take the first 6 entries.
                        let endIdx = min(6, hourly.count)
                        slidHourly = Array(hourly[0..<endIdx])
                    }

                    // Determine day/night for this entry.
                    // Only recalculate when we have reliable timezone info for sunrise/sunset.
                    // Without it, trust the Dart-provided isDay value.
                    var entryIsDay = cached.isDay
                    if hasTimezoneInfo,
                       let sunriseDate = cached.sunriseDate,
                       let sunsetDate = cached.sunsetDate {
                        entryIsDay = entryDate >= sunriseDate && entryDate < sunsetDate
                    }

                    let gradientColors = WidgetGradients.colors(
                        for: cached.conditionName,
                        tempF: Double(cached.temperature),
                        isDay: entryIsDay
                    )

                    let data = WeatherData(
                        temperature: cached.temperature,
                        feelsLike: cached.feelsLike,
                        high: cached.high,
                        low: cached.low,
                        conditionName: cached.conditionName,
                        description: cached.description,
                        isDay: entryIsDay,
                        humidity: cached.humidity,
                        windSpeed: cached.windSpeed,
                        uvIndex: cached.uvIndex,
                        quip: batchQuip,
                        persona: cached.persona,
                        cityName: cached.cityName,
                        latitude: lat,
                        longitude: lon,
                        lastUpdated: cached.lastUpdated,
                        gradientColors: gradientColors,
                        hourly: slidHourly,
                        sunrise: cached.sunrise,
                        sunset: cached.sunset,
                        uvIndexMax: cached.uvIndexMax,
                        utcOffsetSeconds: cached.utcOffsetSeconds,
                        sunriseEpoch: cached.sunriseEpoch,
                        sunsetEpoch: cached.sunsetEpoch,
                        precipLabel: cached.precipLabel,
                        alertLabel: cached.alertLabel,
                        alertSeverity: cached.alertSeverity
                    )

                    entries.append(WeatherEntry(date: entryDate, data: data, isPlaceholder: false))
                }

                completion(Timeline(entries: entries, policy: .atEnd))
                return
            }

            // --- Fetched fresh data from Open-Meteo ---
            let fetched = response!
            let condition = WeatherFetcher.conditionName(from: fetched.current.weather_code)
            let description = WeatherFetcher.description(from: fetched.current.weather_code)
            let temp = fetched.current.temperature_2m

            // Use the weather location's timezone for parsing local time strings
            let fetchedTZ = TimeZone(secondsFromGMT: fetched.utc_offset_seconds) ?? .current

            // Parse all hourly times upfront
            let isoFmt = ISO8601DateFormatter()
            isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let fallbackFmt = DateFormatter()
            fallbackFmt.dateFormat = "yyyy-MM-dd'T'HH:mm"
            fallbackFmt.locale = Locale(identifier: "en_US_POSIX")
            fallbackFmt.timeZone = fetchedTZ

            var hourlyDates: [Date] = []
            if let hourly = fetched.hourly {
                hourlyDates = hourly.time.map { timeStr in
                    isoFmt.date(from: timeStr) ?? fallbackFmt.date(from: timeStr) ?? .distantPast
                }
            }

            // Generate timeline entries every 15 minutes for the next 6 hours.
            // Each entry slides the hourly window forward and picks a fresh quip,
            // so the widget stays visually current even if WidgetKit delays the
            // next getTimeline call.
            var entries: [WeatherEntry] = []
            let entryCount = 24
            let intervalMinutes = 15

            // Pick one quip for the entire timeline batch so it stays
            // stable across entries (changes only every ~6 hours).
            let batchQuip = WidgetQuips.pickQuip(condition: condition, tempF: temp) ?? cached.quip

            for i in 0..<entryCount {
                let entryDate = calendar.date(byAdding: .minute, value: i * intervalMinutes, to: now)!

                // Determine day/night for this entry's time
                let entryIsDay: Bool
                if let sunrise = fetched.daily.sunrise?.first,
                   let sunset = fetched.daily.sunset?.first,
                   let sunriseDate = isoFmt.date(from: sunrise) ?? fallbackFmt.date(from: sunrise),
                   let sunsetDate = isoFmt.date(from: sunset) ?? fallbackFmt.date(from: sunset) {
                    entryIsDay = entryDate >= sunriseDate && entryDate < sunsetDate
                } else {
                    entryIsDay = fetched.current.is_day == 1
                }

                let gradientColors = WidgetGradients.colors(for: condition, tempF: temp, isDay: entryIsDay)
                let quip = batchQuip

                // Slide the hourly window to start at this entry's time
                var hourlyEntries: [HourlyEntry]? = nil
                if let hourly = fetched.hourly {
                    // Parse daily sunrise/sunset arrays for per-hour isDay
                    let dailySunrise: [Date] = (fetched.daily.sunrise ?? []).compactMap {
                        isoFmt.date(from: $0) ?? fallbackFmt.date(from: $0)
                    }
                    let dailySunset: [Date] = (fetched.daily.sunset ?? []).compactMap {
                        isoFmt.date(from: $0) ?? fallbackFmt.date(from: $0)
                    }

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
                            let hourDate = hourlyDates[j]
                            let hourIsDay = Self.isHourDay(
                                hourDate,
                                dailySunrise: dailySunrise,
                                dailySunset: dailySunset,
                                fallback: fetched.current.is_day == 1,
                                timeZone: fetchedTZ
                            )
                            return HourlyEntry(
                                time: hourly.time[j],
                                epoch: nil,
                                temperature: Int(hourly.temperature_2m[j].rounded()),
                                weatherCode: hourly.weather_code[j],
                                isDay: hourIsDay
                            )
                        }
                    }
                }

                let data = WeatherData(
                    temperature: Int(temp.rounded()),
                    feelsLike: Int(fetched.current.apparent_temperature.rounded()),
                    high: Int(fetched.daily.temperature_2m_max[0].rounded()),
                    low: Int(fetched.daily.temperature_2m_min[0].rounded()),
                    conditionName: condition,
                    description: description,
                    isDay: entryIsDay,
                    humidity: fetched.current.relative_humidity_2m,
                    windSpeed: Int(fetched.current.wind_speed_10m.rounded()),
                    uvIndex: Int(fetched.current.uv_index.rounded()),
                    quip: quip,
                    persona: cached.persona,
                    cityName: cached.cityName,
                    latitude: lat,
                    longitude: lon,
                    lastUpdated: ISO8601DateFormatter().string(from: entryDate),
                    gradientColors: gradientColors,
                    hourly: hourlyEntries,
                    sunrise: fetched.daily.sunrise?.first,
                    sunset: fetched.daily.sunset?.first,
                    uvIndexMax: fetched.daily.uv_index_max?.first.map { Int($0.rounded()) },
                    utcOffsetSeconds: fetched.utc_offset_seconds,
                    sunriseEpoch: nil,
                    sunsetEpoch: nil,
                    precipLabel: cached.precipLabel,
                    alertLabel: cached.alertLabel,
                    alertSeverity: cached.alertSeverity
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

    /// Determines if a given hour should show a day icon, with transition-hour logic.
    /// If sunrise/sunset falls within the hour, use day icon only if >30 min of daylight.
    private static func isHourDay(
        _ hourDate: Date,
        dailySunrise: [Date],
        dailySunset: [Date],
        fallback: Bool,
        timeZone: TimeZone? = nil
    ) -> Bool {
        var cal = Calendar.current
        if let tz = timeZone { cal.timeZone = tz }
        let hourOfDay = cal.component(.hour, from: hourDate)

        // Find matching day's sunrise/sunset by comparing dates
        var sunrise: Date?
        var sunset: Date?
        for (i, sr) in dailySunrise.enumerated() {
            if cal.isDate(sr, inSameDayAs: hourDate) {
                sunrise = sr
                if i < dailySunset.count { sunset = dailySunset[i] }
                break
            }
        }

        guard let sr = sunrise, let ss = sunset else { return fallback }

        let srHour = cal.component(.hour, from: sr)
        let srMin = cal.component(.minute, from: sr)
        let ssHour = cal.component(.hour, from: ss)
        let ssMin = cal.component(.minute, from: ss)

        // Transition-hour logic
        if hourOfDay == srHour {
            return (60 - srMin) > 30
        }
        if hourOfDay == ssHour {
            return ssMin > 30
        }

        let minutes = hourOfDay * 60
        let sunriseMin = srHour * 60 + srMin
        let sunsetMin = ssHour * 60 + ssMin
        return minutes >= sunriseMin && minutes < sunsetMin
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
