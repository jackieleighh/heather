import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let data: WeatherData
    var entryDate: Date = Date()

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
                    .frame(height: 170)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.15 : 0.4)
                    .offset(x: 15, y: 20)

                VStack(alignment: .leading, spacing: 2) {
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

                        Spacer(minLength: 4)

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
                                let moonIcon = data.moonPhaseSFSymbol ?? getMoonPhase().sfSymbol
                                let moonIllum = data.moonIllumination ?? moonIllumination()
                                DetailLabel(
                                    icon: moonIcon,
                                    value: "\(moonIllum)%"
                                )
                            }
                            if let alertText = data.alertText {
                                DetailLabel(
                                    icon: data.alertIcon,
                                    value: alertText,
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
                            if let summary = data.widgetSummary,
                               data.summaryIsDay == nil || data.summaryIsDay == data.isDay {
                                Text(summary)
                                    .font(.custom("Quicksand-Medium", size: 12))
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                    .opacity(0.95)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }

                    Spacer()

                    // Quip
                    Text(data.quip)
                        .font(.custom("Poppins", size: 16))
                        .lineLimit(3)
                        .opacity(0.95)

                    Spacer()

                    // Timeline graph
                    if let segments = data.timelineSegments, !segments.isEmpty {
                        TimelineBarView(
                            segments: segments,
                            hasPrecip: data.hasPrecipInTimeline ?? false,
                            isDay: data.isDay,
                            entryDate: entryDate,
                            utcOffsetSeconds: data.utcOffsetSeconds
                        )
                    }
                }
                .padding(16)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 0.5, x: 0, y: 0.5)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
        }
        .containerBackground(for: .widget) {
            WidgetGradientBackground(
                hexColors: data.gradientColors,
                condition: data.conditionName,
                isDay: data.isDay,
                family: .systemLarge
            )
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
                .foregroundStyle(.white)
        }
    }
}
