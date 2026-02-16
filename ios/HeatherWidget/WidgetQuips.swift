import Foundation

struct WidgetQuips {
    /// Picks a random quip from the quip map stored in shared UserDefaults.
    /// Returns nil if no quip data is available.
    static func pickQuip(condition: String, tempF: Double) -> String? {
        guard let userDefaults = UserDefaults(suiteName: "group.com.totms.heather"),
              let jsonString = userDefaults.string(forKey: "widget_quips"),
              let data = jsonString.data(using: .utf8),
              let map = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String]]] else {
            return nil
        }

        let tier = temperatureTier(from: tempF)

        guard let tiers = map[condition] else { return nil }

        // Try exact tier, then fallback tiers
        let quips = tiers[tier]
            ?? tiers["flannelWeather"]
            ?? tiers["shortsWeather"]
            ?? tiers.values.first

        guard let quips, !quips.isEmpty else { return nil }
        return quips.randomElement()
    }

    private static func temperatureTier(from tempF: Double) -> String {
        if tempF < 15 { return "singleDigits" }
        if tempF < 32 { return "freezing" }
        if tempF < 50 { return "jacketWeather" }
        if tempF < 70 { return "flannelWeather" }
        if tempF < 90 { return "shortsWeather" }
        return "scorcher"
    }
}
