import Foundation

struct HourlyEntry: Codable {
    let time: String
    let temperature: Int
    let weatherCode: Int

    var conditionName: String {
        WeatherFetcher.conditionName(from: weatherCode)
    }

    var hourLabel: String {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm",
        ]
        var parsed: Date?
        for format in formats {
            let fmt = DateFormatter()
            fmt.dateFormat = format
            fmt.locale = Locale(identifier: "en_US_POSIX")
            if let d = fmt.date(from: time) {
                parsed = d
                break
            }
        }
        if parsed == nil {
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            parsed = iso.date(from: time)
        }
        guard let date = parsed else { return "" }
        let hFmt = DateFormatter()
        hFmt.dateFormat = "ha"
        return hFmt.string(from: date).lowercased()
    }
}

struct WeatherData: Codable {
    let temperature: Int
    let feelsLike: Int
    let high: Int
    let low: Int
    let conditionName: String
    let description: String
    let isDay: Bool
    let humidity: Int
    let windSpeed: Int
    let uvIndex: Int
    let quip: String
    let persona: String
    let cityName: String
    let latitude: Double?
    let longitude: Double?
    let lastUpdated: String
    let gradientColors: [String]
    let hourly: [HourlyEntry]?
    let sunrise: String?
    let sunset: String?
    let uvIndexMax: Int?

    static let placeholder = WeatherData(
        temperature: 72,
        feelsLike: 70,
        high: 78,
        low: 62,
        conditionName: "sunny",
        description: "Clear sky",
        isDay: true,
        humidity: 45,
        windSpeed: 8,
        uvIndex: 3,
        quip: "It's giving main character energy out there.",
        persona: "heather",
        cityName: "Los Angeles",
        latitude: nil,
        longitude: nil,
        lastUpdated: ISO8601DateFormatter().string(from: Date()),
        gradientColors: ["#FF5B86E5", "#FF36D1DC"],
        hourly: nil,
        sunrise: nil,
        sunset: nil,
        uvIndexMax: nil
    )

    var sunriseLabel: String? {
        guard let sunrise else { return nil }
        return Self.formatTimeLabel(sunrise)
    }

    var sunsetLabel: String? {
        guard let sunset else { return nil }
        return Self.formatTimeLabel(sunset)
    }

    private static func formatTimeLabel(_ isoString: String) -> String? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm",
            "yyyy-MM-dd'T'HH:mm:ss",
        ]
        var parsed: Date?
        for format in formats {
            let fmt = DateFormatter()
            fmt.dateFormat = format
            fmt.locale = Locale(identifier: "en_US_POSIX")
            if let d = fmt.date(from: isoString) {
                parsed = d
                break
            }
        }
        guard let date = parsed else { return nil }
        let display = DateFormatter()
        display.dateFormat = "h:mm a"
        return display.string(from: date)
    }

    static func load() -> WeatherData? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.totms.heather"),
              let jsonString = userDefaults.string(forKey: "widget_data"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }

    static func save(_ data: WeatherData) {
        guard let userDefaults = UserDefaults(suiteName: "group.com.totms.heather"),
              let json = try? JSONEncoder().encode(data),
              let jsonString = String(data: json, encoding: .utf8) else {
            return
        }
        userDefaults.set(jsonString, forKey: "widget_data")
    }
}
