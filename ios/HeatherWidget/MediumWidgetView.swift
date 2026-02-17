import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let data: WeatherData

    private var personaLogoName: String {
        switch data.persona {
        case "jade": return "jade_logo"
        case "luna": return "luna_logo"
        case "aurelia": return "aurelia_logo"
        default: return "heather_logo"
        }
    }

    var body: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                WeatherEffectOverlay(
                    conditionName: data.conditionName,
                    isDay: data.isDay,
                    scale: 0.8
                )

                // Persona logo overlay
                Image(personaLogoName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.black)
                    .opacity(0.2)
                    .offset(x:20,y:16)

                VStack(alignment: .leading, spacing: 0) {
                    // Top: city + temp on left, icon + sun/moon on right
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(data.cityName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)

                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("\(data.temperature)°")
                                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                                    .minimumScaleFactor(0.7)

                                Text("\(data.high)°/\(data.low)°")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .opacity(0.8)
                            }

                            Text("Feels like \(data.feelsLike)°")
                                .font(.system(size: 9))
                                .opacity(0.7)
                                .padding(.leading, 2)
                        }
                        Spacer()
                        // Condition icon + sunrise/sunset + UV/moon stacked
                        VStack(alignment: .trailing, spacing: 3) {
                            WidgetConditionIcon(
                                conditionName: data.conditionName,
                                isDay: data.isDay,
                                size: 32
                            )
                            if data.isDay {
                                if let sunsetLabel = data.sunsetLabel {
                                    MediumDetailLabel(
                                        icon: "sunset.fill",
                                        value: sunsetLabel
                                    )
                                }
                                MediumDetailLabel(
                                    icon: "sun.max.fill",
                                    value: "UV \(data.uvIndexMax ?? data.uvIndex)"
                                )
                            } else {
                                if let sunriseLabel = data.sunriseLabel {
                                    MediumDetailLabel(
                                        icon: "sunrise.fill",
                                        value: sunriseLabel
                                    )
                                }
                                let phase = getMoonPhase()
                                MediumDetailLabel(
                                    icon: phase.sfSymbol,
                                    value: "\(moonIllumination())%"
                                )
                            }
                        }
                    }

                    Spacer()

                    // Middle: quip
                    Text(data.quip)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .opacity(0.9)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    // Bottom: condensed hourly forecast
                    if let hours = data.hourly, !hours.isEmpty {
                        HStack(spacing: 0) {
                            ForEach(Array(hours.prefix(8).enumerated()), id: \.offset) { _, entry in
                                VStack(spacing: 1) {
                                    Text(entry.hourLabel)
                                        .font(.system(size: 8))
                                        .opacity(0.7)
                                    WidgetConditionIcon(
                                        conditionName: entry.conditionName,
                                        isDay: data.isDay,
                                        size: 12
                                    ).frame(height: 14)
                                    Text("\(entry.temperature)°")
                                        .font(.system(size: 9, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .foregroundStyle(.white)
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: data.gradientColors.map { Color(hex: $0) },
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
        }
    }
}

private struct MediumDetailLabel: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .opacity(0.7)
            Text(value)
                .font(.system(size: 9, weight: .semibold))
                .opacity(0.8)
        }
    }
}
