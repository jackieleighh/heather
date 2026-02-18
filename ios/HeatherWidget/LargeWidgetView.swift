import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
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
                    scale: 1.0
                )

                // Persona logo overlay
                Image(personaLogoName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .foregroundColor(.black)
                    .opacity(0.2)
                    .offset(x:20,y:16)

                // Dark scrim for text readability
                Color.black.opacity(0.08)
                    .clipShape(ContainerRelativeShape())

                VStack(alignment: .leading, spacing: 2) {
                    // Two-column layout
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.cityName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)

                            Text("\(data.temperature)°")
                                .font(.system(size: 52, weight: .semibold, design: .rounded))
                                .minimumScaleFactor(0.7)

                            Text("\(data.high)°/\(data.low)°")
                                .font(.caption)
                                .fontWeight(.medium)
                                .opacity(0.9)

                            Text("Feels like \(data.feelsLike)°")
                                .font(.caption2)
                                .opacity(0.7)

                            Text(data.description.capitalized)
                                .font(.caption2)
                                .opacity(0.7)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            WidgetConditionIcon(
                                conditionName: data.conditionName,
                                isDay: data.isDay,
                                size: 48
                            )

                            if data.isDay {
                                if let sunsetLabel = data.sunsetLabel {
                                    DetailLabel(
                                        icon: "sunset.fill",
                                        value: sunsetLabel
                                    )
                                }
                                DetailLabel(
                                    icon: "sun.max.fill",
                                    value: "UV \(data.uvIndexMax ?? data.uvIndex)"
                                )
                            } else {
                                if let sunriseLabel = data.sunriseLabel {
                                    DetailLabel(
                                        icon: "sunrise.fill",
                                        value: sunriseLabel
                                    )
                                }
                                let phase = getMoonPhase()
                                DetailLabel(
                                    icon: phase.sfSymbol,
                                    value: "\(moonIllumination())%"
                                )
                            }
                        }
                    }

                    Spacer()

                    // Quip
                    Text(data.quip)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .opacity(0.95)

                    Spacer()

                    // Hourly forecast
                    if let hours = data.hourly, !hours.isEmpty {
                        let items = Array(hours.prefix(6))
                        HStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, entry in
                                VStack(spacing: 3) {
                                    Text(entry.hourLabel)
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                    WidgetConditionIcon(
                                        conditionName: entry.conditionName,
                                        isDay: data.isDay,
                                        size: 16
                                    ).frame(height: 20)
                                    Text("\(entry.temperature)°")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                if index < items.count - 1 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                LinearGradient(
                    colors: data.gradientColors.map { Color(hex: $0) },
                    startPoint: (data.conditionName == "sunny" || data.conditionName == "mostlySunny") ? .topTrailing : .top,
                    endPoint: (data.conditionName == "sunny" || data.conditionName == "mostlySunny") ? .bottomLeading : .bottom
                )
                ContainerRelativeShape()
                    .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
            }
        }
    }
}

private struct DetailLabel: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .opacity(0.7)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .opacity(0.8)
        }
    }
}
