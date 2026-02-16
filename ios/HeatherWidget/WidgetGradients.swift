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
            ["#FFEDE9FE", "#FFC4B5FD", "#FF38BDF8"],
            ["#FFEDE9FE", "#FF96D9DB", "#FF38BDF8"],
            ["#FF96D9DB", "#FF38BDF8", "#FF00CED1"],
            ["#FF38BDF8", "#FFA3E635", "#FFFDE047"],
            ["#FFA3E635", "#FFFDE047", "#FFFF8C00"],
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
            ["#FF94A3B8", "#FF475569", "#FF312E81"],
            ["#FFE2E8F0", "#FF94A3B8", "#FF475569"],
            ["#FF94A3B8", "#FF475569", "#FF96D9DB"],
            ["#FF475569", "#FF96D9DB", "#FF2E1065"],
            ["#FF94A3B8", "#FF2E1065", "#FF0C4A5E"],
            ["#FF475569", "#FFF97316", "#FF831843"],
        ],
        "drizzle": [
            ["#FFE2E8F0", "#FF94A3B8", "#FF475569"],
            ["#FFE2E8F0", "#FF94A3B8", "#FF38BDF8"],
            ["#FF94A3B8", "#FF96D9DB", "#FF475569"],
            ["#FF94A3B8", "#FF475569", "#FF8B5CF6"],
            ["#FF94A3B8", "#FF475569", "#FFE6007A"],
            ["#FF475569", "#FF831843", "#FFEF4444"],
        ],
        "rain": [
            ["#FF94A3B8", "#FF475569", "#FF312E81"],
            ["#FF475569", "#FF312E81", "#FF2563EB"],
            ["#FF475569", "#FF2563EB", "#FF0C4A5E"],
            ["#FF475569", "#FF6366F1", "#FF2E1065"],
            ["#FF1E1B4B", "#FF2E1065", "#FFE6007A"],
            ["#FF1E1B4B", "#FF831843", "#FFB91C1C"],
        ],
        "heavyRain": [
            ["#FF1E1B4B", "#FF312E81", "#FF2563EB"],
            ["#FF1E1B4B", "#FF2563EB", "#FF6366F1"],
            ["#FF0F0716", "#FF2E1065", "#FF2563EB"],
            ["#FF0F0716", "#FF0C4A5E", "#FFA3E635"],
            ["#FF050308", "#FF831843", "#FF8B5CF6"],
            ["#FF050308", "#FF831843", "#FFE6007A"],
        ],
        "freezingRain": [
            ["#FF94A3B8", "#FF475569", "#FF0C4A5E"],
            ["#FFE2E8F0", "#FF38BDF8", "#FF0C4A5E"],
            ["#FF475569", "#FF2563EB", "#FF00CED1"],
            ["#FF475569", "#FF6366F1", "#FF0C4A5E"],
            ["#FF1E1B4B", "#FF0C4A5E", "#FFE6007A"],
            ["#FF050308", "#FF0C4A5E", "#FFB91C1C"],
        ],
        "snow": [
            ["#FFEDE9FE", "#FFC4B5FD", "#FF94A3B8"],
            ["#FFFAFAFA", "#FFEDE9FE", "#FF38BDF8"],
            ["#FFFAFAFA", "#FFE2E8F0", "#FF96D9DB"],
            ["#FFE2E8F0", "#FF475569", "#FF8B5CF6"],
            ["#FFE2E8F0", "#FF8B5CF6", "#FFE6007A"],
            ["#FFE2E8F0", "#FFE6007A", "#FFB91C1C"],
        ],
        "blizzard": [
            ["#FFFAFAFA", "#FFE2E8F0", "#FF94A3B8"],
            ["#FFFAFAFA", "#FFE2E8F0", "#FF475569"],
            ["#FFFAFAFA", "#FF475569", "#FF2563EB"],
            ["#FFFAFAFA", "#FF8B5CF6", "#FF2E1065"],
            ["#FFFAFAFA", "#FFE6007A", "#FF050308"],
            ["#FFFAFAFA", "#FFB91C1C", "#FF050308"],
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
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF050308", "#FF1E1B4B", "#FF312E81"],
            ["#FF0F0716", "#FF2E1065", "#FF312E81"],
            ["#FF0F0716", "#FF2E1065", "#FF0C4A5E"],
            ["#FF050308", "#FF0F0716", "#FFF97316"],
            ["#FF050308", "#FF0F0716", "#FFB91C1C"],
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
            ["#FF050308", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF1E1B4B", "#FF475569"],
            ["#FF0F0716", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF0F0716", "#FF2E1065", "#FF1E1B4B"],
            ["#FF0F0716", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],
        ],
        "drizzle": [
            ["#FF050308", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF1E1B4B", "#FF475569"],
            ["#FF0F0716", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF0F0716", "#FF2E1065", "#FF1E1B4B"],
            ["#FF0F0716", "#FF831843", "#FFF97316"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
        ],
        "rain": [
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF1E1B4B", "#FF2563EB"],
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF050308", "#FF0F0716", "#FF2E1065"],
            ["#FF050308", "#FF0F0716", "#FF831843"],
            ["#FF050308", "#FF1E1B4B", "#FFB91C1C"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF0A0F1E", "#FF2563EB"],
            ["#FF050308", "#FF1E1B4B", "#FF6366F1"],
            ["#FF050308", "#FF0F0716", "#FF0C4A5E"],
            ["#FF050308", "#FF0F0716", "#FF2E1065"],
            ["#FF050308", "#FF831843", "#FFE6007A"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF1E1B4B", "#FF0C4A5E"],
            ["#FF050308", "#FF0A0F1E", "#FF00CED1"],
            ["#FF050308", "#FF2E1065", "#FF0C4A5E"],
            ["#FF050308", "#FF0F0716", "#FF0C4A5E"],
            ["#FF050308", "#FF831843", "#FFF97316"],
            ["#FF050308", "#FF0C4A5E", "#FFB91C1C"],
        ],
        "snow": [
            ["#FF10071F", "#FF312E81", "#FFC4B5FD"],
            ["#FF050308", "#FF1E1B4B", "#FFEDE9FE"],
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF831843", "#FFEDE9FE"],
            ["#FF050308", "#FF831843", "#FFF97316"],
            ["#FF050308", "#FFB91C1C", "#FFFAFAFA"],
        ],
        "blizzard": [
            ["#FF050308", "#FF94A3B8", "#FFFAFAFA"],
            ["#FF050308", "#FF475569", "#FFFAFAFA"],
            ["#FF050308", "#FF1E1B4B", "#FFE2E8F0"],
            ["#FF050308", "#FF2E1065", "#FFE2E8F0"],
            ["#FF050308", "#FF831843", "#FFFAFAFA"],
            ["#FF050308", "#FFB91C1C", "#FFFAFAFA"],
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
