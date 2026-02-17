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
                    // Top: city + temp, icon top-right
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

                                Text("H:\(data.high)° L:\(data.low)°")
                                    .font(.caption2)
                                    .opacity(0.8)
                            }
                        }
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 32
                        )
                    }

                    Spacer()

                    // Middle: quip
                    Text(data.quip)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .opacity(0.9)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 8)
                    
                    Spacer()

                    // Bottom: conditions row
                    HStack(spacing: 0) {
                        MediumDetailPill(label: "Feels", value: "\(data.feelsLike)°")
                        MediumDetailPill(label: "Humidity", value: "\(data.humidity)%")
                        MediumDetailPill(label: "Wind", value: "\(data.windSpeed) mph")
                        if data.isDay {
                            MediumDetailPill(label: "UV", value: "\(data.uvIndex)")
                        } else {
                            MediumDetailPill(label: "Moon", value: "\(moonIllumination())%")
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

private struct MediumDetailPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 1) {
            Text(label)
                .font(.system(size: 9))
                .opacity(0.7)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
    }
}
