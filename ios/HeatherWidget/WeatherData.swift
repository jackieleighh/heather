import Foundation

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
    let quip: String
    let persona: String
    let cityName: String
    let lastUpdated: String
    let gradientColors: [String]

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
        quip: "It's giving main character energy out there.",
        persona: "heather",
        cityName: "Los Angeles",
        lastUpdated: ISO8601DateFormatter().string(from: Date()),
        gradientColors: ["#FF5B86E5", "#FF36D1DC"]
    )

    static func load() -> WeatherData? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.totms.heather"),
              let jsonString = userDefaults.string(forKey: "widget_data"),
              let data = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(WeatherData.self, from: data)
    }
}
