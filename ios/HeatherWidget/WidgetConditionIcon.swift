import SwiftUI

struct WidgetConditionIcon: View {
    let conditionName: String
    let isDay: Bool
    let size: CGFloat

    var body: some View {
        Image(systemName: sfSymbolName)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.white.opacity(0.9))
            .font(.system(size: size, weight: .medium))
    }

    private var sfSymbolName: String {
        switch conditionName {
        case "sunny":
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case "mostlySunny", "partlyCloudy":
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case "overcast":
            return "cloud.fill"
        case "foggy":
            return isDay ? "sun.haze.fill" : "cloud.fog.fill"
        case "drizzle":
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case "rain", "heavyRain":
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case "freezingRain":
            return isDay ? "cloud.sleet.fill" : "cloud.sleet.fill"
        case "snow":
            return isDay ? "cloud.snow.fill" : "cloud.snow.fill"
        case "blizzard":
            return "wind.snow"
        case "thunderstorm":
            return isDay ? "cloud.sun.bolt.fill" : "cloud.bolt.rain.fill"
        case "hail":
            return "cloud.hail.fill"
        default:
            return "cloud.fill"
        }
    }
}

/// Returns the SF Symbol name for a precipitation label string.
///
/// When the label contains a transition arrow (→), only the current
/// condition (before the arrow) is used for icon selection.
func precipIcon(_ label: String) -> String {
    let text = if let arrowRange = label.range(of: "→") {
        String(label[label.startIndex..<arrowRange.lowerBound])
    } else {
        label
    }
    let lower = text.lowercased()
    if lower.contains("snow") || lower.contains("flurries") {
        return "snowflake"
    } else if lower.contains("slush") {
        return "cloud.sleet"
    } else if lower.contains("drizzle") || lower.contains("slight rain") {
        return "drop.fill"
    } else {
        return "drop.fill"
    }
}
