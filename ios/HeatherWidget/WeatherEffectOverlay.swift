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
        Canvas { ctx, size in
            drawEffect(ctx: ctx, size: size, time: 0)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Effect Router

    private func drawEffect(ctx: GraphicsContext, size: CGSize, time: Double) {
        // Normalize time to avoid floating point precision issues with large epoch values
        let t = time.truncatingRemainder(dividingBy: 100000)

        switch conditionName {
        case "sunny":
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t)
                drawSunGlowRadial(ctx: ctx, size: size, time: t)
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(80 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
            }
        case "mostlySunny":
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t, lengthScale: 0.78, alphaScale: 0.8)
                drawSunGlowRadial(ctx: ctx, size: size, time: t, outerRadius: 110, innerRadius: 45, outerAlpha: 0.45, innerAlpha: 0.60)
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.15, cy: 0.30, scale: 0.38, alpha: 0.30, speed: 0.06),
                    CloudConfig(cx: 0.58, cy: 0.38, scale: 0.42, alpha: 0.28, speed: 0.04),
                    CloudConfig(cx: 0.30, cy: 0.62, scale: 0.35, alpha: 0.22, speed: 0.05),
                ])
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(80 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.15, cy: 0.30, scale: 0.38, alpha: 0.30, speed: 0.04),
                    CloudConfig(cx: 0.58, cy: 0.38, scale: 0.42, alpha: 0.28, speed: 0.03),
                    CloudConfig(cx: 0.30, cy: 0.62, scale: 0.35, alpha: 0.22, speed: 0.035),
                ])
            }
        case "partlyCloudy":
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t, lengthScale: 0.62, alphaScale: 0.65)
                drawSunGlowRadial(ctx: ctx, size: size, time: t, outerRadius: 90, innerRadius: 35, outerAlpha: 0.35, innerAlpha: 0.50)
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.20, cy: 0.08, scale: 0.40, alpha: 0.35, speed: 0.05),
                    CloudConfig(cx: 0.65, cy: 0.20, scale: 0.48, alpha: 0.38, speed: 0.035),
                    CloudConfig(cx: 0.10, cy: 0.38, scale: 0.42, alpha: 0.32, speed: 0.06),
                    CloudConfig(cx: 0.75, cy: 0.55, scale: 0.36, alpha: 0.28, speed: 0.045),
                    CloudConfig(cx: 0.40, cy: 0.72, scale: 0.34, alpha: 0.24, speed: 0.055),
                ])
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(80 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.2, cy: 0.1, scale: 0.38, alpha: 0.28, speed: 0.05),
                    CloudConfig(cx: 0.6, cy: 0.25, scale: 0.42, alpha: 0.30, speed: 0.035),
                    CloudConfig(cx: 0.35, cy: 0.55, scale: 0.35, alpha: 0.24, speed: 0.045),
                ])
            }
        case "overcast":
            drawOvercast(ctx: ctx, size: size, time: t)
        case "foggy":
            drawFog(ctx: ctx, size: size, time: t)
        case "drizzle", "rain", "heavyRain", "freezingRain",
             "snow", "blizzard":
            break
        case "thunderstorm", "hail":
            drawLightningFlash(ctx: ctx, size: size, time: t)
        default:
            break
        }
    }

    // MARK: - Sun Rays (Wedge-shaped with gradient, matching app)

    private func drawSunRaysWedge(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        lengthScale: Double = 1.0,
        alphaScale: Double = 1.0
    ) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0
        let spin = time * 0.08

        // Matching app's ray parameters
        let rayAngles: [Double] =  [0.0, 0.55, 1.05, 1.6, 2.15, 2.65, 3.2, 3.75, 4.3, 4.85, 5.35, 5.9]
        let rayLengths: [Double] = [380, 240, 320, 200, 360, 260, 340, 220, 300, 250, 350, 230]
        let raySpreads: [Double] = [0.06, 0.04, 0.055, 0.035, 0.06, 0.045, 0.055, 0.04, 0.05, 0.04, 0.06, 0.035]
        let rayAlphas: [Double] =  [0.40, 0.25, 0.35, 0.20, 0.38, 0.28, 0.33, 0.22, 0.30, 0.24, 0.37, 0.18]
        let innerR: Double = 25 * szScale

        var rayCtx = ctx
        rayCtx.addFilter(.blur(radius: 6 * szScale))

        for i in 0..<rayAngles.count {
            let angle = rayAngles[i] + spin
            let outerR = rayLengths[i] * szScale * lengthScale
            let halfSpread = raySpreads[i]
            let alpha = (rayAlphas[i] + sin(time * 0.5 + Double(i) * 0.7).magnitude * 0.05) * alphaScale

            let cosA = cos(angle)
            let sinA = sin(angle)
            let cosL = cos(angle - halfSpread)
            let sinL = sin(angle - halfSpread)
            let cosR = cos(angle + halfSpread)
            let sinR = sin(angle + halfSpread)

            var path = Path()
            path.move(to: CGPoint(
                x: center.x + CGFloat(cosL * innerR),
                y: center.y + CGFloat(sinL * innerR)
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cosL * outerR),
                y: center.y + CGFloat(sinL * outerR)
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cosR * outerR),
                y: center.y + CGFloat(sinR * outerR)
            ))
            path.addLine(to: CGPoint(
                x: center.x + CGFloat(cosR * innerR),
                y: center.y + CGFloat(sinR * innerR)
            ))
            path.closeSubpath()

            let startPt = CGPoint(
                x: center.x + CGFloat(cosA * innerR),
                y: center.y + CGFloat(sinA * innerR)
            )
            let endPt = CGPoint(
                x: center.x + CGFloat(cosA * outerR),
                y: center.y + CGFloat(sinA * outerR)
            )

            rayCtx.fill(
                path,
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: .white.opacity(alpha), location: 0),
                        .init(color: .white.opacity(0), location: 1),
                    ]),
                    startPoint: startPt,
                    endPoint: endPt
                )
            )
        }
    }

    // MARK: - Sun Glow (Radial gradient, matching app)

    private func drawSunGlowRadial(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        outerRadius: CGFloat = 130,
        innerRadius: CGFloat = 55,
        outerAlpha: Double = 0.55,
        innerAlpha: Double = 0.70
    ) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0
        let scaledOuter = outerRadius * szScale
        let scaledInner = innerRadius * szScale

        // Outer glow
        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 40 * szScale))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scaledOuter,
                y: center.y - scaledOuter,
                width: scaledOuter * 2,
                height: scaledOuter * 2
            )),
            with: .color(.white.opacity(outerAlpha * 0.4 + sin(time * 0.8) * 0.03))
        )

        // Bright core
        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 20 * szScale))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scaledInner,
                y: center.y - scaledInner,
                width: scaledInner * 2,
                height: scaledInner * 2
            )),
            with: .color(.white.opacity(innerAlpha + sin(time * 0.8) * 0.03))
        )
    }

    // MARK: - Moon Glow

    private func drawMoonGlow(ctx: GraphicsContext, size: CGSize, time: Double) {
        let center = CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0

        // Outer soft glow
        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 25 * szScale))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 50 * szScale,
                y: center.y - 50 * szScale,
                width: 100 * szScale,
                height: 100 * szScale
            )),
            with: .color(.white.opacity(0.15))
        )

        // Inner glow
        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 8 * szScale))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 25 * szScale,
                y: center.y - 25 * szScale,
                width: 50 * szScale,
                height: 50 * szScale
            )),
            with: .color(.white.opacity(0.4))
        )
    }

    // MARK: - Stars

    private func drawStars(ctx: GraphicsContext, size: CGSize, time: Double, count: Int) {
        var rng = SeededRNG(seed: 42)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height * 0.7
            let starSize = 0.5 + rng.nextDouble() * 2.5
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

    // MARK: - Clouds (Drifting with wrap-around, matching app)

    private struct CloudConfig {
        let cx: Double
        let cy: Double
        let scale: Double
        let alpha: Double
        let speed: Double
    }

    private func drawClouds(ctx: GraphicsContext, size: CGSize, time: Double, configs: [CloudConfig]) {
        for (i, config) in configs.enumerated() {
            let cloudScale = size.width * config.scale

            // Continuous horizontal drift with wrap-around (matching app)
            let totalWidth = size.width + cloudScale * 1.5
            let rawX = (config.cx * size.width + time * size.width * config.speed)
                .truncatingRemainder(dividingBy: totalWidth) - cloudScale * 0.75
            let wobble = sin(time * 0.3 + config.cx * 10) * 8
            let center = CGPoint(x: rawX, y: size.height * config.cy + wobble)

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
                y: center.y + scale * 0.10,
                width: scale * 1.3,
                height: scale * 0.28
            )),
            with: .color(.white.opacity(alpha * 0.7))
        )

        // Main lobes
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
            with: .color(.white.opacity(alpha * 0.8))
        )
    }

    // MARK: - Overcast

    private func drawOvercast(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height

        // Soft sun glow through cloud layer (matching app)
        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 70))
        glowCtx.fill(
            Circle().path(in: CGRect(
                x: w * 0.7 - 60,
                y: h * 0.08 - 60,
                width: 120,
                height: 120
            )),
            with: .color(.white.opacity(0.15 + sin(time * 0.4) * 0.03))
        )

        // Drifting cloud masses with blob-based rendering (matching app)
        // App uses 6 masses with 7-13 blobs each, blur proportional to scale
        let massParams: [(yFrac: Double, scale: Double, speed: Double, alpha: Double, startX: Double, wobblePhase: Double)] = [
            (0.08, 0.55, 0.14, 0.18, 0.3, 0.0),
            (0.22, 0.50, 0.18, 0.16, 0.7, 1.2),
            (0.38, 0.48, 0.26, 0.14, 0.45, 2.4),
            (0.52, 0.52, 0.16, 0.13, 0.55, 3.6),
            (0.66, 0.45, 0.28, 0.12, 0.35, 4.8),
            (0.80, 0.42, 0.20, 0.10, 0.60, 6.0),
        ]

        var rng = SeededRNG(seed: 88)

        for mass in massParams {
            let massScale = w * mass.scale
            let blurRadius = massScale * 0.12

            // Continuous horizontal drift with wrap-around
            let totalWidth = w * 2.2
            let raw = mass.startX * w + time * mass.speed * w
            let xNorm = (raw.truncatingRemainder(dividingBy: totalWidth)) / totalWidth
            let centerX = (xNorm * 2.2 - 0.6) * w
            let wobble = sin(time * 0.5 + mass.wobblePhase) * h * 0.012
            let centerY = h * mass.yFrac + wobble

            var cloudCtx = ctx
            cloudCtx.addFilter(.blur(radius: blurRadius))

            // Draw 8-10 blobs per mass (matching app's blob-based approach)
            let blobCount = 8 + Int(rng.nextDouble() * 3)
            for _ in 0..<blobCount {
                let dx = (rng.nextDouble() - 0.5) * 1.4
                let dy = (rng.nextDouble() - 0.5) * 0.6
                let blobRadius = (0.14 + rng.nextDouble() * 0.20) * massScale

                cloudCtx.fill(
                    Circle().path(in: CGRect(
                        x: centerX + dx * massScale - blobRadius,
                        y: centerY + dy * massScale - blobRadius,
                        width: blobRadius * 2,
                        height: blobRadius * 2
                    )),
                    with: .color(.white.opacity(mass.alpha))
                )
            }
        }

        // Very subtle haze overlay (matching app's 0.03 alpha)
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 100))

        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 1.0,
                y: h * 0.25 - h * 0.25,
                width: w * 2.0,
                height: h * 0.5
            )),
            with: .color(.white.opacity(0.03 + sin(time * 0.15) * 0.01))
        )

        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 0.9,
                y: h * 0.65 - h * 0.2,
                width: w * 1.8,
                height: h * 0.4
            )),
            with: .color(.white.opacity(0.02 + sin(time * 0.12 + 2.0) * 0.01))
        )
    }

    // MARK: - Fog

    private func drawFog(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height

        // Atmospheric haze base layers (matching app)
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 80))

        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 1.1,
                y: h * 0.3 - h * 0.35,
                width: w * 2.2,
                height: h * 0.7
            )),
            with: .color(.white.opacity(0.12 + sin(time * 0.2) * 0.03))
        )
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 0.9,
                y: h * 0.7 - h * 0.25,
                width: w * 1.8,
                height: h * 0.5
            )),
            with: .color(.white.opacity(0.10 + sin(time * 0.15 + 1.5) * 0.02))
        )

        // 14 fog wisps (matching app)
        var rng = SeededRNG(seed: 77)

        for i in 0..<14 {
            let fi = Double(i)
            let yRaw = rng.nextDouble()
            let yBiased = yRaw * yRaw
            let yFraction = 0.05 + yBiased * 0.85
            let bandHeight = 50.0 + rng.nextDouble() * 70.0
            let speed = 0.08 + rng.nextDouble() * 0.14
            let wispWidth = 0.4 + rng.nextDouble() * 0.6
            let blur = bandHeight * 0.16 + rng.nextDouble() * 6
            let baseAlpha = 0.13 + rng.nextDouble() * 0.12
            let startX = rng.nextDouble() * 2.4
            let wobblePhase = rng.nextDouble() * .pi * 2

            // Continuous horizontal drift with wrap-around (matching app)
            let raw = startX + time * speed
            let xNorm = (raw.truncatingRemainder(dividingBy: 2.4)) - 1.0
            let x = xNorm * w
            let wobble = sin(time * 0.7 + wobblePhase) * h * 0.012
            let y = h * yFraction + wobble
            let opacity = baseAlpha

            var fogCtx = ctx
            fogCtx.addFilter(.blur(radius: blur))
            fogCtx.fill(
                Ellipse().path(in: CGRect(
                    x: x - wispWidth * w / 2,
                    y: y - bandHeight / 2,
                    width: wispWidth * w,
                    height: bandHeight
                )),
                with: .color(.white.opacity(opacity))
            )
        }
    }

    // MARK: - Lightning Flash (Thunderstorm / Hail)

    private func drawLightningFlash(ctx: GraphicsContext, size: CGSize, time: Double) {
        let cycle = time.truncatingRemainder(dividingBy: 4.5)
        guard cycle < 0.3 else { return }

        let flashOpacity = 0.15 * (1.0 - cycle / 0.3)
        ctx.fill(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(.white.opacity(flashOpacity))
        )
    }

}

// MARK: - Seeded Random Number Generator

/// Deterministic RNG so particle positions are stable across widget refreshes.
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
