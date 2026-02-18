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

    private static let dayGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF8B9DD4", "#FFC4B5FD", "#FF2563EB"],
            ["#FF8B9DD4", "#FF7C8FCC", "#FF38BDF8"],
            ["#FF4A9BD9", "#FF38BDF8", "#FF018F91"],
            ["#FF4A9BD9", "#FF5BA847", "#FFD4960A"],
            ["#FF5BA847", "#FFD4960A", "#FFFF8C00"],
            ["#FFFBBF24", "#FFFF8C00", "#FFF472B6"],
        ],
        "partlyCloudy": [
            ["#FFE2E8F0", "#FF94A3B8", "#FF38BDF8"],
            ["#FF94A3B8", "#FF475569", "#FF96D9DB"],
            ["#FF475569", "#FF96D9DB", "#FF2563EB"],
            ["#FF94A3B8", "#FF38BDF8", "#FFA3E635"],
            ["#FF94A3B8", "#FFA3E635", "#FFFFD700"],
            ["#FF475569", "#FFF97316", "#FFFBBF24"],
        ],
        "overcast": [
            ["#FF94A3B8", "#FF8B9DD4", "#FF312E81"],
            ["#FF94A3B8", "#FF7C8FCC", "#FF475569"],
            ["#FF475569", "#FF94A3B8", "#FF0C4A5E"],
            ["#FF475569", "#FF6E8A5E", "#FF9C8535"],
            ["#FF6E8A5E", "#FF9C8535", "#FFC2410C"],
            ["#FF9C8535", "#FFC2410C", "#FF831843"],
        ],
        "drizzle": [
            ["#FF7C8FCC", "#FF8B9DD4", "#FF312E81"],
            ["#FF7C8FCC", "#FF94A3B8", "#FF475569"],
            ["#FF4A9BD9", "#FF475569", "#FF0C4A5E"],
            ["#FF4A9BD9", "#FF6E8A5E", "#FF9C8535"],
            ["#FF4A9BD9", "#FF9C8535", "#FFC2410C"],
            ["#FF4A9BD9", "#FFC2410C", "#FF831843"],
        ],
        "rain": [
            ["#FF7C8FCC", "#FF8B9DD4", "#FF312E81"],
            ["#FF7C8FCC", "#FF94A3B8", "#FF475569"],
            ["#FF4A9BD9", "#FF475569", "#FF0C4A5E"],
            ["#FF4A9BD9", "#FF6E8A5E", "#FF9C8535"],
            ["#FF4A9BD9", "#FF9C8535", "#FFC2410C"],
            ["#FF4A9BD9", "#FFC2410C", "#FF831843"],
        ],
        "heavyRain": [
            ["#FF312E81", "#FF2563EB", "#FF475569"],
            ["#FF312E81", "#FF475569", "#FF7C8FCC"],
            ["#FF312E81", "#FF475569", "#FF0C4A5E"],
            ["#FF312E81", "#FF6E8A5E", "#FF9C8535"],
            ["#FF312E81", "#FF9C8535", "#FFC2410C"],
            ["#FF312E81", "#FFC2410C", "#FF831843"],
        ],
        "freezingRain": [
            ["#FF312E81", "#FF2563EB", "#FF475569"],
            ["#FF312E81", "#FF475569", "#FF7C8FCC"],
            ["#FF312E81", "#FF475569", "#FF0C4A5E"],
            ["#FF312E81", "#FF6E8A5E", "#FF9C8535"],
            ["#FF312E81", "#FF9C8535", "#FFC2410C"],
            ["#FF312E81", "#FFC2410C", "#FF831843"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FFC4B5FD", "#FF7C8FCC"],
            ["#FFFAFAFA", "#FF94A3B8", "#FF7C8FCC"],
            ["#FFFAFAFA", "#FFE2E8F0", "#FF7C8FCC"],
            ["#FFFAFAFA", "#FF8B9DD4", "#FF7C8FCC"],
            ["#FFFAFAFA", "#FF94A3B8", "#FF7C8FCC"],
            ["#FFFAFAFA", "#FF7C8FCC", "#FF475569"],
        ],
        "blizzard": [
            ["#FFE2E8F0", "#FFC4B5FD", "#FF7C8FCC"],
            ["#FFE2E8F0", "#FF94A3B8", "#FF7C8FCC"],
            ["#FFE2E8F0", "#FF94A3B8", "#FF7C8FCC"],
            ["#FFE2E8F0", "#FF8B9DD4", "#FF7C8FCC"],
            ["#FFE2E8F0", "#FF7C8FCC", "#FF475569"],
            ["#FFE2E8F0", "#FF8B9DD4", "#FF475569"],
        ],
        "thunderstorm": [
            ["#FF1E1B4B", "#FF6366F1", "#FF8B5CF6"],
            ["#FF0F0716", "#FF2563EB", "#FFA3E635"],
            ["#FF050308", "#FF2E1065", "#FF6366F1"],
            ["#FF050308", "#FF1E1B4B", "#FF8B5CF6"],
            ["#FF050308", "#FF2E1065", "#FF2563EB"],
            ["#FF050308", "#FF831843", "#FF8B5CF6"],
        ],
        "hail": [
            ["#FF94A3B8", "#FF475569", "#FF0C4A5E"],
            ["#FF475569", "#FF0C4A5E", "#FFE2E8F0"],
            ["#FF0F0716", "#FF0C4A5E", "#FF94A3B8"],
            ["#FF1E1B4B", "#FF2E1065", "#FF0C4A5E"],
            ["#FF050308", "#FF0C4A5E", "#FFA3E635"],
            ["#FF050308", "#FF831843", "#FF0C4A5E"],
        ],
    ]

    // MARK: - Night Gradients

    private static let nightGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF1E1B4B", "#FF2E1065", "#FF2563EB"],
            ["#FF1E1B4B", "#FF2E1065", "#FF1A2744"],
            ["#FF1E1B4B", "#FF2E1065", "#FF312E81"],
            ["#FF1E1B4B", "#FF2E1065", "#FF0C4A5E"],
            ["#FF1E1B4B", "#FF2E1065", "#FF831843"],
            ["#FF1E1B4B", "#FF831843", "#FFB91C1C"],
        ],
        "partlyCloudy": [
            ["#FF050308", "#FF1E1B4B", "#FF475569"],
            ["#FF0F0716", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF0C4A5E", "#FF2E1065"],
            ["#FF1E1B4B", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFC2410C"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
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
            ["#FF050308", "#FF1E1B4B", "#FF1A2744"],  // singleDigits
            ["#FF050308", "#FF1E1B4B", "#FF475569"],  // freezing
            ["#FF050308", "#FF1E1B4B", "#FF312E81"],  // jacketWeather
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],  // flannelWeather
            ["#FF050308", "#FF2E1065", "#FF831843"],  // shortsWeather
            ["#FF050308", "#FF831843", "#FFB91C1C"],  // scorcher
        ],
        "rain": [
            ["#FF050308", "#FF1E1B4B", "#FF1A2744"],  // singleDigits
            ["#FF050308", "#FF1E1B4B", "#FF475569"],  // freezing
            ["#FF050308", "#FF1E1B4B", "#FF312E81"],  // jacketWeather
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],  // flannelWeather
            ["#FF050308", "#FF2E1065", "#FF831843"],  // shortsWeather
            ["#FF050308", "#FF831843", "#FFB91C1C"],  // scorcher
        ],
        "heavyRain": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],  // singleDigits
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],  // freezing
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],  // jacketWeather
            ["#FF050308", "#FF0A0F1E", "#FF018F91"],  // flannelWeather
            ["#FF050308", "#FF0F0716", "#FFB50060"],  // shortsWeather
            ["#FF050308", "#FF831843", "#FFF97316"],  // scorcher
        ],
        "freezingRain": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],  // singleDigits
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],  // freezing
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],  // jacketWeather
            ["#FF050308", "#FF0A0F1E", "#FF018F91"],  // flannelWeather
            ["#FF050308", "#FF0F0716", "#FFB50060"],  // shortsWeather
            ["#FF050308", "#FF831843", "#FFF97316"],  // scorcher
        ],
        "snow": [
            ["#FF0F0716", "#FF1E1B4B", "#FFEDE9FE"],  // singleDigits
            ["#FF0F0716", "#FF1E1B4B", "#FFC4B5FD"],  // freezing
            ["#FF0F0716", "#FF1E1B4B", "#FFE2E8F0"],  // jacketWeather
            ["#FF0F0716", "#FF1E1B4B", "#FF94A3B8"],  // flannelWeather
            ["#FF0F0716", "#FF2E1065", "#FF831843"],  // shortsWeather
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],  // scorcher
        ],
        "blizzard": [
            ["#FF050308", "#FF475569", "#FFEDE9FE"],  // singleDigits
            ["#FF050308", "#FF475569", "#FFC4B5FD"],  // freezing
            ["#FF050308", "#FF475569", "#FFE2E8F0"],  // jacketWeather
            ["#FF050308", "#FF475569", "#FFFAFAFA"],  // flannelWeather
            ["#FF050308", "#FF2E1065", "#FF831843"],  // shortsWeather
            ["#FF050308", "#FF831843", "#FFB91C1C"],  // scorcher
        ],
        "thunderstorm": [
            ["#FF050308", "#FF1E1B4B", "#FF2563EB"],
            ["#FF050308", "#FF0F0716", "#FF6366F1"],
            ["#FF050308", "#FF2E1065", "#FF8B5CF6"],
            ["#FF050308", "#FF1E1B4B", "#FFE6007A"],
            ["#FF050308", "#FF0F0716", "#FFA3E635"],
            ["#FF050308", "#FF831843", "#FFE6007A"],
        ],
        "hail": [
            ["#FF050308", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF050308", "#FF0A0F1E", "#FFE2E8F0"],
            ["#FF050308", "#FF0C4A5E", "#FF0F0716"],
            ["#FF050308", "#FF2E1065", "#FF0C4A5E"],
            ["#FF050308", "#FF831843", "#FF0C4A5E"],
            ["#FF050308", "#FFB91C1C", "#FF0C4A5E"],
        ],
    ]
}
