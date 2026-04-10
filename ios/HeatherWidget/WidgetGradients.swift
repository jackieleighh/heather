import Foundation
import SwiftUI
import WidgetKit

struct WidgetGradients {

    static func gradientStops(from hexColors: [String], condition: String = "", isDay: Bool = true, family: WidgetFamily = .systemSmall) -> [Gradient.Stop] {
        let colors = hexColors.map { Color(hex: $0) }
        let count = colors.count
        guard count > 1 else {
            return [.init(color: colors.first ?? .clear, location: 0)]
        }

        // Slightly compress stops so the bottom color shows a bit more
        // than pure even distribution.
        let maxStop: Double = 0.82

        return colors.enumerated().map { index, color in
            let location = (Double(index) / Double(count - 1)) * maxStop
            return .init(color: color, location: location)
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
        case "partlyCloudy": return "sunny"
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
            ["#FF88CCFF", "#FF60B4FF", "#FF9E80FF"],
            ["#FF88CCFF", "#FF60B4FF", "#FF18CED2"],
            ["#FF88CCFF", "#FF18CED2", "#FF1CC8AA"],
            ["#FF18CED2", "#FF1CC8AA", "#FFF2CC00"],
            ["#FF18CED2", "#FFF2CC00", "#FFF87008"],
            ["#FF18CED2", "#FFF2CC00", "#FFF03478"],
        ],
        "overcast": [
            ["#FF5454B8", "#FF727AC0", "#FF9A8AC8"],
            ["#FF6454B8", "#FF4C6CC0", "#FF6298D0"],
            ["#FF6858B8", "#FF5C8AC0", "#FF689A50"],
            ["#FF5C8AC0", "#FF689A50", "#FFD8C038"],
            ["#FF7454A2", "#FFD8C038", "#FFD87420"],
            ["#FF7454A2", "#FFD87420", "#FFC84068"],
        ],
        "drizzle": [
            ["#FF5093CE", "#FF4C389F", "#FF7D8ED4"],
            ["#FF5093CE", "#FF3D5FA4", "#FF4C389F"],
            ["#FF5093CE", "#FF5093CE", "#FF49AB91"],
            ["#FF5093CE", "#FF49AB91", "#FFC19C33"],
            ["#FF5093CE", "#FFC19C33", "#FFC75F23"],
            ["#FF5093CE", "#FFC75F23", "#FFA63A62"],
        ],
        "rain": [
            ["#FF5093CE", "#FF4C389F", "#FF7D8ED4"],
            ["#FF5093CE", "#FF3D5FA4", "#FF4C389F"],
            ["#FF5093CE", "#FF5093CE", "#FF49AB91"],
            ["#FF5093CE", "#FF49AB91", "#FFC19C33"],
            ["#FF5093CE", "#FFC19C33", "#FFC75F23"],
            ["#FF5093CE", "#FFC75F23", "#FFA63A62"],
        ],
        "heavyRain": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD8B030"],
            ["#FF405888", "#FFD8B030", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "freezingRain": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD8B030"],
            ["#FF405888", "#FFD8B030", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FF7060D0", "#FF7890D0"],
            ["#FFFAFAFA", "#FF7890D0", "#FF68B8E8"],
            ["#FFFAFAFA", "#FF68B8E8", "#FF38A8D8"],
            ["#FFFAFAFA", "#FF38A8D8", "#FF4088B8"],
            ["#FFFAFAFA", "#FF4088B8", "#FF387898"],
            ["#FFFAFAFA", "#FF387898", "#FFD87420"],
        ],
        "blizzard": [
            ["#FFFAFAFA", "#FF7060D0", "#FF7890D0"],
            ["#FFFAFAFA", "#FF7890D0", "#FF68B8E8"],
            ["#FFFAFAFA", "#FF68B8E8", "#FF38A8D8"],
            ["#FFFAFAFA", "#FF38A8D8", "#FF4088B8"],
            ["#FFFAFAFA", "#FF4088B8", "#FF387898"],
            ["#FFFAFAFA", "#FF387898", "#FFD87420"],
        ],
        "thunderstorm": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD8B030"],
            ["#FF405888", "#FFD8B030", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
        "hail": [
            ["#FF405888", "#FF2563EB", "#FF5E78B0"],
            ["#FF405888", "#FF5E78B0", "#FF6880A8"],
            ["#FF405888", "#FF3878A8", "#FF387898"],
            ["#FF405888", "#FF387898", "#FFD8B030"],
            ["#FF405888", "#FFD8B030", "#FFB85010"],
            ["#FF405888", "#FFB85010", "#FFC84068"],
        ],
    ]

    // MARK: - Night Gradients

    private static let nightGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF1E1B4B", "#FF2E1065", "#FF400898"],
            ["#FF1E1B4B", "#FF2E1065", "#FF1830A0"],
            ["#FF1E1B4B", "#FF2E1065", "#FF186090"],
            ["#FF1E1B4B", "#FF2E1065", "#FF086040"],
            ["#FF1E1B4B", "#FF2E1065", "#FF96006b"],
            ["#FF1E1B4B", "#FF2E1065", "#FF960819"],
        ],
        "overcast": [
            ["#FF0F0716", "#FF2E1065", "#FF400898"],
            ["#FF0F0716", "#FF2E1065", "#FF1830A0"],
            ["#FF0F0716", "#FF2E1065", "#FF186090"],
            ["#FF0F0716", "#FF2E1065", "#FF086040"],
            ["#FF0F0716", "#FF2E1065", "#FF960819"],
            ["#FF0F0716", "#FF2E1065", "#FF96006b"],
        ],
        "drizzle": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FF960819"],
            ["#FF050308", "#FF2E1065", "#FF96006b"],
        ],
        "rain": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FF960819"],
            ["#FF050308", "#FF2E1065", "#FF96006b"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
        ],
        "snow": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FF8070D8"],
            ["#FF0F0716", "#FF186090", "#FF60A8D0"],
            ["#FF0F0716", "#FF186880", "#FF60B8C0"],
            ["#FF0F0716", "#FF960819", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FF96006b"],
        ],
        "blizzard": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FF8070D8"],
            ["#FF0F0716", "#FF186090", "#FF60A8D0"],
            ["#FF0F0716", "#FF186880", "#FF60B8C0"],
            ["#FF0F0716", "#FF960819", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FF96006b"],
        ],
        "thunderstorm": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
        ],
        "hail": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
        ],
    ]
}

// MARK: - Gradient Background

/// Radial gradient with the first color at the upper-right and the last color
/// arcing up the left side, matching the Flutter app's visual feel.
struct WidgetGradientBackground: View {
    let hexColors: [String]
    let condition: String
    let isDay: Bool
    var family: WidgetFamily = .systemSmall

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            let centerY: Double = 0.15

            RadialGradient(
                stops: WidgetGradients.gradientStops(
                    from: hexColors, condition: condition, isDay: isDay, family: family
                ),
                center: UnitPoint(x: 0.75, y: centerY),
                startRadius: 0,
                endRadius: sqrt(w * w + h * h)
            )
        }
    }
}
