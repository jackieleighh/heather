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

                VStack(alignment: .leading, spacing: 2) {
                    // City name
                    Text(data.cityName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    // Temperature row with icon
                    HStack(alignment: .center) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(data.temperature)°")
                                .font(.system(size: 52, weight: .semibold, design: .rounded))
                                .minimumScaleFactor(0.7)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("H:\(data.high)° L:\(data.low)°")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .opacity(0.9)
                                Text(data.description.capitalized)
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                        }
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 48
                        )
                    }

                    Spacer()

                    // Hourly forecast
                    if let hours = data.hourly, !hours.isEmpty {
                        HStack(spacing: 0) {
                            ForEach(Array(hours.prefix(8).enumerated()), id: \.offset) { _, entry in
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
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }

                    Spacer()
                    
                    // Quip
                    Text(data.quip)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .opacity(0.95)
                        .padding(.top, 8)
                    
                    Spacer()

                    // Detail row
                    HStack(spacing: 12) {
                        DetailPill(label: "Feels", value: "\(data.feelsLike)°")
                        DetailPill(label: "Humidity", value: "\(data.humidity)%")
                        DetailPill(label: "Wind", value: "\(data.windSpeed) mph")
                        if data.isDay {
                            DetailPill(label: "UV", value: "\(data.uvIndex)")
                        } else {
                            DetailPill(label: "Moon", value: "\(moonIllumination())%")
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

private struct DetailPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .opacity(0.7)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
