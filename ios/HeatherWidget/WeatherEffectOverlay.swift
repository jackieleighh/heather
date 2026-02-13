import SwiftUI
import WidgetKit

struct WeatherEffectOverlay: View {
    let conditionName: String
    let isDay: Bool
    let scale: Double

    init(conditionName: String, isDay: Bool, scale: Double = 1.0) {
        self.conditionName = conditionName
        self.isDay = isDay
        self.scale = scale
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 4)) { context in
            let timeOffset = context.date.timeIntervalSince1970
            Canvas { ctx, size in
                drawEffect(ctx: ctx, size: size, time: timeOffset)
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Effect Router

    private func drawEffect(ctx: GraphicsContext, size: CGSize, time: Double) {
        switch conditionName {
        case "sunny":
            if isDay {
                drawSunGlow(ctx: ctx, size: size, time: time)
                drawSunRays(ctx: ctx, size: size, time: time)
            } else {
                drawStars(ctx: ctx, size: size, time: time, count: Int(30 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: time)
            }
        case "mostlySunny":
            if isDay {
                drawSunGlow(ctx: ctx, size: size, time: time, outerRadius: 70, innerRadius: 40, outerAlpha: 0.15, innerAlpha: 0.2)
                drawSunRays(ctx: ctx, size: size, time: time, count: 8, outerRadius: 90, opacity: 0.08)
                drawClouds(ctx: ctx, size: size, time: time, configs: [
                    CloudConfig(cx: 0.15, cy: 0.2, scale: 0.35, alpha: 0.25),
                    CloudConfig(cx: 0.6, cy: 0.5, scale: 0.30, alpha: 0.20),
                ])
            } else {
                drawStars(ctx: ctx, size: size, time: time, count: Int(25 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: time)
                drawClouds(ctx: ctx, size: size, time: time, configs: [
                    CloudConfig(cx: 0.3, cy: 0.35, scale: 0.30, alpha: 0.18),
                ])
            }
        case "partlyCloudy":
            if isDay {
                drawSunGlow(ctx: ctx, size: size, time: time, outerRadius: 60, innerRadius: 30, outerAlpha: 0.12, innerAlpha: 0.18)
                drawClouds(ctx: ctx, size: size, time: time, configs: [
                    CloudConfig(cx: 0.2, cy: 0.08, scale: 0.40, alpha: 0.32),
                    CloudConfig(cx: 0.65, cy: 0.22, scale: 0.45, alpha: 0.35),
                    CloudConfig(cx: 0.35, cy: 0.55, scale: 0.38, alpha: 0.28),
                ])
            } else {
                drawStars(ctx: ctx, size: size, time: time, count: Int(20 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: time)
                drawClouds(ctx: ctx, size: size, time: time, configs: [
                    CloudConfig(cx: 0.2, cy: 0.1, scale: 0.38, alpha: 0.28),
                    CloudConfig(cx: 0.6, cy: 0.25, scale: 0.42, alpha: 0.30),
                    CloudConfig(cx: 0.35, cy: 0.55, scale: 0.35, alpha: 0.24),
                ])
            }
        case "overcast":
            drawOvercast(ctx: ctx, size: size, time: time)
        case "foggy":
            drawFog(ctx: ctx, size: size, time: time)
        case "drizzle":
            drawRain(ctx: ctx, size: size, time: time, count: Int(40 * scale), lineLength: 8, strokeWidth: 0.6, maxOpacity: 0.25)
        case "rain":
            drawRain(ctx: ctx, size: size, time: time, count: Int(60 * scale), lineLength: 12, strokeWidth: 0.8, maxOpacity: 0.3)
        case "heavyRain":
            drawRain(ctx: ctx, size: size, time: time, count: Int(100 * scale), lineLength: 16, strokeWidth: 1.2, maxOpacity: 0.35)
        case "freezingRain":
            drawFreezingRain(ctx: ctx, size: size, time: time, count: Int(70 * scale))
        case "snow":
            drawSnow(ctx: ctx, size: size, time: time, count: Int(50 * scale))
        case "blizzard":
            drawSnow(ctx: ctx, size: size, time: time, count: Int(80 * scale), maxSize: 4.0)
            drawWhiteoutHaze(ctx: ctx, size: size, time: time)
        case "thunderstorm":
            drawRain(ctx: ctx, size: size, time: time, count: Int(80 * scale), lineLength: 15, strokeWidth: 1.0, maxOpacity: 0.3)
            drawLightningBolt(ctx: ctx, size: size, time: time)
        case "hail":
            drawHail(ctx: ctx, size: size, time: time, count: Int(50 * scale))
        default:
            break
        }
    }

    // MARK: - Sun Glow

    private func drawSunGlow(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        outerRadius: CGFloat = 90,
        innerRadius: CGFloat = 50,
        outerAlpha: Double = 0.2,
        innerAlpha: Double = 0.3
    ) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let pulse = sin(time * 0.8) * 0.03

        // Outer glow
        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 30))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - outerRadius,
                y: center.y - outerRadius,
                width: outerRadius * 2,
                height: outerRadius * 2
            )),
            with: .color(.white.opacity(outerAlpha + pulse))
        )

        // Inner glow
        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 15))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - innerRadius,
                y: center.y - innerRadius,
                width: innerRadius * 2,
                height: innerRadius * 2
            )),
            with: .color(.white.opacity(innerAlpha + pulse))
        )
    }

    // MARK: - Sun Rays

    private func drawSunRays(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        count: Int = 10,
        outerRadius: CGFloat = 120,
        opacity: Double = 0.12
    ) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let innerRadius: CGFloat = 50

        var rayCtx = ctx
        rayCtx.addFilter(.blur(radius: 4))

        for i in 0..<count {
            let fi = Double(i)
            let baseAngle = fi * .pi * 2 / Double(count)
            let angle = baseAngle + time * 0.1
            let rayOpacity = opacity + sin(time * 0.4 + fi * 1.5) * 0.04
            let outerR = outerRadius + CGFloat(sin(time * 0.5 + fi * 0.7) * 15)

            let cosA = CGFloat(cos(angle))
            let sinA = CGFloat(sin(angle))

            var path = Path()
            path.move(to: CGPoint(
                x: center.x + cosA * innerRadius,
                y: center.y + sinA * innerRadius
            ))
            path.addLine(to: CGPoint(
                x: center.x + cosA * outerR,
                y: center.y + sinA * outerR
            ))

            rayCtx.stroke(
                path,
                with: .color(.white.opacity(rayOpacity)),
                lineWidth: 3
            )
        }
    }

    // MARK: - Moon Glow

    private func drawMoonGlow(ctx: GraphicsContext, size: CGSize, time: Double) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)

        // Outer soft glow
        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 20))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 40,
                y: center.y - 40,
                width: 80,
                height: 80
            )),
            with: .color(.white.opacity(0.12))
        )

        // Inner glow
        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 8))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 20,
                y: center.y - 20,
                width: 40,
                height: 40
            )),
            with: .color(.white.opacity(0.3))
        )
    }

    // MARK: - Stars

    private func drawStars(ctx: GraphicsContext, size: CGSize, time: Double, count: Int) {
        var rng = SeededRNG(seed: 42)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height * 0.7
            let starSize = 0.5 + rng.nextDouble() * 2.0
            let twinkleSpeed = 0.5 + rng.nextDouble() * 2.0
            let phase = rng.nextDouble() * .pi * 2

            let twinkle = (sin(time * twinkleSpeed + phase) + 1) / 2
            let opacity = 0.1 + twinkle * 0.3
            let radius = starSize * (0.8 + twinkle * 0.2)

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(opacity))
            )
        }
    }

    // MARK: - Clouds

    private struct CloudConfig {
        let cx: Double
        let cy: Double
        let scale: Double
        let alpha: Double
    }

    private func drawClouds(ctx: GraphicsContext, size: CGSize, time: Double, configs: [CloudConfig]) {
        for (i, config) in configs.enumerated() {
            let drift = sin(time * (0.15 + Double(i) * 0.03) + Double(i) * 1.2) * 15
            let center = CGPoint(
                x: size.width * config.cx + drift,
                y: size.height * config.cy
            )
            let cloudScale = size.width * config.scale
            drawSingleCloud(ctx: ctx, center: center, scale: cloudScale, alpha: config.alpha)
        }
    }

    private func drawSingleCloud(ctx: GraphicsContext, center: CGPoint, scale: CGFloat, alpha: Double) {
        var cloudCtx = ctx
        cloudCtx.addFilter(.blur(radius: scale * 0.06))

        // Flat base oval
        cloudCtx.fill(
            Ellipse().path(in: CGRect(
                x: center.x - scale * 0.65,
                y: center.y + scale * 0.02,
                width: scale * 1.3,
                height: scale * 0.28
            )),
            with: .color(.white.opacity(alpha * 0.7))
        )

        // Left lobe
        let leftR = scale * 0.24
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scale * 0.25 - leftR,
                y: center.y - leftR,
                width: leftR * 2,
                height: leftR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        // Center lobe (tallest)
        let centerR = scale * 0.30
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - centerR,
                y: center.y - scale * 0.08 - centerR,
                width: centerR * 2,
                height: centerR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        // Right lobe
        let rightR = scale * 0.22
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x + scale * 0.28 - rightR,
                y: center.y + scale * 0.02 - rightR,
                width: rightR * 2,
                height: rightR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        // Top accent puff
        let topR = scale * 0.18
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x + scale * 0.04 - topR,
                y: center.y - scale * 0.20 - topR,
                width: topR * 2,
                height: topR * 2
            )),
            with: .color(.white.opacity(alpha * 0.85))
        )
    }

    // MARK: - Overcast

    private func drawOvercast(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height

        // Diffuse glow through cloud layer
        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 35))
        glowCtx.fill(
            Circle().path(in: CGRect(
                x: w * 0.75 - 60,
                y: h * 0.12 - 60,
                width: 120,
                height: 120
            )),
            with: .color(.white.opacity(0.10 + sin(time * 0.6) * 0.02))
        )

        // Haze blanket layers
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 40))

        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * -0.2 + sin(time * 0.15) * 20,
                y: h * 0.02,
                width: w * 1.4,
                height: h * 0.40
            )),
            with: .color(.white.opacity(0.18))
        )
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * -0.15 + sin(time * 0.12 + 2) * 15,
                y: h * 0.38,
                width: w * 1.3,
                height: h * 0.35
            )),
            with: .color(.white.opacity(0.15))
        )
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * -0.1 + sin(time * 0.18 + 4) * 12,
                y: h * 0.68,
                width: w * 1.2,
                height: h * 0.30
            )),
            with: .color(.white.opacity(0.12))
        )

        // Dense cloud ovals
        var cloudCtx = ctx
        cloudCtx.addFilter(.blur(radius: 30))

        let cloudLayers: [(cx: Double, cy: Double, w: Double, h: Double, a: Double, tMul: Double, tOff: Double)] = [
            (0.3, 0.10, 0.75, 0.16, 0.22, 0.25, 0),
            (0.7, 0.18, 0.70, 0.14, 0.24, 0.2, 1),
            (0.45, 0.32, 0.80, 0.15, 0.20, 0.3, 2),
            (0.55, 0.48, 0.75, 0.14, 0.18, 0.22, 3),
            (0.35, 0.62, 0.70, 0.13, 0.16, 0.28, 4),
        ]

        for layer in cloudLayers {
            let drift = sin(time * layer.tMul + layer.tOff) * 15
            cloudCtx.fill(
                Ellipse().path(in: CGRect(
                    x: w * layer.cx - w * layer.w / 2 + drift,
                    y: h * layer.cy - h * layer.h / 2,
                    width: w * layer.w,
                    height: h * layer.h
                )),
                with: .color(.white.opacity(layer.a))
            )
        }
    }

    // MARK: - Fog

    private func drawFog(ctx: GraphicsContext, size: CGSize, time: Double) {
        var fogCtx = ctx
        fogCtx.addFilter(.blur(radius: 40))

        for i in 0..<5 {
            let fi = Double(i)
            let yBase = size.height * (0.1 + fi * 0.18)
            let xOffset = sin(time * (0.5 + fi * 0.1) + fi) * 30
            let opacity = 0.04 + sin(time * 0.3 + fi * 0.8).magnitude * 0.03
            let bandHeight = 50.0 + sin(time + fi) * 10

            fogCtx.fill(
                RoundedRectangle(cornerRadius: 30).path(in: CGRect(
                    x: -size.width * 0.2 + xOffset,
                    y: yBase - bandHeight / 2,
                    width: size.width * 1.4,
                    height: bandHeight
                )),
                with: .color(.white.opacity(opacity))
            )
        }
    }

    // MARK: - Rain

    private func drawRain(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        count: Int,
        lineLength: CGFloat,
        strokeWidth: CGFloat,
        maxOpacity: Double
    ) {
        var rng = SeededRNG(seed: UInt64(time.truncatingRemainder(dividingBy: 10000) * 100))

        for _ in 0..<count {
            let x = rng.nextDouble() * (size.width + 20) - 10
            let y = rng.nextDouble() * (size.height + 20) - 10
            let opacity = 0.08 + rng.nextDouble() * maxOpacity
            let length = lineLength * (0.7 + rng.nextDouble() * 0.6)

            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 1, y: y + length))

            ctx.stroke(
                path,
                with: .color(.white.opacity(opacity)),
                lineWidth: strokeWidth
            )
        }
    }

    // MARK: - Freezing Rain

    private func drawFreezingRain(ctx: GraphicsContext, size: CGSize, time: Double, count: Int) {
        let icyBlue = Color(red: 0.69, green: 0.88, blue: 1.0)
        var rng = SeededRNG(seed: UInt64(time.truncatingRemainder(dividingBy: 10000) * 100))

        for i in 0..<count {
            let x = rng.nextDouble() * (size.width + 20) - 10
            let y = rng.nextDouble() * (size.height + 20) - 10
            let opacity = 0.08 + rng.nextDouble() * 0.25
            let length = 10.0 + rng.nextDouble() * 6
            let width = 0.8 + rng.nextDouble() * 1.2

            let color = i % 3 == 0 ? icyBlue : Color.white

            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + 0.6, y: y + length))

            ctx.stroke(
                path,
                with: .color(color.opacity(opacity)),
                lineWidth: width
            )
        }

        // Icy sheen overlay
        var sheenCtx = ctx
        sheenCtx.addFilter(.blur(radius: 50))
        let sheenOpacity = 0.03 + sin(time * 0.5) * 0.015
        sheenCtx.fill(
            Circle().path(in: CGRect(
                x: size.width * 0.05,
                y: size.height * 0.45,
                width: size.width * 0.7,
                height: size.width * 0.7
            )),
            with: .color(icyBlue.opacity(sheenOpacity))
        )
    }

    // MARK: - Snow

    private func drawSnow(ctx: GraphicsContext, size: CGSize, time: Double, count: Int? = nil, maxSize: Double = 3.0) {
        let particleCount = count ?? Int(50 * scale)
        var rng = SeededRNG(seed: UInt64(time.truncatingRemainder(dividingBy: 10000) * 100))

        for _ in 0..<particleCount {
            let baseX = rng.nextDouble() * size.width
            let y = rng.nextDouble() * (size.height + 10) - 5
            let flakeSize = 1.0 + rng.nextDouble() * maxSize
            let opacity = 0.1 + rng.nextDouble() * 0.3
            let wobblePhase = rng.nextDouble() * .pi * 2

            // Sine-wave wobble for drift appearance
            let x = baseX + sin(time * 1.5 + wobblePhase) * 5
            let radius = flakeSize / 2

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(opacity))
            )
        }
    }

    // MARK: - Whiteout Haze (Blizzard)

    private func drawWhiteoutHaze(ctx: GraphicsContext, size: CGSize, time: Double) {
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 50))
        let opacity = 0.04 + sin(time * 0.4) * 0.02
        hazeCtx.fill(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(.white.opacity(opacity))
        )
    }

    // MARK: - Lightning Bolt (Thunderstorm)

    private func drawLightningBolt(ctx: GraphicsContext, size: CGSize, time: Double) {
        // Static zigzag bolt shape in upper portion
        let startX = size.width * 0.35
        let startY = size.height * 0.05

        var bolt = Path()
        bolt.move(to: CGPoint(x: startX, y: startY))
        bolt.addLine(to: CGPoint(x: startX - 8, y: startY + size.height * 0.12))
        bolt.addLine(to: CGPoint(x: startX + 4, y: startY + size.height * 0.14))
        bolt.addLine(to: CGPoint(x: startX - 12, y: startY + size.height * 0.28))
        bolt.addLine(to: CGPoint(x: startX - 2, y: startY + size.height * 0.22))
        bolt.addLine(to: CGPoint(x: startX + 6, y: startY + size.height * 0.20))
        bolt.addLine(to: CGPoint(x: startX, y: startY))

        // Subtle glow bolt
        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 6))
        glowCtx.fill(bolt, with: .color(.white.opacity(0.08)))

        // Sharp bolt outline
        ctx.stroke(bolt, with: .color(.white.opacity(0.12)), lineWidth: 1)
    }

    // MARK: - Hail

    private func drawHail(ctx: GraphicsContext, size: CGSize, time: Double, count: Int) {
        var rng = SeededRNG(seed: UInt64(time.truncatingRemainder(dividingBy: 10000) * 100))

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * (size.height + 10) - 5
            let stoneSize = 2.0 + rng.nextDouble() * 3.5
            let opacity = 0.1 + rng.nextDouble() * 0.25
            let radius = stoneSize / 2

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(opacity))
            )
        }
    }
}

// MARK: - Seeded Random Number Generator

/// Deterministic RNG so particle positions are stable per widget refresh
/// but change on each timeline update.
private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }

    init(seed: Int) {
        self.init(seed: UInt64(bitPattern: Int64(seed)))
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func nextDouble() -> Double {
        return Double(next() % 10000) / 10000.0
    }
}
