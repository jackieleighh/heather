import CoreLocation
import WidgetKit

/// Monitors significant location changes (cell tower transitions) and refreshes
/// the widget data when the user has moved substantially. This uses Apple's
/// battery-efficient API that triggers on ~500m-2km movements.
///
/// Self-contained: doesn't import widget extension types. Builds the same JSON
/// format as WeatherData so the widget can read it.
final class SignificantLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = SignificantLocationManager()

    private let locationManager = CLLocationManager()
    private let appGroupId = "group.com.totms.heather"
    /// Minimum distance in meters before triggering a widget refresh.
    private let minimumDistance: Double = 2000 // 2 km

    private var isMonitoring = false

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    // MARK: - Public API

    /// Starts monitoring if "Always" authorization is granted.
    /// Safe to call multiple times — no-ops if already monitoring.
    func startMonitoringIfAuthorized() {
        let status = locationManager.authorizationStatus
        guard status == .authorizedAlways else { return }
        startMonitoring()
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else { return }
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoring = true
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoring = false
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let newLat = location.coordinate.latitude
        let newLon = location.coordinate.longitude

        guard let userDefaults = UserDefaults(suiteName: appGroupId) else { return }

        let lastLat = userDefaults.double(forKey: "sig_loc_last_lat")
        let lastLon = userDefaults.double(forKey: "sig_loc_last_lon")

        // Always write fresh coords for the Dart background task
        writeNativeCoords(lat: newLat, lon: newLon, userDefaults: userDefaults)

        // If we have a previous location, check distance
        if lastLat != 0 || lastLon != 0 {
            let previousLocation = CLLocation(latitude: lastLat, longitude: lastLon)
            let distance = location.distance(from: previousLocation)
            if distance < minimumDistance {
                return
            }
        }

        // User moved significantly — refresh widget data
        userDefaults.set(newLat, forKey: "sig_loc_last_lat")
        userDefaults.set(newLon, forKey: "sig_loc_last_lon")

        Task {
            await refreshWidgetData(latitude: newLat, longitude: newLon)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            startMonitoring()
        case .authorizedWhenInUse, .denied, .restricted:
            stopMonitoring()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently ignore — widget continues showing last known data
    }

    // MARK: - Widget Refresh

    private func writeNativeCoords(lat: Double, lon: Double, userDefaults: UserDefaults) {
        userDefaults.set(lat, forKey: "native_bg_lat")
        userDefaults.set(lon, forKey: "native_bg_lon")
        userDefaults.set(Date().timeIntervalSince1970, forKey: "native_bg_ts")
    }

    private func refreshWidgetData(latitude: Double, longitude: Double) async {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else { return }

        // Reverse geocode to get city name
        let cityName = await reverseGeocode(latitude: latitude, longitude: longitude)

        // Fetch weather from Open-Meteo
        guard let response = await fetchWeather(latitude: latitude, longitude: longitude) else {
            // Even on failure, reload timelines so the widget can use its own fetch
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let current = response["current"] as? [String: Any] ?? [:]
        let daily = response["daily"] as? [String: Any] ?? [:]
        let hourly = response["hourly"] as? [String: Any] ?? [:]
        let utcOffset = response["utc_offset_seconds"] as? Int ?? 0

        let temp = current["temperature_2m"] as? Double ?? 0
        let feelsLike = current["apparent_temperature"] as? Double ?? 0
        let humidity = current["relative_humidity_2m"] as? Int ?? 0
        let windSpeed = current["wind_speed_10m"] as? Double ?? 0
        let weatherCode = current["weather_code"] as? Int ?? 0
        let isDay = (current["is_day"] as? Int ?? 1) == 1
        let uvIndex = current["uv_index"] as? Double ?? 0

        let highs = daily["temperature_2m_max"] as? [Double] ?? []
        let lows = daily["temperature_2m_min"] as? [Double] ?? []
        let sunrises = daily["sunrise"] as? [String] ?? []
        let sunsets = daily["sunset"] as? [String] ?? []
        let uvMaxes = daily["uv_index_max"] as? [Double] ?? []

        let condition = conditionName(from: weatherCode)
        let description = weatherDescription(from: weatherCode)
        let gradientColors = Self.gradientColors(for: condition, tempF: temp, isDay: isDay)

        // Pick a quip from the stored quip map
        let quip = pickQuip(condition: condition, tempF: temp, userDefaults: userDefaults)
            ?? "Weather's moving, and so are you."

        // Build hourly entries for the next 6 hours
        var hourlyEntries: [[String: Any]] = []
        if let times = hourly["time"] as? [String],
           let temps = hourly["temperature_2m"] as? [Double],
           let codes = hourly["weather_code"] as? [Int] {
            let now = Date()
            let tz = TimeZone(secondsFromGMT: utcOffset) ?? .current
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm"
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = tz

            for i in 0..<times.count {
                guard let hourDate = fmt.date(from: times[i]) else { continue }
                if hourDate < now { continue }
                if hourlyEntries.count >= 6 { break }
                hourlyEntries.append([
                    "time": times[i],
                    "temperature": Int(temps[i].rounded()),
                    "weatherCode": codes[i],
                ])
            }
        }

        // Load existing widget data to preserve alert/moon info
        let existingData = loadExistingWidgetData(userDefaults: userDefaults)

        // Build the widget JSON payload (same format as WeatherData)
        var payload: [String: Any] = [
            "temperature": Int(temp.rounded()),
            "feelsLike": Int(feelsLike.rounded()),
            "high": highs.isEmpty ? 0 : Int(highs[0].rounded()),
            "low": lows.isEmpty ? 0 : Int(lows[0].rounded()),
            "conditionName": condition,
            "description": description,
            "isDay": isDay,
            "humidity": humidity,
            "windSpeed": Int(windSpeed.rounded()),
            "uvIndex": Int(uvIndex.rounded()),
            "quip": quip,
            "persona": existingData["persona"] as? String ?? "heather",
            "cityName": cityName,
            "latitude": latitude,
            "longitude": longitude,
            "lastUpdated": ISO8601DateFormatter().string(from: Date()),
            "gradientColors": gradientColors,
            "utcOffsetSeconds": utcOffset,
        ]

        if !hourlyEntries.isEmpty { payload["hourly"] = hourlyEntries }
        if !sunrises.isEmpty { payload["sunrise"] = sunrises[0] }
        if !sunsets.isEmpty { payload["sunset"] = sunsets[0] }
        if !uvMaxes.isEmpty { payload["uvIndexMax"] = Int(uvMaxes[0].rounded()) }

        // Preserve existing alert/moon data
        if let v = existingData["alertLabel"] { payload["alertLabel"] = v }
        if let v = existingData["alertSeverity"] { payload["alertSeverity"] = v }
        if let v = existingData["alertExpires"] { payload["alertExpires"] = v }
        if let v = existingData["moonPhase"] { payload["moonPhase"] = v }
        if let v = existingData["moonIllumination"] { payload["moonIllumination"] = v }
        if let v = existingData["widgetSummary"] { payload["widgetSummary"] = v }
        if let v = existingData["summaryIsDay"] { payload["summaryIsDay"] = v }
        if let v = existingData["precipLabel"] { payload["precipLabel"] = v }

        // Save to app group
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            userDefaults.set(jsonString, forKey: "widget_data")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Weather Fetch

    private func fetchWeather(latitude: Double, longitude: Double) async -> [String: Any]? {
        let urlString = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(latitude)&longitude=\(longitude)"
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,uv_index"
            + "&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max"
            + "&hourly=temperature_2m,weather_code,precipitation_probability"
            + "&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto&forecast_days=2"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 15
            let session = URLSession(configuration: config)
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            return nil
        }
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(latitude: Double, longitude: Double) async -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let place = placemarks.first {
                return place.locality
                    ?? place.subAdministrativeArea
                    ?? place.administrativeArea
                    ?? "Unknown"
            }
        } catch {}

        // Fall back to existing widget city name
        let existing = loadExistingWidgetData(
            userDefaults: UserDefaults(suiteName: appGroupId) ?? .standard
        )
        return existing["cityName"] as? String ?? "Unknown"
    }

    // MARK: - Helpers

    private func loadExistingWidgetData(userDefaults: UserDefaults) -> [String: Any] {
        guard let jsonString = userDefaults.string(forKey: "widget_data"),
              let data = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }

    private func pickQuip(condition: String, tempF: Double, userDefaults: UserDefaults) -> String? {
        guard let jsonString = userDefaults.string(forKey: "widget_quips"),
              let data = jsonString.data(using: .utf8),
              let map = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String]]] else {
            return nil
        }

        let tier = temperatureTier(from: tempF)
        guard let tiers = map[condition] else { return nil }

        let quips = tiers[tier]
            ?? tiers["flannelWeather"]
            ?? tiers["shortsWeather"]
            ?? tiers.values.first

        guard let quips, !quips.isEmpty else { return nil }

        // Stable index: changes every 3 hours
        let hoursSinceEpoch = Int(Date().timeIntervalSince1970) / (3 * 3600)
        let index = abs(hoursSinceEpoch) % quips.count
        return quips[index]
    }

    private func temperatureTier(from tempF: Double) -> String {
        if tempF < 15 { return "singleDigits" }
        if tempF < 32 { return "freezing" }
        if tempF < 50 { return "jacketWeather" }
        if tempF < 70 { return "flannelWeather" }
        if tempF < 90 { return "shortsWeather" }
        return "scorcher"
    }

    // MARK: - WMO Code Mapping

    private func conditionName(from wmoCode: Int) -> String {
        switch wmoCode {
        case 0: return "sunny"
        case 1: return "mostlySunny"
        case 2: return "partlyCloudy"
        case 3: return "overcast"
        case 45, 48: return "foggy"
        case 51, 53, 55, 80: return "drizzle"
        case 56, 57, 66, 67: return "freezingRain"
        case 61, 63, 81: return "rain"
        case 65, 82: return "heavyRain"
        case 71, 73, 77, 85: return "snow"
        case 75, 86: return "blizzard"
        case 95: return "thunderstorm"
        case 96, 99: return "hail"
        default: return "unknown"
        }
    }

    private func weatherDescription(from wmoCode: Int) -> String {
        switch wmoCode {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Foggy"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snowfall"
        case 73: return "Moderate snowfall"
        case 75: return "Heavy snowfall"
        case 77: return "Snow grains"
        case 80: return "Slight rain"
        case 81: return "Moderate rain"
        case 82: return "Heavy rain"
        case 85: return "Light snow"
        case 86: return "Heavy snow"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown"
        }
    }

    // MARK: - Gradient Colors

    /// Matches WidgetGradients.colors() logic without importing the widget extension.
    private static func gradientColors(for condition: String, tempF: Double, isDay: Bool) -> [String] {
        let tier = tierIndex(from: tempF)
        let resolved = resolveCondition(condition)
        if isDay {
            return dayGradients[resolved]?[tier] ?? dayGradients["overcast"]![tier]
        }
        return nightGradients[resolved]?[tier] ?? nightGradients["overcast"]![tier]
    }

    private static func tierIndex(from tempF: Double) -> Int {
        if tempF < 15 { return 0 }
        if tempF < 32 { return 1 }
        if tempF < 50 { return 2 }
        if tempF < 70 { return 3 }
        if tempF < 90 { return 4 }
        return 5
    }

    private static func resolveCondition(_ condition: String) -> String {
        switch condition {
        case "mostlySunny": return "sunny"
        case "partlyCloudy": return "sunny"
        case "foggy": return "overcast"
        case "unknown": return "overcast"
        case "freezingRain": return "heavyRain"
        case "thunderstorm": return "heavyRain"
        case "hail": return "heavyRain"
        case "blizzard": return "snow"
        default: return condition
        }
    }

    private static let dayGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF70A8FF", "#FF80A8F8", "#FF9888F8"],
            ["#FF70B0FF", "#FF70B8F8", "#FF50B0F0"],
            ["#FF50B0F0", "#FF58B8D0", "#FF50B8A0"],
            ["#FF58B8D0", "#FF58C8A0", "#FFA0C828"],
            ["#FFA8C830", "#FFF0D830", "#FFF07818"],
            ["#FFF0D838", "#FFF08028", "#FFD83020"],
        ],
        "overcast": [
            ["#FF5454B8", "#FF727AC0", "#FF9A8AC8"],
            ["#FF6454B8", "#FF4C6CC0", "#FF6298D0"],
            ["#FF6858B8", "#FF5C8AC0", "#FF689A50"],
            ["#FF5C8AC0", "#FF689A50", "#FFD8C038"],
            ["#FF7454A2", "#FFD8C038", "#FFD87420"],
            ["#FF7454A2", "#FFD87420", "#FFE07090"],
        ],
        "drizzle": [
            ["#FF6888D0", "#FF6878C0", "#FF8878D8"],
            ["#FF6888D0", "#FF5888C8", "#FF60A8E0"],
            ["#FF6888D0", "#FF5090C0", "#FF48C0A8"],
            ["#FF6888D0", "#FF88A8A0", "#FFE0C020"],
            ["#FF6888D0", "#FF9888B0", "#FFF09030"],
            ["#FF6888D0", "#FFA880B8", "#FFE84880"],
        ],
        "rain": [
            ["#FF5878C4", "#FF5C70B8", "#FF8074D0"],
            ["#FF5878C4", "#FF5080C0", "#FF5CA0DC"],
            ["#FF5878C4", "#FF4C88B8", "#FF44B8A0"],
            ["#FF5878C4", "#FF789090", "#FFDCBC20"],
            ["#FF5878C4", "#FF8878A8", "#FFEC8830"],
            ["#FF5878C4", "#FF9870A8", "#FFE4487C"],
        ],
        "heavyRain": [
            ["#FF3C5CB0", "#FF445CA8", "#FF6C64C0"],
            ["#FF3C5CB0", "#FF3C6CB0", "#FF4C8CD0"],
            ["#FF3C5CB0", "#FF3C74A8", "#FF34A490"],
            ["#FF3C5CB0", "#FF607880", "#FFCCAC18"],
            ["#FF3C5CB0", "#FF706898", "#FFDC7428"],
            ["#FF3C5CB0", "#FF806090", "#FFD43C70"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FF98A8E0", "#FF9888E0"],
            ["#FFFAFAFA", "#FF98A8E0", "#FF90B0E8"],
            ["#FFFAFAFA", "#FF90B0E8", "#FF60C0E0"],
            ["#FFFAFAFA", "#FF60C0E0", "#FF68A8D0"],
            ["#FFFAFAFA", "#FF68A8D0", "#FF5898B0"],
            ["#FFFAFAFA", "#FF5898B0", "#FFD87420"],
        ],
    ]

    private static let nightGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF2E1065", "#FF381878", "#FF400898"],
            ["#FF2E1065", "#FF282878", "#FF1830A0"],
            ["#FF2E1065", "#FF1C4090", "#FF186090"],
            ["#FF2E1065", "#FF185870", "#FF086040"],
            ["#FF2E1065", "#FF602088", "#FF96006b"],
            ["#FF2E1065", "#FF781868", "#FF960819"],
        ],
        "overcast": [
            ["#FF0F0716", "#FF301470", "#FF400898"],
            ["#FF0F0716", "#FF222470", "#FF1830A0"],
            ["#FF0F0716", "#FF183888", "#FF186090"],
            ["#FF0F0716", "#FF144C68", "#FF086040"],
            ["#FF0F0716", "#FF4C1838", "#FFA85010"],
            ["#FF0F0716", "#FF581C80", "#FF960819"],
        ],
        "drizzle": [
            ["#FF050308", "#FF2C1870", "#FF400898"],
            ["#FF050308", "#FF1C2878", "#FF1830A0"],
            ["#FF050308", "#FF2C3890", "#FF186090"],
            ["#FF050308", "#FF2C4870", "#FF086040"],
            ["#FF050308", "#FF581880", "#FF96006b"],
            ["#FF050308", "#FF701060", "#FF960819"],
        ],
        "rain": [
            ["#FF050308", "#FF261468", "#FF400898"],
            ["#FF050308", "#FF182470", "#FF1830A0"],
            ["#FF050308", "#FF283488", "#FF186090"],
            ["#FF050308", "#FF284068", "#FF086040"],
            ["#FF050308", "#FF501478", "#FF96006b"],
            ["#FF050308", "#FF680C58", "#FF960819"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF201060", "#FF400898"],
            ["#FF050308", "#FF141E68", "#FF1830A0"],
            ["#FF050308", "#FF243080", "#FF186090"],
            ["#FF050308", "#FF243860", "#FF086040"],
            ["#FF050308", "#FF481070", "#FFB50060"],
            ["#FF050308", "#FF600850", "#FFB91C1C"],
        ],
        "snow": [
            ["#FF0F0716", "#FF2E1065", "#FF8070D8"],
            ["#FF0F0716", "#FF312E81", "#FF8070D8"],
            ["#FF0F0716", "#FF186090", "#FF60A8D0"],
            ["#FF0F0716", "#FF186880", "#FF60B8C0"],
            ["#FF0F0716", "#FF960819", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FF96006b"],
        ],
    ]
}
