import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let data: WeatherData

    var body: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                WeatherEffectOverlay(
                    conditionName: data.conditionName,
                    isDay: data.isDay,
                    scale: 1.0
                )

                // Logo overlay
                Image("heather_logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.2 : 0.3)
                    .offset(x: 15, y: 20)

                VStack(alignment: .leading, spacing: 2) {
                    // Two-column layout
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.cityName)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .lineLimit(1)

                            Text("\(data.temperature)°")
                                .font(.system(size: 52, weight: .semibold, design: .rounded))
                                .minimumScaleFactor(0.7)

                            Text("\(data.high)°/\(data.low)°")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .opacity(0.9)

                            Text("Feels like \(data.feelsLike)°")
                                .font(.system(size: 11))
                                .opacity(0.7)

                            Text(data.description.capitalized)
                                .font(.system(size: 11))
                                .opacity(0.7)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            WidgetConditionIcon(
                                conditionName: data.conditionName,
                                isDay: data.isDay,
                                size: 48
                            )

                            if data.isDay {
                                if let sunsetLabel = data.sunsetLabel {
                                    DetailLabel(
                                        icon: "sunset.fill",
                                        value: sunsetLabel
                                    )
                                }
                                DetailLabel(
                                    icon: "sun.max.fill",
                                    value: "UV \(data.uvIndexMax ?? data.uvIndex)"
                                )
                            } else {
                                if let sunriseLabel = data.sunriseLabel {
                                    DetailLabel(
                                        icon: "sunrise.fill",
                                        value: sunriseLabel
                                    )
                                }
                                let phase = getMoonPhase()
                                DetailLabel(
                                    icon: phase.sfSymbol,
                                    value: "\(moonIllumination())%"
                                )
                            }
                        }
                    }

                    Spacer()

                    // Quip
                    Text(data.quip)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .lineLimit(3)
                        .opacity(0.95)

                    Spacer()

                    // Hourly forecast
                    if let hours = data.hourly, !hours.isEmpty {
                        let items = Array(hours.prefix(6))
                        HStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, entry in
                                VStack(spacing: 3) {
                                    Text(entry.hourLabel)
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                    WidgetConditionIcon(
                                        conditionName: entry.conditionName,
                                        isDay: data.isDay,
                                        size: 28
                                    ).frame(height: 30)
                                    Text("\(entry.temperature)°")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                }
                                if index < items.count - 1 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
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
                    startPoint: (data.conditionName == "sunny" || data.conditionName == "mostlySunny") ? .topTrailing : .top,
                    endPoint: (data.conditionName == "sunny" || data.conditionName == "mostlySunny") ? .bottomLeading : .bottom
                )
            }
        }
    }
}

private struct DetailLabel: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .opacity(0.7)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .opacity(0.8)
        }
    }
}
