import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
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
                    scale: 0.6
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
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.08),
                        Color.black.opacity(0.04),
                        Color.black.opacity(0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(ContainerRelativeShape())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(data.cityName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 30
                        )
                    }

                    Spacer()

                    Text("\(data.temperature)°")
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.7)

                    Text("H:\(data.high)° L:\(data.low)°")
                        .font(.caption2)
                        .opacity(0.8)
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
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                ContainerRelativeShape()
                    .strokeBorder(.white.opacity(0.25), lineWidth: 0.75)
            }
        }
    }
}
