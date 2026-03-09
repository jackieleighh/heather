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
                    .frame(height: 100)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.15 : 0.4)
                    .offset(x: 10, y: 16)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(data.cityName)
                            .font(.custom("Quicksand-Bold", size: 12))
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
                        .font(.custom("Poppins-Bold", size: 48))
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)

                    Text("\(data.high)°/\(data.low)°")
                        .font(.custom("Quicksand-SemiBold", size: 13))
                        .opacity(0.9)

                    Text("Feels like \(data.feelsLike)°")
                        .font(.custom("Quicksand-Medium", size: 11))
                        .opacity(0.9)
                        .padding(.top, 1)

                    if let alertLabel = data.alertLabel {
                        HStack(spacing: 2) {
                            Image(systemName: data.alertIcon)
                                .font(.system(size: 9))
                            Text(alertLabel)
                                .font(.custom("Quicksand-SemiBold", size: 10))
                                .lineLimit(1)
                        }
                        .foregroundStyle(data.alertColor)
                        .padding(.top, 1)
                    } else {
                        Text(data.description.capitalized)
                            .font(.custom("Quicksand-Medium", size: 11))
                            .opacity(0.9)
                            .padding(.top, 1)
                    }
                }
                .padding(12)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 0.5, x: 0, y: 0.5)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
        }
        .containerBackground(for: .widget) {
            WidgetGradientBackground(
                hexColors: data.gradientColors,
                condition: data.conditionName,
                isDay: data.isDay
            )
        }
    }
}
