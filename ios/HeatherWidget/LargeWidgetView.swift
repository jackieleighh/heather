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
                // Persona logo overlay
                Image(personaLogoName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(0.15)
                    .offset(x:20,y:16)

                VStack(alignment: .leading, spacing: 8) {
                    // Top row: city + icon
                    HStack {
                        Text(data.cityName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 60
                        )
                    }

                    // Temperature
                    HStack(alignment: .top, spacing: 4) {
                        Text("\(data.temperature)°")
                            .font(.system(size: 56, weight: .semibold, design: .rounded))
                            .minimumScaleFactor(0.7)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(data.description.capitalized)
                                .font(.caption)
                                .opacity(0.8)
                            Text("H:\(data.high)° L:\(data.low)°")
                                .font(.caption)
                                .fontWeight(.medium)
                                .opacity(0.9)
                        }
                        .padding(.top, 8)
                    }

                    // Quip
                    Text(data.quip)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(3)
                        .opacity(0.95)

                    Spacer()

                    // Detail row
                    HStack(spacing: 16) {
                        DetailPill(label: "Feels", value: "\(data.feelsLike)°")
                        DetailPill(label: "Humidity", value: "\(data.humidity)%")
                        DetailPill(label: "Wind", value: "\(data.windSpeed) mph")
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
