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
        let t = time.truncatingRemainder(dividingBy: 100000)

        switch conditionName {
        case "sunny":
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t)
                drawSunGlowRadial(ctx: ctx, size: size, time: t)
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(50 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
            }
        case "mostlySunny":
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t, lengthScale: 0.78, alphaScale: 0.8)
                drawSunGlowRadial(ctx: ctx, size: size, time: t, outerRadius: 80, innerRadius: 32, outerAlpha: 0.32, innerAlpha: 0.42)
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(50 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
            }
        case "partlyCloudy":
            let pcCenter = CGPoint(x: size.width * 0.75, y: size.height * 0.12)
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t, lengthScale: 0.54, alphaScale: 0.65, sunCenter: pcCenter)
                drawSunGlowRadial(ctx: ctx, size: size, time: t, outerRadius: 65, innerRadius: 25, outerAlpha: 0.28, innerAlpha: 0.36, sunCenter: pcCenter)
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(50 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t, moonCenter: pcCenter)
            }
            drawTopDarkeningBand(ctx: ctx, size: size)
        case "overcast":
            drawOvercast(ctx: ctx, size: size, time: t)
        case "foggy":
            drawFog(ctx: ctx, size: size, time: t)
        case "drizzle":
            drawDrizzleDots(ctx: ctx, size: size, count: Int(12 * scale))
        case "rain":
            drawRainStreaks(ctx: ctx, size: size, count: Int(20 * scale), minAlpha: 0.10, maxAlpha: 0.20, strokeWidth: 0.5, angle: 0.22, lengthRange: 6...10)
        case "heavyRain":
            drawRainStreaks(ctx: ctx, size: size, count: Int(30 * scale), minAlpha: 0.10, maxAlpha: 0.20, strokeWidth: 0.6, angle: 0.28, lengthRange: 8...14)
            drawBottomHaze(ctx: ctx, size: size, opacity: 0.05)
        case "freezingRain":
            drawFreezingRain(ctx: ctx, size: size, count: Int(18 * scale))
        case "snow":
            drawSnowDots(ctx: ctx, size: size, count: Int(25 * scale), minAlpha: 0.14, maxAlpha: 0.22, radiusRange: 1.0...2.5)
            drawDarkOverlay(ctx: ctx, size: size, opacity: 0.10)
        case "blizzard":
            drawSnowDots(ctx: ctx, size: size, count: Int(40 * scale), minAlpha: 0.16, maxAlpha: 0.35, radiusRange: 1.0...3.0)
            drawWhiteHaze(ctx: ctx, size: size, opacity: 0.03)
            drawDarkOverlay(ctx: ctx, size: size, opacity: 0.10)
        case "thunderstorm":
            drawRainStreaks(ctx: ctx, size: size, count: Int(25 * scale), minAlpha: 0.10, maxAlpha: 0.20, strokeWidth: 0.5, angle: 0.22, lengthRange: 6...10)
            drawSubtleLightningGlow(ctx: ctx, size: size, opacity: 0.06)
        case "hail":
            drawHailStones(ctx: ctx, size: size, count: Int(25 * scale))
            drawSubtleLightningGlow(ctx: ctx, size: size, opacity: 0.05)
        default:
            break
        }
    }

    // MARK: - Sun Rays (Mini wedge-shaped)

    private func drawSunRaysWedge(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        lengthScale: Double = 1.0,
        alphaScale: Double = 1.0,
        sunCenter: CGPoint? = nil
    ) {
        let center = sunCenter ?? CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0
        let spin = time * 0.15

        let rayAngles: [Double] =  [0.0, 0.63, 1.26, 1.88, 2.51, 3.14, 3.77, 4.40, 5.03, 5.65]
        let rayLengths: [Double] = [240, 160, 220, 140, 230, 170, 210, 150, 200, 165]
        let raySpreads: [Double] = [0.05, 0.035, 0.048, 0.03, 0.05, 0.038, 0.045, 0.035, 0.042, 0.035]
        let rayAlphas: [Double] =  [0.25, 0.16, 0.22, 0.13, 0.24, 0.18, 0.20, 0.14, 0.19, 0.15]
        let innerR: Double = 18 * szScale

        var rayCtx = ctx
        rayCtx.addFilter(.blur(radius: 5 * szScale))

        for i in 0..<rayAngles.count {
            let angle = rayAngles[i] + spin
            let outerR = rayLengths[i] * szScale * lengthScale
            let halfSpread = raySpreads[i]
            let alpha = rayAlphas[i] * alphaScale

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

    // MARK: - Sun Glow (Mini radial)

    private func drawSunGlowRadial(
        ctx: GraphicsContext,
        size: CGSize,
        time: Double,
        outerRadius: CGFloat = 90,
        innerRadius: CGFloat = 38,
        outerAlpha: Double = 0.38,
        innerAlpha: Double = 0.50,
        sunCenter: CGPoint? = nil
    ) {
        let center = sunCenter ?? CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0
        let scaledOuter = outerRadius * szScale
        let scaledInner = innerRadius * szScale

        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 28 * szScale))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scaledOuter,
                y: center.y - scaledOuter,
                width: scaledOuter * 2,
                height: scaledOuter * 2
            )),
            with: .color(.white.opacity(outerAlpha * 0.4))
        )

        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 14 * szScale))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scaledInner,
                y: center.y - scaledInner,
                width: scaledInner * 2,
                height: scaledInner * 2
            )),
            with: .color(.white.opacity(innerAlpha))
        )

        // Bright core (matches Flutter's 55px core)
        let coreR = 22 * szScale
        var coreCtx = ctx
        coreCtx.addFilter(.blur(radius: 8 * szScale))
        coreCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - coreR,
                y: center.y - coreR,
                width: coreR * 2,
                height: coreR * 2
            )),
            with: .color(.white.opacity(0.55))
        )
    }

    // MARK: - Moon Glow (Mini)

    private func drawMoonGlow(ctx: GraphicsContext, size: CGSize, time: Double, moonCenter: CGPoint? = nil) {
        let center = moonCenter ?? CGPoint(x: size.width * 0.8, y: size.height * 0.12)
        let szScale = min(size.width, size.height) / 400.0

        var outerCtx = ctx
        outerCtx.addFilter(.blur(radius: 18 * szScale))
        outerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 36 * szScale,
                y: center.y - 36 * szScale,
                width: 72 * szScale,
                height: 72 * szScale
            )),
            with: .color(.white.opacity(0.12))
        )

        var innerCtx = ctx
        innerCtx.addFilter(.blur(radius: 6 * szScale))
        innerCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - 18 * szScale,
                y: center.y - 18 * szScale,
                width: 36 * szScale,
                height: 36 * szScale
            )),
            with: .color(.white.opacity(0.28))
        )
    }

    // MARK: - Stars (Fewer, fainter)

    private func drawStars(ctx: GraphicsContext, size: CGSize, time: Double, count: Int) {
        var rng = SeededRNG(seed: 42)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height * 0.7
            let starSize = 0.5 + rng.nextDouble() * 2.0
            let phase = rng.nextDouble() * .pi * 2

            let twinkle = (sin(phase) + 1) / 2
            let opacity = 0.08 + twinkle * 0.17
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

    // MARK: - Top Darkening Band (Partly cloudy cloud hint)

    private func drawTopDarkeningBand(ctx: GraphicsContext, size: CGSize) {
        let szScale = min(size.width, size.height) / 400.0
        var bandCtx = ctx
        bandCtx.addFilter(.blur(radius: 30 * szScale))
        bandCtx.fill(
            Ellipse().path(in: CGRect(
                x: size.width * 0.5 - size.width * 0.7,
                y: -size.height * 0.075,
                width: size.width * 1.4,
                height: size.height * 0.15
            )),
            with: .color(.black.opacity(0.06))
        )
    }

    // MARK: - Overcast Cloud Masses (matches Flutter overcast_background.dart)

    private func drawOvercastCloudBlobs(ctx: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        var rng = SeededRNG(seed: 88)

        // 6 cloud masses matching the app's parameters:
        // (xFraction, yFraction, scale, alpha)
        // x positions pushed toward edges so blobs don't sit on center text
        let masses: [(xFrac: Double, yFrac: Double, scale: Double, alpha: Double)] = [
            (0.15, 0.06,  0.55, 0.16),  // top-left
            (0.85, 0.20,  0.50, 0.14),  // upper-right
            (0.10, 0.38,  0.48, 0.13),  // mid-left
            (0.90, 0.52,  0.52, 0.12),  // mid-right
            (0.20, 0.68,  0.46, 0.11),  // lower-left
            (0.80, 0.82,  0.50, 0.12),  // lower-right
        ]

        for mass in masses {
            let scale = w * mass.scale
            let blurR = scale * 0.12
            let centerX = w * mass.xFrac
            let centerY = h * mass.yFrac
            let blobCount = 10 + Int(rng.nextDouble() * 6) // 10-15 blobs per mass

            var blobCtx = ctx
            blobCtx.addFilter(.blur(radius: blurR))

            for _ in 0..<blobCount {
                let dx = (rng.nextDouble() - 0.5) * 1.8
                let dy = (rng.nextDouble() - 0.5) * 0.8
                let blobRadius = (0.16 + rng.nextDouble() * 0.22) * scale

                let bx = centerX + dx * scale
                let by = centerY + dy * scale

                blobCtx.fill(
                    Circle().path(in: CGRect(
                        x: bx - blobRadius,
                        y: by - blobRadius,
                        width: blobRadius * 2,
                        height: blobRadius * 2
                    )),
                    with: .color(.white.opacity(mass.alpha))
                )
            }
        }
    }

    // MARK: - Drizzle Dots (Scattered mist circles)

    private func drawDrizzleDots(ctx: GraphicsContext, size: CGSize, count: Int) {
        var rng = SeededRNG(seed: 55)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height
            let radius = 0.8 + rng.nextDouble() * 0.4
            let alpha = 0.08 + rng.nextDouble() * 0.08

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(alpha))
            )
        }
    }

    // MARK: - Overcast (Cloud blobs + haze)

    private func drawOvercast(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height
        let szScale = min(w, h) / 400.0

        // Soft sun glow high up
        let glowR = 70.0 * szScale
        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 50 * szScale))
        glowCtx.fill(
            Circle().path(in: CGRect(
                x: w * 0.8 - glowR,
                y: h * 0.12 - glowR,
                width: glowR * 2,
                height: glowR * 2
            )),
            with: .color(.white.opacity(0.16))
        )

        // Cloud blobs at edges/corners
        drawOvercastCloudBlobs(ctx: ctx, size: size)

        // Upper haze
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 100 * szScale))
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 1.0,
                y: h * 0.25 - h * 0.25,
                width: w * 2.0,
                height: h * 0.5
            )),
            with: .color(.white.opacity(0.04))
        )

        // Lower haze
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 0.9,
                y: h * 0.65 - h * 0.2,
                width: w * 1.8,
                height: h * 0.4
            )),
            with: .color(.white.opacity(0.03))
        )
    }

    // MARK: - Fog (Fewer wisps, fainter)

    private func drawFog(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height
        let szScale = min(w, h) / 400.0

        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 100 * szScale))
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 0.8,
                y: h * 0.25 - h * 0.2,
                width: w * 1.6,
                height: h * 0.4
            )),
            with: .color(.white.opacity(0.022))
        )

        var rng = SeededRNG(seed: 77)

        for _ in 0..<5 {
            let yRaw = rng.nextDouble()
            let yBiased = yRaw * yRaw
            let yFraction = 0.05 + yBiased * 0.85
            let bandHeight = (50.0 + rng.nextDouble() * 70.0) * szScale
            let speed = 0.08 + rng.nextDouble() * 0.14
            let wispWidth = 0.3 + rng.nextDouble() * 0.3
            let blur = bandHeight * 0.16 + rng.nextDouble() * 6
            let baseAlpha = 0.04 + rng.nextDouble() * 0.04
            let startX = rng.nextDouble() * 2.4
            let wobblePhase = rng.nextDouble() * .pi * 2

            let raw = startX + time * speed
            let xNorm = (raw.truncatingRemainder(dividingBy: 2.4)) - 1.0
            let x = xNorm * w
            let wobble = sin(time * 0.7 + wobblePhase) * h * 0.008
            let y = h * yFraction + wobble

            var fogCtx = ctx
            fogCtx.addFilter(.blur(radius: blur))
            fogCtx.fill(
                Ellipse().path(in: CGRect(
                    x: x - wispWidth * w / 2,
                    y: y - bandHeight / 2,
                    width: wispWidth * w,
                    height: bandHeight
                )),
                with: .color(.white.opacity(baseAlpha))
            )
        }
    }

    // MARK: - Rain Streaks (Static diagonal lines)

    private func drawRainStreaks(
        ctx: GraphicsContext,
        size: CGSize,
        count: Int,
        minAlpha: Double,
        maxAlpha: Double,
        strokeWidth: CGFloat,
        angle: Double,
        lengthRange: ClosedRange<Double>
    ) {
        var rng = SeededRNG(seed: 55)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height
            let length = lengthRange.lowerBound + rng.nextDouble() * (lengthRange.upperBound - lengthRange.lowerBound)
            let alpha = minAlpha + rng.nextDouble() * (maxAlpha - minAlpha)

            let dx = sin(angle) * length
            let dy = cos(angle) * length

            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + dx, y: y + dy))

            ctx.stroke(
                path,
                with: .color(.white.opacity(alpha)),
                lineWidth: strokeWidth
            )
        }
    }

    // MARK: - Bottom Haze (Heavy rain ground mist)

    private func drawBottomHaze(ctx: GraphicsContext, size: CGSize, opacity: Double) {
        let szScale = min(size.width, size.height) / 400.0
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 30 * szScale))
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: -size.width * 0.1,
                y: size.height * 0.75,
                width: size.width * 1.2,
                height: size.height * 0.35
            )),
            with: .color(.white.opacity(opacity))
        )
    }

    // MARK: - Freezing Rain (Alternating white/icy-blue streaks + sheen)

    private func drawFreezingRain(ctx: GraphicsContext, size: CGSize, count: Int) {
        var rng = SeededRNG(seed: 63)
        let icyBlue = Color(red: 0.69, green: 0.88, blue: 1.0) // 0xB0E0FF

        for i in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height
            let length = 6.0 + rng.nextDouble() * 4.0
            let alpha = 0.12 + rng.nextDouble() * 0.08
            let angle = 0.20

            let dx = sin(angle) * length
            let dy = cos(angle) * length

            let color = (i % 2 == 0) ? Color.white : icyBlue

            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + dx, y: y + dy))

            ctx.stroke(
                path,
                with: .color(color.opacity(alpha)),
                lineWidth: 0.7
            )
        }

        // Icy sheen circle
        let szScale = min(size.width, size.height) / 400.0
        var sheenCtx = ctx
        sheenCtx.addFilter(.blur(radius: 40 * szScale))
        sheenCtx.fill(
            Circle().path(in: CGRect(
                x: size.width * 0.3,
                y: size.height * 0.4,
                width: size.width * 0.4,
                height: size.width * 0.4
            )),
            with: .color(icyBlue.opacity(0.05))
        )
    }

    // MARK: - Snow Dots (Static scattered dots)

    private func drawSnowDots(
        ctx: GraphicsContext,
        size: CGSize,
        count: Int,
        minAlpha: Double,
        maxAlpha: Double,
        radiusRange: ClosedRange<Double>
    ) {
        var rng = SeededRNG(seed: 71)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height
            let radius = radiusRange.lowerBound + rng.nextDouble() * (radiusRange.upperBound - radiusRange.lowerBound)
            let alpha = minAlpha + rng.nextDouble() * (maxAlpha - minAlpha)

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(alpha))
            )
        }
    }

    // MARK: - White Haze (Blizzard whiteout)

    private func drawWhiteHaze(ctx: GraphicsContext, size: CGSize, opacity: Double) {
        let szScale = min(size.width, size.height) / 400.0
        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 60 * szScale))
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: -size.width * 0.1,
                y: size.height * 0.1,
                width: size.width * 1.2,
                height: size.height * 0.8
            )),
            with: .color(.white.opacity(opacity))
        )
    }

    // MARK: - Dark Overlay (Snow / Blizzard)

    private func drawDarkOverlay(ctx: GraphicsContext, size: CGSize, opacity: Double) {
        ctx.fill(
            Rectangle().path(in: CGRect(origin: .zero, size: size)),
            with: .color(.black.opacity(opacity))
        )
    }

    // MARK: - Subtle Lightning Glow (Thunderstorm / Hail)

    private func drawSubtleLightningGlow(ctx: GraphicsContext, size: CGSize, opacity: Double) {
        var rng = SeededRNG(seed: 99)
        let x = rng.nextDouble() * size.width * 0.6 + size.width * 0.2
        let y = rng.nextDouble() * size.height * 0.4 + size.height * 0.1
        let szScale = min(size.width, size.height) / 400.0
        let glowR = 40.0 * szScale

        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 20 * szScale))
        glowCtx.fill(
            Circle().path(in: CGRect(
                x: x - glowR,
                y: y - glowR,
                width: glowR * 2,
                height: glowR * 2
            )),
            with: .color(.white.opacity(opacity))
        )
    }

    // MARK: - Hail Stones (Small faint circles)

    private func drawHailStones(ctx: GraphicsContext, size: CGSize, count: Int) {
        var rng = SeededRNG(seed: 83)

        for _ in 0..<count {
            let x = rng.nextDouble() * size.width
            let y = rng.nextDouble() * size.height
            let radius = 1.5 + rng.nextDouble() * 1.5
            let alpha = 0.12 + rng.nextDouble() * 0.10

            ctx.fill(
                Circle().path(in: CGRect(
                    x: x - radius,
                    y: y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(alpha))
            )
        }
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
