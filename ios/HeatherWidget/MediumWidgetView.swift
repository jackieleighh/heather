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

                // Dark scrim for text readability
                Color.black.opacity(0.08)
                    .clipShape(ContainerRelativeShape())

                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(data.cityName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    // Details row: H/L + feels like on left, labels + icon on right
                    HStack(alignment: .bottom, spacing: 1) {
                        
                        Text("\(data.temperature)°")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .minimumScaleFactor(0.7)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(data.high)°/\(data.low)°")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .opacity(0.8)

                            Text("Feels like \(data.feelsLike)°")
                                .font(.system(size: 9))
                                .opacity(0.7)
                            
                            Text(data.description.capitalized)
                                .font(.system(size: 9))
                                .opacity(0.7)
                        }

                        Spacer()

                        HStack(alignment: .bottom, spacing: 4) {
                            VStack(alignment: .trailing, spacing: 3) {
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
                            WidgetConditionIcon(
                                conditionName: data.conditionName,
                                isDay: data.isDay,
                                size: 32
                            )
                        }
                    }

//                    Spacer(minLength: 4)
//
//                    // Middle: quip
//                    Text(data.quip)
//                        .font(.caption2)
//                        .fontWeight(.medium)
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                        .opacity(0.9)

                    Spacer()

                    // Bottom: condensed hourly forecast
                    if let hours = data.hourly, !hours.isEmpty {
                        let items = Array(hours.prefix(6))
                        HStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, entry in
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
                                if index < items.count - 1 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
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
        .fixedSize()
    }
}
