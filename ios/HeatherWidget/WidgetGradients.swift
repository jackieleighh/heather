import Foundation
import SwiftUI
import WidgetKit

struct WidgetGradients {

    static func gradientStops(from hexColors: [String], condition: String = "", isDay: Bool = true, family: WidgetFamily = .systemSmall) -> [Gradient.Stop] {
        guard hexColors.count > 1 else {
            return [.init(color: Color(hex: hexColors.first ?? "FF000000"), location: 0)]
        }

        let stepsPerSegment = 24 // intermediate colors between each pair
        var stops: [Gradient.Stop] = []
        let totalSegments = hexColors.count - 1
        let totalStops = totalSegments * stepsPerSegment + 1

        for i in 0..<totalSegments {
            let c1 = parseRGB(hexColors[i])
            let c2 = parseRGB(hexColors[i + 1])

            for step in 0..<stepsPerSegment {
                let linear = Double(step) / Double(stepsPerSegment)
                // Smoothstep easing for less visible banding
                let t = linear * linear * (3.0 - 2.0 * linear)
                let r = c1.r + (c2.r - c1.r) * t
                let g = c1.g + (c2.g - c1.g) * t
                let b = c1.b + (c2.b - c1.b) * t
                let stopIndex = i * stepsPerSegment + step
                let location = Double(stopIndex) / Double(totalStops - 1)
                stops.append(.init(color: Color(red: r, green: g, blue: b), location: location))
            }
        }

        // Add the final color
        let last = parseRGB(hexColors.last!)
        stops.append(.init(color: Color(red: last.r, green: last.g, blue: last.b), location: 1.0))

        return stops
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
        case "freezingRain": return "heavyRain"
        case "thunderstorm": return "heavyRain"
        case "hail": return "heavyRain"
        case "blizzard": return "snow"
        default: return condition
        }
    }

    // MARK: - Day Gradients
    // Each entry: [[tier0], [tier1], [tier2], [tier3], [tier4], [tier5]]
    // Colors match BackgroundGradients in background_gradients.dart

    private static let dayGradients: [String: [[String]]] = [
        "sunny": [
            ["#FF70A8FF", "#FF80A8F8", "#FF9888F8"],
            ["#FF70B0FF", "#FF70B8F8", "#FF70D8F8"],
            ["#FF70B8F8", "#FF70D8F8", "#FF38C0A0"],
            ["#FF70D8F8", "#FF38C0A0", "#FFF0D838"],
            ["#FF38C0A0", "#FFF0D838", "#FFF08028"],
            ["#FFF0D838", "#FFF08028", "#FFD80070"],
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
            ["#FF6888D0", "#FF6878C0", "#FF8878D8"],
            ["#FF6888D0", "#FF5888C8", "#FF60A8E0"],
            ["#FF6888D0", "#FF5090C0", "#FF48C0A8"],
            ["#FF6888D0", "#FF88A8A0", "#FFE0C020"],
            ["#FF6888D0", "#FF9888B0", "#FFF09030"],
            ["#FF6888D0", "#FFA880B8", "#FFE84880"],
        ],
        "rain": [
            ["#FF5878C4", "#FF5C70B8", "#FF8074D0"],
            ["#FF5878C4", "#FF5080C0", "#FF5CA0DC"],
            ["#FF5878C4", "#FF4C88B8", "#FF44B8A0"],
            ["#FF5878C4", "#FF789090", "#FFDCBC20"],
            ["#FF5878C4", "#FF8878A8", "#FFEC8830"],
            ["#FF5878C4", "#FF9870A8", "#FFE4487C"],
        ],
        "heavyRain": [
            ["#FF3C5CB0", "#FF445CA8", "#FF6C64C0"],
            ["#FF3C5CB0", "#FF3C6CB0", "#FF4C8CD0"],
            ["#FF3C5CB0", "#FF3C74A8", "#FF34A490"],
            ["#FF3C5CB0", "#FF607880", "#FFCCAC18"],
            ["#FF3C5CB0", "#FF706898", "#FFDC7428"],
            ["#FF3C5CB0", "#FF806090", "#FFD43C70"],
        ],
        "snow": [
            ["#FFFAFAFA", "#FF7060D0", "#FF7890D0"],
            ["#FFFAFAFA", "#FF7890D0", "#FF68B8E8"],
            ["#FFFAFAFA", "#FF68B8E8", "#FF38A8D8"],
            ["#FFFAFAFA", "#FF38A8D8", "#FF4088B8"],
            ["#FFFAFAFA", "#FF4088B8", "#FF387898"],
            ["#FFFAFAFA", "#FF387898", "#FFD87420"],
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
            ["#FF050308", "#FF2E1065", "#FF96006b"],
            ["#FF050308", "#FF2E1065", "#FF960819"],
        ],
        "rain": [
            ["#FF050308", "#FF2E1065", "#FF400898"],
            ["#FF050308", "#FF2E1065", "#FF1830A0"],
            ["#FF050308", "#FF2E1065", "#FF186090"],
            ["#FF050308", "#FF2E1065", "#FF086040"],
            ["#FF050308", "#FF2E1065", "#FF96006b"],
            ["#FF050308", "#FF2E1065", "#FF960819"],
        ],
        "heavyRain": [
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
    ]
}

// MARK: - Gradient Background

/// Linear gradient from top to bottom, matching the Flutter app's visual feel.
struct WidgetGradientBackground: View {
    let hexColors: [String]
    let condition: String
    let isDay: Bool
    var family: WidgetFamily = .systemSmall

    var body: some View {
        LinearGradient(
            stops: WidgetGradients.gradientStops(
                from: hexColors, condition: condition, isDay: isDay, family: family
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
