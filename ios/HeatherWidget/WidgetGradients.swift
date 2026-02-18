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

    /// Interpolates additional color stops between each pair for smoother gradients.
    static func smoothed(_ hexColors: [String]) -> [String] {
        guard hexColors.count >= 2 else { return hexColors }
        let stepsPerSegment = 8
        var result: [String] = []
        for i in 0..<hexColors.count - 1 {
            let c1 = parseRGB(hexColors[i])
            let c2 = parseRGB(hexColors[i + 1])
            for s in 0...stepsPerSegment {
                if i > 0 && s == 0 { continue }
                let linear = Double(s) / Double(stepsPerSegment)
                // Ease-in-out (smoothstep) for perceptually even transitions
                let t = linear * linear * (3.0 - 2.0 * linear)
                // Interpolate in linear-light (gamma 2.2)
                let r = pow(pow(c1.r, 2.2) * (1 - t) + pow(c2.r, 2.2) * t, 1 / 2.2)
                let g = pow(pow(c1.g, 2.2) * (1 - t) + pow(c2.g, 2.2) * t, 1 / 2.2)
                let b = pow(pow(c1.b, 2.2) * (1 - t) + pow(c2.b, 2.2) * t, 1 / 2.2)
                result.append(String(format: "#FF%02X%02X%02X",
                    min(max(Int(r * 255), 0), 255),
                    min(max(Int(g * 255), 0), 255),
                    min(max(Int(b * 255), 0), 255)))
            }
        }
        return result
    }

    private static func parseRGB(_ hex: String) -> (r: Double, g: Double, b: Double) {
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

    private static let dayGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF8B9DD4", "#FFC4B5FD", "#FF2563EB"],
            ["#FF8B9DD4", "#FF7C8FCC", "#FF68B2DB"],
            ["#FF4A8EC2", "#FF68B2DB", "#FF058285"],
            ["#FF4A8EC2", "#FF5BA847", "#FFD4960A"],
            ["#FF5BA847", "#FFD4960A", "#FFFF8C00"],
            ["#FFFBBF24", "#FFFF8C00", "#FFF472B6"],
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
            ["#FF4A8EC2", "#FF475569", "#FF0C4A5E"],
            ["#FF4A8EC2", "#FF6E8A5E", "#FF9C8535"],
            ["#FF4A8EC2", "#FF9C8535", "#FFC2410C"],
            ["#FF4A8EC2", "#FFC2410C", "#FF831843"],
        ],
        "rain": [
            ["#FF7C8FCC", "#FF8B9DD4", "#FF312E81"],
            ["#FF7C8FCC", "#FF94A3B8", "#FF475569"],
            ["#FF4A8EC2", "#FF475569", "#FF0C4A5E"],
            ["#FF4A8EC2", "#FF6E8A5E", "#FF9C8535"],
            ["#FF4A8EC2", "#FF9C8535", "#FFC2410C"],
            ["#FF4A8EC2", "#FFC2410C", "#FF831843"],
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
            ["#FF312E81", "#FF2563EB", "#FF475569"],
            ["#FF312E81", "#FF475569", "#FF7C8FCC"],
            ["#FF312E81", "#FF475569", "#FF0C4A5E"],
            ["#FF312E81", "#FF6E8A5E", "#FF9C8535"],
            ["#FF312E81", "#FF9C8535", "#FFC2410C"],
            ["#FF312E81", "#FFC2410C", "#FF831843"],
        ],
        "hail": [
            ["#FF312E81", "#FF2563EB", "#FF475569"],
            ["#FF312E81", "#FF475569", "#FF7C8FCC"],
            ["#FF312E81", "#FF475569", "#FF0C4A5E"],
            ["#FF312E81", "#FF6E8A5E", "#FF9C8535"],
            ["#FF312E81", "#FF9C8535", "#FFC2410C"],
            ["#FF312E81", "#FFC2410C", "#FF831843"],
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
            ["#FF050308", "#FF0F0716", "#FFB50060"],
            ["#FF050308", "#FF831843", "#FFF97316"],
        ],
        "freezingRain": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0F0716", "#FFB50060"],
            ["#FF050308", "#FF831843", "#FFF97316"],
        ],
        "snow": [
            ["#FF0F0716", "#FF1E1B4B", "#FFEDE9FE"],
            ["#FF0F0716", "#FF1E1B4B", "#FFC4B5FD"],
            ["#FF0F0716", "#FF1E1B4B", "#FFE2E8F0"],
            ["#FF0F0716", "#FF1E1B4B", "#FF94A3B8"],
            ["#FF0F0716", "#FF2E1065", "#FF831843"],
            ["#FF0F0716", "#FF831843", "#FFB91C1C"],
        ],
        "blizzard": [
            ["#FF050308", "#FF475569", "#FFEDE9FE"],
            ["#FF050308", "#FF475569", "#FFC4B5FD"],
            ["#FF050308", "#FF475569", "#FFE2E8F0"],
            ["#FF050308", "#FF475569", "#FFFAFAFA"],
            ["#FF050308", "#FF2E1065", "#FF831843"],
            ["#FF050308", "#FF831843", "#FFB91C1C"],
        ],
        "thunderstorm": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0F0716", "#FFB50060"],
            ["#FF050308", "#FF831843", "#FFF97316"],
        ],
        "hail": [
            ["#FF050308", "#FF0A0F1E", "#FF475569"],
            ["#FF050308", "#FF0A0F1E", "#FF312E81"],
            ["#FF050308", "#FF0A0F1E", "#FF6366F1"],
            ["#FF050308", "#FF0A0F1E", "#FF058285"],
            ["#FF050308", "#FF0F0716", "#FFB50060"],
            ["#FF050308", "#FF831843", "#FFF97316"],
        ],
    ]
}
