import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let data: WeatherData

    private var personaLogoName: String {
        switch data.persona {
        case "jade": return "jade_logo"
        case "luna": return "luna_logo"
        default: return "heather_logo"
        }
    }

    var body: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                // Persona logo overlay
                Image(personaLogoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .opacity(0.2)
                    .offset(x:20,y:16)

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
