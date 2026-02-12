import SwiftUI

struct WidgetConditionIcon: View {
    let conditionName: String
    let isDay: Bool
    let size: CGFloat

    var body: some View {
        Image(systemName: sfSymbolName)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.white.opacity(0.7))
            .font(.system(size: size, weight: .light))
    }

    private var sfSymbolName: String {
        switch conditionName {
        case "sunny":
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case "mostlySunny":
            return isDay ? "sun.min.fill" : "moon.fill"
        case "partlyCloudy":
            return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case "overcast":
            return "cloud.fill"
        case "foggy":
            return "cloud.fog.fill"
        case "drizzle":
            return isDay ? "cloud.sun.rain.fill" : "cloud.moon.rain.fill"
        case "rain":
            return "cloud.rain.fill"
        case "heavyRain":
            return "cloud.heavyrain.fill"
        case "freezingRain":
            return "cloud.sleet.fill"
        case "snow":
            return "cloud.snow.fill"
        case "blizzard":
            return "wind.snow"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "hail":
            return "cloud.hail.fill"
        default:
            return "cloud.fill"
        }
    }
}
