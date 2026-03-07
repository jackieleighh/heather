import Foundation
import SwiftUI

struct WidgetGradients {

    static func gradientStops(from hexColors: [String], condition: String = "", isDay: Bool = true) -> [Gradient.Stop] {
        let colors = hexColors.map { Color(hex: $0) }
        let useWeightedStops = isDay && isSunnyType(condition)
        if !useWeightedStops {
            // Even distribution for night and non-sunny day conditions
            return colors.enumerated().map { .init(color: $1, location: Double($0) / Double(max(colors.count - 1, 1))) }
        }
        switch colors.count {
        case 1:
            return [.init(color: colors[0], location: 0)]
        case 2:
            return [.init(color: colors[0], location: 0), .init(color: colors[1], location: 1)]
        case 3:
            return zip(colors, [0.0, 0.8, 1.0]).map { .init(color: $0, location: $1) }
        case 4:
            return zip(colors, [0.0, 0.65, 0.85, 1.0]).map { .init(color: $0, location: $1) }
        case 5:
            return zip(colors, [0.0, 0.4, 0.65, 0.85, 1.0]).map { .init(color: $0, location: $1) }
        default:
            return colors.enumerated().map { .init(color: $1, location: Double($0) / Double(colors.count - 1)) }
        }
    }

    private static func isSunnyType(_ condition: String) -> Bool {
        ["sunny", "mostlySunny", "partlyCloudy", "clear"].contains(condition)
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
            ["#FF8B75E5", "#FFA08CF0", "#FF9088DD"],
            ["#FF9088DD", "#FF75A0E0", "#FF88C8E8"],
            ["#FF88C8E8", "#FF40B8C8", "#FF74A85E"],
            ["#FF40B8C8", "#FF74A85E", "#FFC49E2E"],
            ["#FF74A85E", "#FFE0B430", "#FFF06A0A"],
            ["#FFE0B430", "#FFF06A0A", "#FFB50060"],
        ],
        "overcast": [
            ["#FF6465C4", "#FF8D93CE", "#FFB8A5E0"],
            ["#FF7464C7", "#FF687CC0", "#FF7BAEE3"],
            ["#FF7464C7", "#FF4E8FAE", "#FF74A85E"],
            ["#FF4E8FAE", "#FF74A85E", "#FFC49E2E"],
            ["#FF9B7AC6", "#FFC49E2E", "#FFF06A0A"],
            ["#FFE27D25", "#FFF06A0A", "#FFB50060"],
        ],
        "drizzle": [
            ["#FF7464C7", "#FF7BAEE3", "#FF687CC0"],
            ["#FF7464C7", "#FF7BAEE3", "#FF4E8FAE"],
            ["#FF7BAEE3", "#FF4E8FAE", "#FF74A85E"],
            ["#FF687CC0", "#FF74A85E", "#FFC49E2E"],
            ["#FF687CC0", "#FFC49E2E", "#FFF06A0A"],
            ["#FF687CC0", "#FFE27D25", "#FFB5436E"],
        ],
        "rain": [
            ["#FF7464C7", "#FF7BAEE3", "#FF687CC0"],
            ["#FF7464C7", "#FF7BAEE3", "#FF4E8FAE"],
            ["#FF7BAEE3", "#FF4E8FAE", "#FF74A85E"],
            ["#FF687CC0", "#FF74A85E", "#FFC49E2E"],
            ["#FF687CC0", "#FFC49E2E", "#FFF06A0A"],
            ["#FF687CC0", "#FFE27D25", "#FFB5436E"],
        ],
        "heavyRain": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF8A9CBE"],
            ["#FF405888", "#FF4A8EC2", "#FF4E8FAE"],
            ["#FF405888", "#FF4E8FAE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "freezingRain": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF8A9CBE"],
            ["#FF405888", "#FF4A8EC2", "#FF4E8FAE"],
            ["#FF405888", "#FF4E8FAE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FF8B75E5", "#FF9AAFE5"],
            ["#FFFAFAFA", "#FF9AAFE5", "#FF92D0FC"],
            ["#FFFAFAFA", "#FF92D0FC", "#FF5BC6F0"],
            ["#FFFAFAFA", "#FF5BC6F0", "#FF5EA6D5"],
            ["#FFFAFAFA", "#FF5EA6D5", "#FF4E8FAE"],
            ["#FFFAFAFA", "#FF4E8FAE", "#FFF06A0A"],
        ],
        "blizzard": [
            ["#FFFAFAFA", "#FF8B75E5", "#FF9AAFE5"],
            ["#FFFAFAFA", "#FF9AAFE5", "#FF92D0FC"],
            ["#FFFAFAFA", "#FF92D0FC", "#FF5BC6F0"],
            ["#FFFAFAFA", "#FF5BC6F0", "#FF5EA6D5"],
            ["#FFFAFAFA", "#FF5EA6D5", "#FF4E8FAE"],
            ["#FFFAFAFA", "#FF4E8FAE", "#FFF06A0A"],
        ],
        "thunderstorm": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF8A9CBE"],
            ["#FF405888", "#FF4A8EC2", "#FF4E8FAE"],
            ["#FF405888", "#FF4E8FAE", "#FFD4960A"],
            ["#FF405888", "#FFD4960A", "#FFC2410C"],
            ["#FF405888", "#FFC2410C", "#FFB50060"],
        ],
        "hail": [
            ["#FF405888", "#FF2563EB", "#FF7C8FCC"],
            ["#FF405888", "#FF7C8FCC", "#FF8A9CBE"],
            ["#FF405888", "#FF4A8EC2", "#FF4E8FAE"],
            ["#FF405888", "#FF4E8FAE", "#FFD4960A"],
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
            ["#FF1E1B4B", "#FF2E1065", "#FF7B2D35"],
            ["#FF1E1B4B", "#FF2E1065", "#FF831843"],
        ],
        "overcast": [
            ["#FF0F0716", "#FF1E1B4B", "#FF312E81"],
            ["#FF0F0716", "#FF2E1065", "#FF1A3A8C"],
            ["#FF1A2744", "#FF134A66", "#FF0E4A3A"],
            ["#FF0C4A5E", "#FF0E4A3A", "#FF552A0D"],
            ["#FF2E1065", "#FF552A0D", "#FF64250C"],
            ["#FF552A0D", "#FF64250C", "#FF831843"],
        ],
        "drizzle": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FF7B2D35"],
            ["#FF050308", "#FF2E1065", "#FF831843"],
        ],
        "rain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FF7B2D35"],
            ["#FF050308", "#FF2E1065", "#FF831843"],
        ],
        "heavyRain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "snow": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FFA08CF0"],
            ["#FF0F0716", "#FF134A66", "#FF88C8E8"],
            ["#FF0F0716", "#FF0C4A5E", "#FF86D2D6"],
            ["#FF0F0716", "#FF831843", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FFE05A9C"],
        ],
        "blizzard": [
            ["#FF0F0716", "#FF2E1065", "#FFEDE9FE"],
            ["#FF0F0716", "#FF312E81", "#FFA08CF0"],
            ["#FF0F0716", "#FF134A66", "#FF88C8E8"],
            ["#FF0F0716", "#FF0C4A5E", "#FF86D2D6"],
            ["#FF0F0716", "#FF831843", "#FFF06A0A"],
            ["#FF0F0716", "#FFF06A0A", "#FFE05A9C"],
        ],
        "thunderstorm": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
        "hail": [
            ["#FF050308", "#FF2E1065", "#FF4C1D95"],
            ["#FF050308", "#FF2E1065", "#FF1A3A8C"],
            ["#FF050308", "#FF2E1065", "#FF134A66"],
            ["#FF050308", "#FF2E1065", "#FF0E4A3A"],
            ["#FF050308", "#FF2E1065", "#FFB91C1C"],
            ["#FF050308", "#FF2E1065", "#FFB50060"],
        ],
    ]
}
