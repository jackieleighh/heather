import Foundation

struct WidgetGradients {

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
            ["#FFA8B8E8", "#FFDCD2FF", "#FF4D82F5"],
            ["#FFB5E0F5", "#FF80CBE9", "#FF6AADD8"],
            ["#FF72BCF0", "#FF35BFC5", "#FF18ACAF"],
            ["#FF72BCF0", "#FFA8CC38", "#FFFDD45A"],
            ["#FF72BCF0", "#FFA8CC38", "#FFEBB020", "#FFFF9D0A"],
            ["#FF72BCF0", "#FFA8CC38", "#FFEBB020", "#FFFF9D0A", "#FFE05A9C"],
        ],
        "overcast": [
            ["#FF94A3B8", "#FF8B9DD4", "#FF7888BE"],
            ["#FF94A3B8", "#FF7C8FCC", "#FF92A2BE"],
            ["#FF94A3B8", "#FF92A2BE", "#FF5C94AE"],
            ["#FF92A2BE", "#FF92B882", "#FFC4AD58"],
            ["#FF92B882", "#FFC4AD58", "#FFDC9450"],
            ["#FFC4AD58", "#FFDC9450", "#FFC47090"],
        ],
        "drizzle": [
            ["#FF7C8FCC", "#FF8B9DD4", "#FF7888BE"],
            ["#FF7C8FCC", "#FF8B9DD4", "#FF92A2BE"],
            ["#FF7888BE", "#FF5C94AE", "#FF4A8EC2"],
            ["#FF7888BE", "#FF6E8A5E", "#FF9C8535"],
            ["#FF7888BE", "#FF9C8535", "#FFDC9450"],
            ["#FF7888BE", "#FFDC9450", "#FFC47090"],
        ],
        "rain": [
            ["#FF7C8FCC", "#FF8B9DD4", "#FF7888BE"],
            ["#FF7C8FCC", "#FF8B9DD4", "#FF92A2BE"],
            ["#FF7888BE", "#FF5C94AE", "#FF4A8EC2"],
            ["#FF7888BE", "#FF6E8A5E", "#FF9C8535"],
            ["#FF7888BE", "#FF9C8535", "#FFDC9450"],
            ["#FF7888BE", "#FFDC9450", "#FFC47090"],
        ],
        "heavyRain": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF92A2BE"],
            ["#FF405888", "#FF4A8EC2", "#FF5C94AE"],
            ["#FF405888", "#FF5C94AE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "freezingRain": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF92A2BE"],
            ["#FF405888", "#FF4A8EC2", "#FF5C94AE"],
            ["#FF405888", "#FF5C94AE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FFC4B5FD", "#FFA8B8E8"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF6AADD8"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FF80CBE9", "#FF6AADD8"],
        ],
        "blizzard": [
            ["#FFFAFAFA", "#FFC4B5FD", "#FFA8B8E8"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF6AADD8"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FFA8B8E8", "#FF80CBE9"],
            ["#FFFAFAFA", "#FF80CBE9", "#FF6AADD8"],
        ],
        "thunderstorm": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF92A2BE"],
            ["#FF405888", "#FF4A8EC2", "#FF5C94AE"],
            ["#FF405888", "#FF5C94AE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "hail": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF92A2BE"],
            ["#FF405888", "#FF4A8EC2", "#FF5C94AE"],
            ["#FF405888", "#FF5C94AE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
    ]

    // MARK: - Night Gradients

    private static let nightGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF1E1B4B", "#FF2E1065", "#FF4C1D95"],
            ["#FF1E1B4B", "#FF2E1065", "#FF1A3A8C"],
            ["#FF1E1B4B", "#FF2E1065", "#FF134A66"],
            ["#FF1E1B4B", "#FF2E1065", "#FF0E4A3A"],
            ["#FF1E1B4B", "#FF2E1065", "#FF831843"],
            ["#FF1E1B4B", "#FF2E1065", "#FFB91C1C"],
        ],
        "overcast": [
            ["#FF0F0716", "#FF1E1B4B", "#FF1A2744"],
            ["#FF0F0716", "#FF1E1B4B", "#FF475569"],
            ["#FF0F0716", "#FF1E1B4B", "#FF312E81"],
            ["#FF0F0716", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF0F0716", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],
        ],
        "drizzle": [
            ["#FF050308", "#FF1E1B4B", "#FF1A2744"],
            ["#FF050308", "#FF1E1B4B", "#FF475569"],
            ["#FF050308", "#FF1E1B4B", "#FF312E81"],
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF050308", "#FF2E1065", "#FF831843"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
        ],
        "rain": [
            ["#FF050308", "#FF1E1B4B", "#FF1A2744"],
            ["#FF050308", "#FF1E1B4B", "#FF475569"],
            ["#FF050308", "#FF1E1B4B", "#FF312E81"],
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF050308", "#FF2E1065", "#FF831843"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0A0F1E", "#FFF97316"],
            ["#FF050308", "#FF0A0F1E", "#FFB50060"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0A0F1E", "#FFF97316"],
            ["#FF050308", "#FF0A0F1E", "#FFB50060"],
        ],
        "snow": [
            ["#FF0F0716", "#FF1E1B4B", "#FFEDE9FE"],
            ["#FF0F0716", "#FF1E1B4B", "#FFDCD2FF"],
            ["#FF0F0716", "#FF1E1B4B", "#FFB5E0F5"],
            ["#FF0F0716", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],
        ],
        "blizzard": [
            ["#FF0F0716", "#FF1E1B4B", "#FFEDE9FE"],
            ["#FF0F0716", "#FF1E1B4B", "#FFDCD2FF"],
            ["#FF0F0716", "#FF1E1B4B", "#FFB5E0F5"],
            ["#FF0F0716", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],
        ],
        "thunderstorm": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0A0F1E", "#FFF97316"],
            ["#FF050308", "#FF0A0F1E", "#FFB50060"],
        ],
        "hail": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0A0F1E", "#FFF97316"],
            ["#FF050308", "#FF0A0F1E", "#FFB50060"],
        ],
    ]
}
