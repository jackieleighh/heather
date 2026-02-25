import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let data: WeatherData

    var body: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                WeatherEffectOverlay(
                    conditionName: data.conditionName,
                    isDay: data.isDay,
                    scale: 0.6
                )

                // Logo overlay
                Image("heather_logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.2 : 0.3)
                    .offset(x: 10, y: 16)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .top) {
                        Text(data.cityName)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .lineLimit(1)
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 26
                        )
                    }

                    Spacer()

                    Text("\(data.temperature)°")
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.7)

                    Text("\(data.high)°/\(data.low)°")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .opacity(0.8)

                    Text("Feels like \(data.feelsLike)°")
                        .font(.system(size: 9))
                        .opacity(0.7)

                    Text(data.description.capitalized)
                        .font(.system(size: 9))
                        .opacity(0.7)
                }
                .padding(16)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 0.5, x: 0, y: 0.5)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                LinearGradient(
                    colors: data.gradientColors.map { Color(hex: $0) },
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            }
        }
    }
}
