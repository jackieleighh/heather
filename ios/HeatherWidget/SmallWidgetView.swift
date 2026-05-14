import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let data: WeatherData

    var body: some View {
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
                .overlay(alignment: .topTrailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        dayNightDetails
                    }
                    .offset(y: 38)
                }

                Spacer(minLength: 0)

                Text("\(data.temperature)\u{00B0}")
                    .font(.custom("Poppins-Bold", size: 48))
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 0)

                Text("\(data.high)\u{00B0}/\(data.low)\u{00B0}")
                    .font(.custom("Quicksand-SemiBold", size: 13))
                    .opacity(0.9)

                Text("Feels like \(data.feelsLike)\u{00B0}")
                    .font(.custom("Quicksand-Medium", size: 11))
                    .opacity(0.9)
                    .padding(.top, 1)

                if let alertText = data.alertText {
                    HStack(spacing: 2) {
                        Image(systemName: data.alertIcon)
                            .font(.system(size: 9))
                            .foregroundStyle(data.alertColor)
                        Text(alertText)
                            .font(.custom("Quicksand-SemiBold", size: 10))
                            .lineLimit(1)
                    }
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
        .containerBackground(for: .widget) {
            WidgetGradientBackground(
                hexColors: data.gradientColors,
                condition: data.conditionName,
                isDay: data.isDay
            )
        }
    }

    // MARK: - Day/Night Details

    @ViewBuilder
    private var dayNightDetails: some View {
        if data.isDay {
            if let sunsetLabel = data.sunsetLabel {
                SmallDetailLabel(icon: "sunset.fill", value: sunsetLabel)
            }
            SmallDetailLabel(
                icon: "sun.max.fill",
                value: "UV \(data.uvIndexMax ?? data.uvIndex) Max"
            )
        } else {
            if let sunriseLabel = data.sunriseLabel {
                SmallDetailLabel(icon: "sunrise.fill", value: sunriseLabel)
            }
            let moonIcon = data.moonPhaseSFSymbol ?? getMoonPhase().sfSymbol
            let moonIllum = data.moonIllumination ?? moonIllumination()
            SmallDetailLabel(icon: moonIcon, value: "\(moonIllum)%")
        }
    }
}

private struct SmallDetailLabel: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .opacity(0.9)
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 9))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .opacity(0.9)
        }
        .fixedSize(horizontal: true, vertical: true)
    }
}
