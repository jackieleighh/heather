import SwiftUI

struct TimelineBarView: View {
    let segments: [TimelineSegment]
    let hasPrecip: Bool
    let isDay: Bool
    var entryDate: Date = Date()
    var utcOffsetSeconds: Int? = nil

    /// Clock-based labels at 3-hour intervals: "now", +3h, +6h, +9h, +12h
    private var timeLabels: [String] {
        var labels = ["now"]
        let tz = TimeZone(secondsFromGMT: utcOffsetSeconds ?? TimeZone.current.secondsFromGMT()) ?? .current
        var cal = Calendar.current
        cal.timeZone = tz
        for offset in [3, 6, 9, 12] {
            let future = cal.date(byAdding: .hour, value: offset, to: entryDate) ?? entryDate
            let hour = cal.component(.hour, from: future)
            let h12 = hour % 12 == 0 ? 12 : hour % 12
            let ampm = hour >= 12 ? "pm" : "am"
            labels.append("\(h12)\(ampm)")
        }
        return labels
    }

    var body: some View {
        VStack(spacing: 3) {
            if hasPrecip {
                precipitationBar
            } else {
                temperatureTrend
            }
            timeLabelsRow
        }
    }

    // MARK: - Precipitation Bar (matching Rain card bar graph)

    private var precipitationBar: some View {
        let labelW: CGFloat = 24
        let graphH: CGFloat = 32

        return HStack(alignment: .bottom, spacing: 0) {
            // Y-axis labels
            VStack(alignment: .trailing, spacing: 0) {
                Text("100%")
                    .font(.custom("Poppins-SemiBold", size: 8))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer(minLength: 0)
                Text("50%")
                    .font(.custom("Poppins-SemiBold", size: 8))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer(minLength: 0)
                Text("0%")
                    .font(.custom("Poppins-SemiBold", size: 8))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(width: labelW, height: graphH)

            // Bar graph area
            GeometryReader { geo in
                let probs = hourlyPrecipProbs
                let graphW = geo.size.width
                let slotW = graphW / CGFloat(probs.count)
                let gap: CGFloat = 1.5
                let barW = max(slotW - gap, 1)

                ZStack(alignment: .bottomLeading) {
                    // Grid line at 50%
                    Path { path in
                        let y = graphH * 0.5
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: graphW, y: y))
                    }
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)

                    // Bars
                    HStack(spacing: 0) {
                        ForEach(Array(probs.enumerated()), id: \.offset) { _, prob in
                            let pct = Double(prob) / 100.0
                            let barH = max(graphH * pct, pct > 0 ? 2 : 0)
                            VStack {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(.white.opacity(0.45 + 0.45 * pct))
                                    .frame(width: barW, height: barH)
                            }
                            .frame(width: slotW)
                        }
                    }

                    // "Now" indicator — vertical line at first bar position
                    Path { path in
                        let x = slotW / 2
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: graphH))
                    }
                    .stroke(.white.opacity(0.5), lineWidth: 1)
                }
            }
            .frame(height: graphH)
        }
        .frame(height: graphH)
    }

    /// Sample precipitation probability at hourly intervals across 12 hours.
    private var hourlyPrecipProbs: [Int] {
        let targetMinutes = Array(stride(from: 0, through: 720, by: 60))
        return targetMinutes.map { target in
            let closest = segments.min(by: {
                abs($0.minuteOffset - target) < abs($1.minuteOffset - target)
            })
            return closest?.precipProbability ?? 0
        }
    }

    // MARK: - Temperature Trend

    private var temperatureTrend: some View {
        GeometryReader { geo in
            let temps = hourlyTemps
            if temps.count >= 2 {
                let minTemp = Double(temps.min() ?? 0)
                let maxTemp = Double(temps.max() ?? 100)
                let range = max(maxTemp - minTemp, 1)
                let height = geo.size.height

                let points: [CGPoint] = temps.enumerated().map { i, temp in
                    let x = geo.size.width * Double(i) / Double(temps.count - 1)
                    let y = height - ((Double(temp) - minTemp) / range) * height * 0.7 - height * 0.15
                    return CGPoint(x: x, y: y)
                }

                // Smooth cubic Bezier curve (matching Temp card style)
                Path { path in
                    path.move(to: points[0])
                    for i in 1..<points.count {
                        let cpx = (points[i - 1].x + points[i].x) / 2
                        path.addCurve(
                            to: points[i],
                            control1: CGPoint(x: cpx, y: points[i - 1].y),
                            control2: CGPoint(x: cpx, y: points[i].y)
                        )
                    }
                }
                .stroke(.white.opacity(0.6), lineWidth: 1.5)

                // "Now" dot at the first point
                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .position(x: points[0].x, y: points[0].y)

                // Temp labels at key points (every 3 hours to match time labels)
                ForEach(Array(temps.enumerated()), id: \.offset) { i, temp in
                    Text("\(temp)°")
                        .font(.custom("Poppins-SemiBold", size: 9))
                        .foregroundStyle(.white.opacity(0.9))
                        .position(x: points[i].x, y: points[i].y - 10)
                }
            }
        }
        .frame(height: 32)
    }

    /// Extracts temperatures at 3-hour intervals for the trend line (5 points across 12 hours).
    private var hourlyTemps: [Int] {
        let targetMinutes = [0, 180, 360, 540, 720]
        return targetMinutes.compactMap { target in
            let closest = segments.min(by: {
                abs($0.minuteOffset - target) < abs($1.minuteOffset - target)
            })
            return closest?.temperature
        }
    }

    // MARK: - Time Labels

    private var timeLabelsRow: some View {
        HStack {
            ForEach(Array(timeLabels.enumerated()), id: \.offset) { i, label in
                Text(label)
                    .font(.custom("Quicksand-Medium", size: 9))
                    .opacity(0.6)
                if i < timeLabels.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
    }
}
