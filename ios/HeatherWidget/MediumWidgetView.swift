import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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
                    .frame(width: 100, height: 100)
                    .opacity(0.2)
                    .offset(x:20,y:16)

                VStack(alignment: .leading, spacing: 6) {
                    // Top row: city + icon
                    HStack {
                        Text(data.cityName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 36
                        )
                    }

                    // Temperature row
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(data.temperature)°")
                            .font(.system(size: 42, weight: .semibold, design: .rounded))
                            .minimumScaleFactor(0.7)

                        Text("H:\(data.high)° L:\(data.low)°")
                            .font(.caption2)
                            .opacity(0.8)
                    }

                    // Quip spanning full width
                    Text(data.quip)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .opacity(0.9)
                        .fixedSize(horizontal: false, vertical: true)
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
