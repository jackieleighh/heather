import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let data: WeatherData
    var entryDate: Date = Date()

    var body: some View {
        if data.widgetSummary != nil {
            newLayout
        } else {
            legacyLayout
        }
    }

    // MARK: - New 3-Layer Layout

    private var newLayout: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                WeatherEffectOverlay(
                    conditionName: data.conditionName,
                    isDay: data.isDay,
                    scale: 0.8
                )

                Image("heather_logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.15 : 0.4)
                    .offset(x: 10, y: 16)

                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        // Left column: weather details
                        VStack(alignment: .leading, spacing: 0) {
                            Text(data.cityName)
                                .font(.custom("Quicksand-Bold", size: 12))
                                .lineLimit(1)

                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(data.temperature)°")
                                    .font(.custom("Poppins-Bold", size: 42))
                                    .minimumScaleFactor(0.7)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("\(data.high)°/\(data.low)°")
                                        .font(.custom("Quicksand-SemiBold", size: 13))
                                        .opacity(0.9)

                                    Text("Feels like \(data.feelsLike)°")
                                        .font(.custom("Quicksand-Medium", size: 11))
                                        .opacity(0.9)

                                    if let alertText = data.alertText {
                                        HStack(spacing: 2) {
                                            Image(systemName: data.alertIcon)
                                                .font(.system(size: 9))
                                                .foregroundStyle(data.alertColor)
                                            Text(alertText)
                                                .font(.custom("Quicksand-SemiBold", size: 10))
                                                .lineLimit(1)
                                        }
                                    } else {
                                        Text(data.description.capitalized)
                                            .font(.custom("Quicksand-Medium", size: 11))
                                            .opacity(0.9)
                                    }
                                }
                                .padding(.bottom, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right column: UV/detail + icon on top, summary below
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(alignment: .top, spacing: 6) {
                                Spacer(minLength: 0)
                                VStack(alignment: .trailing, spacing: 2) {
                                    if data.isDay {
                                        if let sunsetLabel = data.sunsetLabel {
                                            MediumDetailLabel(
                                                icon: "sunset.fill",
                                                value: sunsetLabel
                                            )
                                        }
                                        MediumDetailLabel(
                                            icon: "sun.max.fill",
                                            value: "UV \(data.uvIndexMax ?? data.uvIndex) Max"
                                        )
                                    } else {
                                        if let sunriseLabel = data.sunriseLabel {
                                            MediumDetailLabel(
                                                icon: "sunrise.fill",
                                                value: sunriseLabel
                                            )
                                        }
                                        if let sfSymbol = data.moonPhaseSFSymbol,
                                           let illum = data.moonIllumination {
                                            MediumDetailLabel(
                                                icon: sfSymbol,
                                                value: "\(illum)%"
                                            )
                                        }
                                    }
                                }
                                WidgetConditionIcon(
                                    conditionName: data.conditionName,
                                    isDay: data.isDay,
                                    size: 32
                                )
                            }
                            if let summary = data.widgetSummary,
                               data.summaryIsDay == nil || data.summaryIsDay == data.isDay {
                                Text(summary)
                                    .font(.custom("Quicksand-Medium", size: 11))
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                    .opacity(0.95)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    Spacer(minLength: 4)

                    // Timeline Bar — full width
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
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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
                family: .systemMedium
            )
        }
    }

    // MARK: - Legacy Layout (fallback for old cached data)

    private var legacyLayout: some View {
        WidgetView() {
            ZStack(alignment: .bottomTrailing) {
                WeatherEffectOverlay(
                    conditionName: data.conditionName,
                    isDay: data.isDay,
                    scale: 0.8
                )

                Image("heather_logo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)
                    .foregroundStyle(.black)
                    .opacity(data.isDay ? 0.15 : 0.4)
                    .offset(x: 10, y: 16)

                VStack(alignment: .leading, spacing: 0) {

                    Text(data.cityName)
                        .font(.custom("Quicksand-Bold", size: 12))
                        .lineLimit(1)

                    HStack(alignment: .bottom, spacing: 6) {

                        Text("\(data.temperature)°")
                            .font(.custom("Poppins-Bold", size: 42))
                            .minimumScaleFactor(0.7)

                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(data.high)°/\(data.low)°")
                                .font(.custom("Quicksand-SemiBold", size: 15))
                                .opacity(0.9)

                            Text("Feels like \(data.feelsLike)°")
                                .font(.custom("Quicksand-Medium", size: 11))
                                .opacity(0.9)

                            Text(data.description.capitalized)
                                .font(.custom("Quicksand-Medium", size: 11))
                                .opacity(0.9)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 3) {
                            HStack(alignment: .bottom, spacing: 4) {
                                VStack(alignment: .trailing, spacing: 3) {
                                    if data.isDay {
                                        if let sunsetLabel = data.sunsetLabel {
                                            MediumDetailLabel(
                                                icon: "sunset.fill",
                                                value: sunsetLabel
                                            )
                                        }
                                        MediumDetailLabel(
                                            icon: "sun.max.fill",
                                            value: "UV \(data.uvIndexMax ?? data.uvIndex) Max"
                                        )
                                    } else {
                                        if let sunriseLabel = data.sunriseLabel {
                                            MediumDetailLabel(
                                                icon: "sunrise.fill",
                                                value: sunriseLabel
                                            )
                                        }
                                        if let sfSymbol = data.moonPhaseSFSymbol,
                                           let illum = data.moonIllumination {
                                            MediumDetailLabel(
                                                icon: sfSymbol,
                                                value: "\(illum)%"
                                            )
                                        }
                                    }
                                }
                                WidgetConditionIcon(
                                    conditionName: data.conditionName,
                                    isDay: data.isDay,
                                    size: 32
                                )
                            }
                            if let alertText = data.alertText {
                                MediumDetailLabel(
                                    icon: data.alertIcon,
                                    value: alertText,
                                    iconTint: data.alertColor
                                )
                            } else if let precipLabel = data.precipLabel {
                                MediumDetailLabel(
                                    icon: precipIcon(precipLabel),
                                    value: precipLabel
                                )
                            } else {
                                Spacer().frame(height: 14)
                            }
                        }
                    }

                    Spacer()

                    if let hours = data.hourly, !hours.isEmpty {
                        let items = Array(hours.prefix(6))
                        HStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, entry in
                                VStack(spacing: 1) {
                                    Text(entry.hourLabel)
                                        .font(.custom("Quicksand-Medium", size: 10))
                                        .opacity(0.9)
                                    WidgetConditionIcon(
                                        conditionName: entry.conditionName,
                                        isDay: entry.isDay ?? data.isDay,
                                        size: 24
                                    ).frame(height: 26)
                                    Text("\(entry.temperature)°")
                                        .font(.custom("Poppins-SemiBold", size: 11))
                                }
                                if index < items.count - 1 {
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
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
                family: .systemMedium
            )
        }
    }
}

private struct MediumDetailLabel: View {
    let icon: String
    let value: String
    var iconTint: Color? = nil

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .opacity(iconTint != nil ? 1.0 : 0.9)
                .foregroundStyle(iconTint ?? .white)
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 11))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .opacity(iconTint != nil ? 1.0 : 0.9)
                .foregroundStyle(.white)
        }
        .fixedSize()
    }
}
