import Foundation
import SwiftUI

struct HourlyEntry: Codable {
    let time: String
    let epoch: Int?
    let temperature: Int
    let weatherCode: Int
    let isDay: Bool?

    var conditionName: String {
        WeatherFetcher.conditionName(from: weatherCode)
    }

    /// Absolute Date from epoch (timezone-independent). Falls back to string parsing.
    func absoluteDate(locationTZ: TimeZone) -> Date {
        if let epoch {
            return Date(timeIntervalSince1970: TimeInterval(epoch))
        }
        // Fallback: parse the ISO string using the location timezone
        return Self.parseTime(time, timeZone: locationTZ) ?? .distantPast
    }

    /// Hour label extracted directly from the ISO time string (no DateFormatter).
    /// The ISO string contains the location's local time, so we just read the hour.
    var hourLabel: String {
        // "2026-03-03T15:00:00.000" → extract hour = 15
        guard let tIndex = time.firstIndex(of: "T"),
              time.index(after: tIndex) < time.endIndex else { return "" }
        let afterT = time[time.index(after: tIndex)...]
        guard let colonIndex = afterT.firstIndex(of: ":") else { return "" }
        let hourStr = String(afterT[afterT.startIndex..<colonIndex])
        guard let hour = Int(hourStr) else { return "" }
        let displayHour = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "am" : "pm"
        return "\(displayHour)\(ampm)"
    }

    /// Parse a time string with a specific timezone.
    static func parseTime(_ str: String, timeZone tz: TimeZone) -> Date? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm",
        ]
        for format in formats {
            let fmt = DateFormatter()
            fmt.dateFormat = format
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = tz
            if let d = fmt.date(from: str) { return d }
        }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: str)
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
    let utcOffsetSeconds: Int?
    let sunriseEpoch: Int?
    let sunsetEpoch: Int?
    let precipLabel: String?
    let alertLabel: String?
    let alertSeverity: String?

    /// Alert color based on severity: extreme=red, severe=orange, default=yellow.
    var alertColor: Color {
        switch alertSeverity?.lowercased() {
        case "extreme": return Color(red: 0xEF/255.0, green: 0x44/255.0, blue: 0x44/255.0)
        case "severe": return Color(red: 0xF9/255.0, green: 0x73/255.0, blue: 0x16/255.0)
        default: return .yellow
        }
    }

    /// Alert icon based on severity: extreme=circle exclamation, severe/default=triangle.
    var alertIcon: String {
        switch alertSeverity?.lowercased() {
        case "extreme": return "exclamationmark.circle.fill"
        default: return "exclamationmark.triangle.fill"
        }
    }

    /// TimeZone derived from the API's utcOffsetSeconds for the weather location.
    var locationTimeZone: TimeZone {
        TimeZone(secondsFromGMT: utcOffsetSeconds ?? TimeZone.current.secondsFromGMT()) ?? .current
    }

    /// Sunrise as absolute Date (prefers epoch, falls back to string parsing).
    var sunriseDate: Date? {
        if let sunriseEpoch { return Date(timeIntervalSince1970: TimeInterval(sunriseEpoch)) }
        guard let sunrise else { return nil }
        return HourlyEntry.parseTime(sunrise, timeZone: locationTimeZone)
    }

    /// Sunset as absolute Date (prefers epoch, falls back to string parsing).
    var sunsetDate: Date? {
        if let sunsetEpoch { return Date(timeIntervalSince1970: TimeInterval(sunsetEpoch)) }
        guard let sunset else { return nil }
        return HourlyEntry.parseTime(sunset, timeZone: locationTimeZone)
    }

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
        uvIndexMax: nil,
        utcOffsetSeconds: nil,
        sunriseEpoch: nil,
        sunsetEpoch: nil,
        precipLabel: nil,
        alertLabel: nil,
        alertSeverity: nil
    )

    var sunriseLabel: String? {
        guard let sunrise else { return nil }
        return Self.formatTimeLabel(sunrise, timeZone: locationTimeZone)
    }

    var sunsetLabel: String? {
        guard let sunset else { return nil }
        return Self.formatTimeLabel(sunset, timeZone: locationTimeZone)
    }

    private static func formatTimeLabel(_ isoString: String, timeZone tz: TimeZone) -> String? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
        ]
        var parsed: Date?
        for format in formats {
            let fmt = DateFormatter()
            fmt.dateFormat = format
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = tz
            if let d = fmt.date(from: isoString) {
                parsed = d
                break
            }
        }
        guard let date = parsed else { return nil }
        let display = DateFormatter()
        display.dateFormat = "h:mm a"
        display.timeZone = tz
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
