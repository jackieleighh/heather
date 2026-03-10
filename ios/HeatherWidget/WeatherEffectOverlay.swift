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
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.15, cy: 0.30, scale: 0.28, alpha: 0.20, speed: 0.06),
                    CloudConfig(cx: 0.58, cy: 0.38, scale: 0.30, alpha: 0.18, speed: 0.04),
                ])
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(50 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t)
                drawClouds(ctx: ctx, size: size, time: t, configs: [
                    CloudConfig(cx: 0.15, cy: 0.30, scale: 0.28, alpha: 0.20, speed: 0.04),
                    CloudConfig(cx: 0.58, cy: 0.38, scale: 0.30, alpha: 0.18, speed: 0.03),
                ])
            }
        case "partlyCloudy":
            let pcCenter = CGPoint(x: size.width * 0.75, y: size.height * 0.12)
            let pcClouds = [
                CloudConfig(cx: 0.20, cy: 0.08, scale: 0.30, alpha: 0.24, speed: 0.05),
                CloudConfig(cx: 0.65, cy: 0.20, scale: 0.36, alpha: 0.26, speed: 0.035),
                CloudConfig(cx: 0.40, cy: 0.55, scale: 0.28, alpha: 0.20, speed: 0.045),
            ]
            if isDay {
                drawSunRaysWedge(ctx: ctx, size: size, time: t, lengthScale: 0.54, alphaScale: 0.65, sunCenter: pcCenter)
                drawSunGlowRadial(ctx: ctx, size: size, time: t, outerRadius: 65, innerRadius: 25, outerAlpha: 0.28, innerAlpha: 0.36, sunCenter: pcCenter)
                drawPartlyCloudyClouds(ctx: ctx, size: size, time: t, configs: pcClouds)
            } else {
                drawStars(ctx: ctx, size: size, time: t, count: Int(50 * scale))
                drawMoonGlow(ctx: ctx, size: size, time: t, moonCenter: pcCenter)
                drawPartlyCloudyClouds(ctx: ctx, size: size, time: t, configs: pcClouds)
            }
        case "overcast":
            drawOvercast(ctx: ctx, size: size, time: t)
        case "foggy":
            drawFog(ctx: ctx, size: size, time: t)
        case "drizzle":
            drawRainStreaks(ctx: ctx, size: size, count: Int(15 * scale), minAlpha: 0.10, maxAlpha: 0.18, strokeWidth: 0.5, angle: 0.15, lengthRange: 8...14)
        case "rain":
            drawRainStreaks(ctx: ctx, size: size, count: Int(30 * scale), minAlpha: 0.12, maxAlpha: 0.22, strokeWidth: 0.7, angle: 0.22, lengthRange: 10...18)
        case "heavyRain":
            drawRainStreaks(ctx: ctx, size: size, count: Int(45 * scale), minAlpha: 0.12, maxAlpha: 0.25, strokeWidth: 0.8, angle: 0.28, lengthRange: 12...22)
            drawBottomHaze(ctx: ctx, size: size, opacity: 0.05)
        case "freezingRain":
            drawFreezingRain(ctx: ctx, size: size, count: Int(24 * scale))
        case "snow":
            drawSnowDots(ctx: ctx, size: size, count: Int(22 * scale), minAlpha: 0.12, maxAlpha: 0.25, radiusRange: 1.0...2.5)
        case "blizzard":
            drawSnowDots(ctx: ctx, size: size, count: Int(40 * scale), minAlpha: 0.14, maxAlpha: 0.28, radiusRange: 1.0...3.0)
            drawWhiteHaze(ctx: ctx, size: size, opacity: 0.03)
        case "thunderstorm":
            drawRainStreaks(ctx: ctx, size: size, count: Int(35 * scale), minAlpha: 0.12, maxAlpha: 0.22, strokeWidth: 0.7, angle: 0.22, lengthRange: 10...18)
            drawSubtleLightningGlow(ctx: ctx, size: size, opacity: 0.06)
        case "hail":
            drawHailStones(ctx: ctx, size: size, count: Int(24 * scale))
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
        let spin = time * 0.08

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

    // MARK: - Clouds (Mini, faint)

    private struct CloudConfig {
        let cx: Double
        let cy: Double
        let scale: Double
        let alpha: Double
        let speed: Double
    }

    private func drawClouds(ctx: GraphicsContext, size: CGSize, time: Double, configs: [CloudConfig]) {
        for config in configs {
            let cloudScale = size.width * config.scale

            let totalWidth = size.width + cloudScale * 1.5
            let rawX = (config.cx * size.width + time * size.width * config.speed)
                .truncatingRemainder(dividingBy: totalWidth) - cloudScale * 0.75
            let wobble = sin(time * 0.3 + config.cx * 10) * 4
            let center = CGPoint(x: rawX, y: size.height * config.cy + wobble)

            drawSingleCloud(ctx: ctx, center: center, scale: cloudScale, alpha: config.alpha)
        }
    }

    private func drawSingleCloud(ctx: GraphicsContext, center: CGPoint, scale: CGFloat, alpha: Double) {
        var cloudCtx = ctx
        cloudCtx.addFilter(.blur(radius: scale * 0.06))

        cloudCtx.fill(
            Ellipse().path(in: CGRect(
                x: center.x - scale * 0.65,
                y: center.y + scale * 0.10,
                width: scale * 1.3,
                height: scale * 0.28
            )),
            with: .color(.white.opacity(alpha * 0.7))
        )

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

    // MARK: - Partly Cloudy Clouds (Mini)

    private func drawPartlyCloudyClouds(ctx: GraphicsContext, size: CGSize, time: Double, configs: [CloudConfig]) {
        for config in configs {
            let cloudScale = size.width * config.scale
            let totalWidth = size.width + cloudScale * 1.5
            let rawX = (config.cx * size.width + time * size.width * config.speed)
                .truncatingRemainder(dividingBy: totalWidth) - cloudScale * 0.75
            let wobble = sin(time * 0.3 + config.cx * 10) * 4
            let center = CGPoint(x: rawX, y: size.height * config.cy + wobble)
            drawPartlyCloudyCloud(ctx: ctx, center: center, scale: cloudScale, alpha: config.alpha)
        }
    }

    private func drawPartlyCloudyCloud(ctx: GraphicsContext, center: CGPoint, scale: CGFloat, alpha: Double) {
        var cloudCtx = ctx
        cloudCtx.addFilter(.blur(radius: scale * 0.06))

        cloudCtx.fill(
            Ellipse().path(in: CGRect(
                x: center.x - scale * 0.70,
                y: center.y + scale * 0.12 - scale * 0.175,
                width: scale * 1.4,
                height: scale * 0.35
            )),
            with: .color(.white.opacity(alpha * 0.75))
        )

        let leftR = scale * 0.30
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - scale * 0.30 - leftR,
                y: center.y - leftR,
                width: leftR * 2,
                height: leftR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        let centerR = scale * 0.36
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x - centerR,
                y: center.y - scale * 0.12 - centerR,
                width: centerR * 2,
                height: centerR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        let rightR = scale * 0.28
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x + scale * 0.32 - rightR,
                y: center.y + scale * 0.02 - rightR,
                width: rightR * 2,
                height: rightR * 2
            )),
            with: .color(.white.opacity(alpha))
        )

        let topR = scale * 0.22
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x + scale * 0.05 - topR,
                y: center.y - scale * 0.24 - topR,
                width: topR * 2,
                height: topR * 2
            )),
            with: .color(.white.opacity(alpha * 0.85))
        )

        let shoulderR = scale * 0.18
        cloudCtx.fill(
            Circle().path(in: CGRect(
                x: center.x + scale * 0.44 - shoulderR,
                y: center.y + scale * 0.05 - shoulderR,
                width: shoulderR * 2,
                height: shoulderR * 2
            )),
            with: .color(.white.opacity(alpha * 0.85))
        )
    }

    // MARK: - Overcast (Fewer masses, fainter)

    private func drawOvercast(ctx: GraphicsContext, size: CGSize, time: Double) {
        let w = size.width
        let h = size.height
        let szScale = min(w, h) / 400.0

        let glowR = 65.0 * szScale
        var glowCtx = ctx
        glowCtx.addFilter(.blur(radius: 50 * szScale))
        glowCtx.fill(
            Circle().path(in: CGRect(
                x: w * 0.7 - glowR,
                y: h * 0.08 - glowR,
                width: glowR * 2,
                height: glowR * 2
            )),
            with: .color(.white.opacity(0.045))
        )

        let massParams: [(yFrac: Double, scale: Double, speed: Double, alpha: Double, startX: Double, wobblePhase: Double)] = [
            (0.08, 0.52, 0.24, 0.06, 0.3, 0.0),
            (0.25, 0.48, 0.28, 0.055, 0.7, 1.2),
            (0.42, 0.50, 0.36, 0.05, 0.45, 2.4),
            (0.58, 0.46, 0.26, 0.045, 0.55, 3.6),
            (0.74, 0.44, 0.32, 0.04, 0.40, 4.8),
        ]

        var rng = SeededRNG(seed: 88)

        for mass in massParams {
            let massScale = w * mass.scale
            let blurRadius = massScale * 0.12

            let totalWidth = w * 2.2
            let raw = mass.startX * w + time * mass.speed * w
            let xNorm = (raw.truncatingRemainder(dividingBy: totalWidth)) / totalWidth
            let centerX = (xNorm * 2.2 - 0.6) * w
            let wobble = sin(time * 0.5 + mass.wobblePhase) * h * 0.008
            let centerY = h * mass.yFrac + wobble

            var cloudCtx = ctx
            cloudCtx.addFilter(.blur(radius: blurRadius))

            let blobCount = 4 + Int(rng.nextDouble() * 3)
            for _ in 0..<blobCount {
                let dx = (rng.nextDouble() - 0.5) * 1.8
                let dy = (rng.nextDouble() - 0.5) * 0.8
                let blobRadius = (0.16 + rng.nextDouble() * 0.22) * massScale

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

        var hazeCtx = ctx
        hazeCtx.addFilter(.blur(radius: 100 * szScale))
        hazeCtx.fill(
            Ellipse().path(in: CGRect(
                x: w * 0.5 - w * 1.0,
                y: h * 0.25 - h * 0.25,
                width: w * 2.0,
                height: h * 0.5
            )),
            with: .color(.white.opacity(0.009))
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

        for _ in 0..<6 {
            let yRaw = rng.nextDouble()
            let yBiased = yRaw * yRaw
            let yFraction = 0.05 + yBiased * 0.85
            let bandHeight = (50.0 + rng.nextDouble() * 70.0) * szScale
            let speed = 0.08 + rng.nextDouble() * 0.14
            let wispWidth = 0.4 + rng.nextDouble() * 0.6
            let blur = bandHeight * 0.16 + rng.nextDouble() * 6
            let baseAlpha = 0.06 + rng.nextDouble() * 0.04
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
            let length = 10.0 + rng.nextDouble() * 8.0
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
