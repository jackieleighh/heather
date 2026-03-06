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
                                .font(.custom("Quicksand-Bold", size: 15))
                                .lineLimit(1)

                            Text("\(data.temperature)°")
                                .font(.custom("Poppins-Bold", size: 58))
                                .minimumScaleFactor(0.7)

                            Text("\(data.high)°/\(data.low)°")
                                .font(.custom("Quicksand-SemiBold", size: 13))
                                .opacity(0.9)

                            Text("Feels like \(data.feelsLike)°")
                                .font(.custom("Quicksand-Medium", size: 12))
                                .opacity(0.9)

                            Text(data.description.capitalized)
                                .font(.custom("Quicksand-Medium", size: 12))
                                .opacity(0.9)
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
                            if let alertLabel = data.alertLabel {
                                DetailLabel(
                                    icon: data.alertIcon,
                                    value: alertLabel,
                                    iconTint: data.alertColor
                                )
                            } else if let precipLabel = data.precipLabel {
                                DetailLabel(
                                    icon: precipIcon(precipLabel),
                                    value: precipLabel
                                )
                            } else {
                                Spacer().frame(height: 16)
                            }
                        }
                    }

                    Spacer()

                    // Quip
                    Text(data.quip)
                        .font(.custom("Poppins-Bold", size: 14))
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
                                        .font(.custom("Quicksand-Medium", size: 11))
                                        .opacity(0.9)
                                    WidgetConditionIcon(
                                        conditionName: entry.conditionName,
                                        isDay: entry.isDay ?? data.isDay,
                                        size: 28
                                    ).frame(height: 30)
                                    Text("\(entry.temperature)°")
                                        .font(.custom("Poppins-SemiBold", size: 13))
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
                .shadow(color: .black.opacity(0.3), radius: 0.5, x: 0, y: 0.5)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
        }
        .containerBackground(for: .widget) {
            ZStack {
                LinearGradient(
                    stops: WidgetGradients.gradientStops(from: data.gradientColors),
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
    var iconTint: Color? = nil

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .opacity(iconTint != nil ? 1.0 : 0.9)
                .foregroundStyle(iconTint ?? .white)
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 12))
                .lineLimit(1)
                .opacity(iconTint != nil ? 1.0 : 0.9)
        }
        .foregroundStyle(iconTint ?? .white)
    }
}
