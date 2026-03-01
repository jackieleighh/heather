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

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(data.cityName)
                            .font(.custom("Poppins-Medium", size: 12))
                            .lineLimit(1)
                        Spacer()
                        WidgetConditionIcon(
                            conditionName: data.conditionName,
                            isDay: data.isDay,
                            size: 26
                        )
                    }

                    Spacer(minLength: 0)

                    Text("\(data.temperature)°")
                        .font(.custom("Poppins-SemiBold", size: 48))
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)

                    Text("\(data.high)°/\(data.low)°")
                        .font(.custom("Poppins-Medium", size: 12))
                        .opacity(0.8)

                    Text("Feels like \(data.feelsLike)°")
                        .font(.custom("Poppins-Regular", size: 10))
                        .opacity(0.7)
                        .padding(.top, 1)

                    Text(data.description.capitalized)
                        .font(.custom("Poppins-Regular", size: 10))
                        .opacity(0.7)
                        .padding(.top, 1)
                }
                .padding(12)
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
