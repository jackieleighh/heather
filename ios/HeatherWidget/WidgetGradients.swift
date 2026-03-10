import Foundation
import SwiftUI

struct WidgetGradients {

    static func gradientStops(from hexColors: [String], condition: String = "", isDay: Bool = true) -> [Gradient.Stop] {
        let colors = hexColors.map { Color(hex: $0) }
        if !isDay {
            // Even distribution for night
            return colors.enumerated().map { .init(color: $1, location: Double($0) / Double(max(colors.count - 1, 1))) }
        }
        // All daytime conditions get weighted stops
        switch colors.count {
        case 1:
            return [.init(color: colors[0], location: 0)]
        case 2:
            return [.init(color: colors[0], location: 0), .init(color: colors[1], location: 1)]
        case 3:
            return zip(colors, [0.0, 0.6, 1.0]).map { .init(color: $0, location: $1) }
        case 4:
            return zip(colors, [0.0, 0.45, 0.78, 1.0]).map { .init(color: $0, location: $1) }
        case 5:
            return zip(colors, [0.0, 0.25, 0.50, 0.75, 1.0]).map { .init(color: $0, location: $1) }
        default:
            return colors.enumerated().map { .init(color: $1, location: Double($0) / Double(colors.count - 1)) }
        }
    }

    static func colors(for condition: String, tempF: Double, isDay: Bool) -> [String] {
        let tier = tierIndex(from: tempF)
        let resolved = resolveCondition(condition)
        if isDay {
            return dayGradients[resolved]?[tier] ?? dayGradients["overcast"]![tier]
        }
        return nightGradients[resolved]?[tier] ?? nightGradients["overcast"]![tier]
    }

    /// Parses a hex color string to SwiftUI-compatible components.
    static func parseRGB(_ hex: String) -> (r: Double, g: Double, b: Double) {
        let clean = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        if clean.count == 8 { // AARRGGBB
            return (Double((value >> 16) & 0xFF) / 255.0,
                    Double((value >> 8) & 0xFF) / 255.0,
                    Double(value & 0xFF) / 255.0)
        }
        return (Double((value >> 16) & 0xFF) / 255.0,
                Double((value >> 8) & 0xFF) / 255.0,
                Double(value & 0xFF) / 255.0)
    }

    // MARK: - Temperature Tiers

    /// 0=singleDigits, 1=freezing, 2=jacket, 3=flannel, 4=shorts, 5=scorcher
    private static func tierIndex(from tempF: Double) -> Int {
        if tempF < 15 { return 0 }
        if tempF < 32 { return 1 }
        if tempF < 50 { return 2 }
        if tempF < 70 { return 3 }
        if tempF < 90 { return 4 }
        return 5
    }

    // MARK: - Condition Aliases

    private static func resolveCondition(_ condition: String) -> String {
        switch condition {
        case "mostlySunny": return "sunny"
        case "foggy": return "overcast"
        case "unknown": return "overcast"
        default: return condition
        }
    }

    // MARK: - Day Gradients
    // Each entry: [[tier0], [tier1], [tier2], [tier3], [tier4], [tier5]]
    // Colors match BackgroundGradients in background_gradients.dart

    private static let dayGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF7858E0", "#FF8870D8", "#FFB498E8"],
            ["#FF7C68D0", "#FF5898D8", "#FF68C0E0"],
            ["#FF60A0C8", "#FF50B8D0", "#FF68C898"],
            ["#FF5898D8", "#FF68D0B0", "#FFD8C038"],
            ["#FF50B8D0", "#FFD8B038", "#FFE07018"],
            ["#FFE8D058", "#FFE07018", "#FFC84068"],
        ],
        "partlyCloudy": [
            ["#FF7060D0", "#FF6878C8", "#FF7C68D0"],
            ["#FF7C68D0", "#FF6878C8", "#FF60A0C8"],
            ["#FF60A0C8", "#FF50B8D0", "#FF68B8E8"],
            ["#FF50B8D0", "#FF60C8A8", "#FF80E0A0"],
            ["#FF60C8A8", "#FFE8D058", "#FFE07018"],
            ["#FFE8D058", "#FFE07018", "#FFC84068"],
        ],
        "overcast": [
            ["#FF6060C8", "#FF8088D0", "#FFA898D8"],
            ["#FF7060C8", "#FF5878D0", "#FF70A8E0"],
            ["#FF7464C7", "#FF6898D0", "#FF88B898"],
            ["#FF6898D0", "#FF88B898", "#FFD8C038"],
            ["#FF8060B0", "#FFD8C038", "#FFE07018"],
            ["#FFC07018", "#FFE07018", "#FFC84068"],
        ],
        "drizzle": [
            ["#FF7060D8", "#FF4C98D8", "#FF6888E0"],
            ["#FF6888E0", "#FF4C98D8", "#FF7060D8"],
            ["#FF6888E0", "#FF4C98D8", "#FF60B898"],
            ["#FF6888E0", "#FF60B898", "#FFD8B030"],
            ["#FF6888E0", "#FFD8B030", "#FFE07018"],
            ["#FF6888E0", "#FFE87820", "#FFC84068"],
        ],
        "rain": [
            ["#FF7060D8", "#FF4C98D8", "#FF6888E0"],
            ["#FF6888E0", "#FF4C98D8", "#FF7060D8"],
            ["#FF6888E0", "#FF4C98D8", "#FF60B898"],
            ["#FF6888E0", "#FF60B898", "#FFD8B030"],
            ["#FF6888E0", "#FFD8B030", "#FFE07018"],
            ["#FF6888E0", "#FFE87820", "#FFC84068"],
        ],
        "heavyRain": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "freezingRain": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FF7060D0", "#FF7890D0"],
            ["#FFFAFAFA", "#FF7890D0", "#FF68B8E8"],
            ["#FFFAFAFA", "#FF68B8E8", "#FF38A8D8"],
            ["#FFFAFAFA", "#FF38A8D8", "#FF4088B8"],
            ["#FFFAFAFA", "#FF4088B8", "#FF387898"],
            ["#FFFAFAFA", "#FF387898", "#FFE07018"],
        ],
        "blizzard": [
            ["#FFFAFAFA", "#FF7060D0", "#FF7890D0"],
            ["#FFFAFAFA", "#FF7890D0", "#FF68B8E8"],
            ["#FFFAFAFA", "#FF68B8E8", "#FF38A8D8"],
            ["#FFFAFAFA", "#FF38A8D8", "#FF4088B8"],
            ["#FFFAFAFA", "#FF4088B8", "#FF387898"],
            ["#FFFAFAFA", "#FF387898", "#FFE07018"],
        ],
        "thunderstorm": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "hail": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
    ]

    // MARK: - Night Gradients

    private static let nightGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF1E1B4B", "#FF2E1065", "#FF4C1D95"],
            ["#FF1E1B4B", "#FF2E1065", "#FF2850B0"],
            ["#FF1E1B4B", "#FF2E1065", "#FF1E6890"],
            ["#FF1E1B4B", "#FF2E1065", "#FF187858"],
            ["#FF1E1B4B", "#FF2E1065", "#FFA83848"],
            ["#FF1E1B4B", "#FF2E1065", "#FFA82058"],
        ],
        "partlyCloudy": [
            ["#FF1E1B4B", "#FF2E1065", "#FF4C1D95"],
            ["#FF1E1B4B", "#FF2E1065", "#FF2850B0"],
            ["#FF1E1B4B", "#FF2E1065", "#FF1E6890"],
            ["#FF1E1B4B", "#FF2E1065", "#FF187858"],
            ["#FF1E1B4B", "#FF2E1065", "#FFA83848"],
            ["#FF1E1B4B", "#FF2E1065", "#FFA82058"],
        ],
        "overcast": [
            ["#FF0F0716", "#FF2E1065", "#FF4C1D95"],
            ["#FF0F0716", "#FF2E1065", "#FF2850B0"],
            ["#FF0F0716", "#FF2E1065", "#FF1E6890"],
            ["#FF0F0716", "#FF2E1065", "#FF187858"],
            ["#FF0F0716", "#FF2E1065", "#FFA83848"],
            ["#FF0F0716", "#FF2E1065", "#FFA82058"],
        ],
        "drizzle": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFA83848"],
            ["#FF050308", "#FF2E1065", "#FFA82058"],
        ],
        "rain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFA83848"],
            ["#FF050308", "#FF2E1065", "#FFA82058"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "snow": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FF8070D8"],
            ["#FF0F0716", "#FF1E6890", "#FF60A8D0"],
            ["#FF0F0716", "#FF186880", "#FF60B8C0"],
            ["#FF0F0716", "#FFA82058", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FFE05A9C"],
        ],
        "blizzard": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FF8070D8"],
            ["#FF0F0716", "#FF1E6890", "#FF60A8D0"],
            ["#FF0F0716", "#FF186880", "#FF60B8C0"],
            ["#FF0F0716", "#FFA82058", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FFE05A9C"],
        ],
        "thunderstorm": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "hail": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF2850B0"],
            ["#FF050308", "#FF2E1065", "#FF1E6890"],
            ["#FF050308", "#FF2E1065", "#FF187858"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
    ]
}

// MARK: - Organic Gradient Background

/// Replaces a straight `LinearGradient` with layered radial gradients that
/// curve around the corners, eliminating the "stripey" look on small widgets.
struct WidgetGradientBackground: View {
    let hexColors: [String]
    let condition: String
    let isDay: Bool

    var body: some View {
        if !isDay || hexColors.count < 3 {
            // Night or fewer colors: even linear is fine
            LinearGradient(
                stops: WidgetGradients.gradientStops(
                    from: hexColors, condition: condition, isDay: isDay
                ),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        } else {
            dayGradient
        }
    }

    private var dayGradient: some View {
        let colors = hexColors.map { Color(hex: $0) }
        return GeometryReader { geo in
            let d = sqrt(pow(geo.size.width, 2) + pow(geo.size.height, 2))
            ZStack {
                // Green base (dominant middle color like the app)
                colors[1]

                // Blue from top-right — strong presence, smooth melt into green
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: colors[0].opacity(0.85), location: 0),
                        .init(color: colors[0].opacity(0.65), location: 0.2),
                        .init(color: colors[0].opacity(0.35), location: 0.45),
                        .init(color: colors[0].opacity(0), location: 0.7),
                    ]),
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: d * 1.1
                )

                // Gold from bottom-left — warm accent, smooth melt into green
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: colors[2].opacity(0.75), location: 0),
                        .init(color: colors[2].opacity(0.55), location: 0.15),
                        .init(color: colors[2].opacity(0.30), location: 0.35),
                        .init(color: colors[2].opacity(0), location: 0.55),
                    ]),
                    center: .bottomLeading,
                    startRadius: 0,
                    endRadius: d * 1.0
                )
            }
        }
    }
}
