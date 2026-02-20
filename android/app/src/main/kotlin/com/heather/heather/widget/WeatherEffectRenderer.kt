package com.totms.heather.widget

import android.graphics.*
import kotlin.math.*

/**
 * Renders weather effects onto a Canvas bitmap, matching the iOS widget's
 * WeatherEffectOverlay visual style.
 */
object WeatherEffectRenderer {

    fun render(canvas: Canvas, conditionName: String, isDay: Boolean, w: Float, h: Float) {
        val time = (System.currentTimeMillis() / 1000.0) % 100000.0
        val szScale = min(w, h) / 400f

        when (conditionName) {
            "sunny" -> if (isDay) {
                drawSunRaysWedge(canvas, w, h, time, szScale)
                drawSunGlow(canvas, w, h, time, szScale)
            } else {
                drawStars(canvas, w, h, time, 60)
                drawMoonGlow(canvas, w, h, time, szScale)
            }
            "mostlySunny" -> if (isDay) {
                drawSunRaysWedge(canvas, w, h, time, szScale, lengthScale = 0.78f, alphaScale = 0.8f)
                drawSunGlow(canvas, w, h, time, szScale, outerR = 110f, innerR = 45f, outerA = 0.18f, innerA = 0.24f)
                drawClouds(canvas, w, h, time, listOf(
                    CloudCfg(0.15, 0.30, 0.38, 0.30, 0.06),
                    CloudCfg(0.58, 0.38, 0.42, 0.28, 0.04),
                    CloudCfg(0.30, 0.62, 0.35, 0.22, 0.05),
                ))
            } else {
                drawStars(canvas, w, h, time, 60)
                drawMoonGlow(canvas, w, h, time, szScale)
                drawClouds(canvas, w, h, time, listOf(
                    CloudCfg(0.15, 0.30, 0.38, 0.30, 0.04),
                    CloudCfg(0.58, 0.38, 0.42, 0.28, 0.03),
                    CloudCfg(0.30, 0.62, 0.35, 0.22, 0.035),
                ))
            }
            "partlyCloudy" -> if (isDay) {
                drawSunRaysWedge(canvas, w, h, time, szScale, lengthScale = 0.62f, alphaScale = 0.65f)
                drawSunGlow(canvas, w, h, time, szScale, outerR = 90f, innerR = 35f, outerA = 0.14f, innerA = 0.20f)
                drawClouds(canvas, w, h, time, listOf(
                    CloudCfg(0.20, 0.08, 0.40, 0.35, 0.05),
                    CloudCfg(0.65, 0.20, 0.48, 0.38, 0.035),
                    CloudCfg(0.10, 0.38, 0.42, 0.32, 0.06),
                    CloudCfg(0.75, 0.55, 0.36, 0.28, 0.045),
                    CloudCfg(0.40, 0.72, 0.34, 0.24, 0.055),
                ))
            } else {
                drawStars(canvas, w, h, time, 60)
                drawMoonGlow(canvas, w, h, time, szScale)
                drawClouds(canvas, w, h, time, listOf(
                    CloudCfg(0.2, 0.1, 0.38, 0.28, 0.05),
                    CloudCfg(0.6, 0.25, 0.42, 0.30, 0.035),
                    CloudCfg(0.35, 0.55, 0.35, 0.24, 0.045),
                ))
            }
            "overcast" -> drawOvercast(canvas, w, h, time)
            "foggy" -> drawFog(canvas, w, h, time)
            "drizzle" -> drawRain(canvas, w, h, time, 64, 2.0, 6.0, 0.8, 2.0, 0.3, 8.0, 101)
            "rain" -> drawRain(canvas, w, h, time, 96, 4.0, 9.0, 0.8, 2.3, 0.5, 12.0, 102)
            "heavyRain" -> drawRain(canvas, w, h, time, 160, 6.0, 14.0, 1.0, 3.0, 1.2, 16.0, 103)
            "freezingRain" -> drawFreezingRain(canvas, w, h, time)
            "snow" -> {
                drawDarkOverlay(canvas, w, h, 0.18f)
                drawSnow(canvas, w, h, time)
            }
            "blizzard" -> {
                drawDarkOverlay(canvas, w, h, 0.18f)
                drawBlizzard(canvas, w, h, time)
                drawWhiteoutHaze(canvas, w, h, time)
            }
            "thunderstorm" -> {
                drawRain(canvas, w, h, time, 200, 6.0, 16.0, 1.0, 2.5, 1.5, 15.0, 104)
                drawLightning(canvas, w, h, time)
            }
            "hail" -> {
                drawHail(canvas, w, h, time)
                drawLightning(canvas, w, h, time)
            }
        }
    }

    /** Adds a subtle dark scrim for text contrast (simulates iOS drop shadows). */
    fun drawTextScrim(canvas: Canvas, w: Float, h: Float) {
        val paint = Paint()

        // Bottom gradient for lower text
        paint.shader = LinearGradient(
            0f, h * 0.65f, 0f, h,
            intArrayOf(Color.TRANSPARENT, Color.argb(50, 0, 0, 0)),
            null, Shader.TileMode.CLAMP,
        )
        canvas.drawRect(0f, 0f, w, h, paint)

        // Top gradient for upper text
        paint.shader = LinearGradient(
            0f, 0f, 0f, h * 0.35f,
            intArrayOf(Color.argb(35, 0, 0, 0), Color.TRANSPARENT),
            null, Shader.TileMode.CLAMP,
        )
        canvas.drawRect(0f, 0f, w, h, paint)
    }

    // ── Dark overlay ─────────────────────────────────────────────

    private fun drawDarkOverlay(canvas: Canvas, w: Float, h: Float, alpha: Float) {
        val paint = Paint().apply { color = Color.argb((alpha * 255).toInt(), 0, 0, 0) }
        canvas.drawRect(0f, 0f, w, h, paint)
    }

    // ── Sun rays (wedge-shaped with gradient, matching iOS) ──────

    private fun drawSunRaysWedge(
        canvas: Canvas, w: Float, h: Float, time: Double, szScale: Float,
        lengthScale: Float = 1f, alphaScale: Float = 1f,
    ) {
        val cx = w * 0.8f
        val cy = h * 0.12f
        val spin = time * 0.08
        val innerR = 25.0 * szScale

        val angles  = doubleArrayOf(0.0,0.55,1.05,1.6,2.15,2.65,3.2,3.75,4.3,4.85,5.35,5.9)
        val lengths = doubleArrayOf(380.0,240.0,320.0,200.0,360.0,260.0,340.0,220.0,300.0,250.0,350.0,230.0)
        val spreads = doubleArrayOf(0.06,0.04,0.055,0.035,0.06,0.045,0.055,0.04,0.05,0.04,0.06,0.035)
        val alphas  = doubleArrayOf(0.40,0.25,0.35,0.20,0.38,0.28,0.33,0.22,0.30,0.24,0.37,0.18)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(6f * szScale, BlurMaskFilter.Blur.NORMAL)
        }

        for (i in angles.indices) {
            val angle = angles[i] + spin
            val outerR = lengths[i] * szScale * lengthScale
            val halfSpread = spreads[i]
            val a = ((alphas[i] + sin(time * 0.5 + i * 0.7).absoluteValue * 0.05) * alphaScale).toFloat()

            val cosA = cos(angle).toFloat(); val sinA = sin(angle).toFloat()
            val cosL = cos(angle - halfSpread).toFloat(); val sinL = sin(angle - halfSpread).toFloat()
            val cosR = cos(angle + halfSpread).toFloat(); val sinR = sin(angle + halfSpread).toFloat()
            val iR = innerR.toFloat(); val oR = outerR.toFloat()

            val path = Path().apply {
                moveTo(cx + cosL * iR, cy + sinL * iR)
                lineTo(cx + cosL * oR, cy + sinL * oR)
                lineTo(cx + cosR * oR, cy + sinR * oR)
                lineTo(cx + cosR * iR, cy + sinR * iR)
                close()
            }

            paint.shader = LinearGradient(
                cx + cosA * iR, cy + sinA * iR,
                cx + cosA * oR, cy + sinA * oR,
                intArrayOf(Color.argb((a * 255).toInt(), 255, 255, 255), Color.TRANSPARENT),
                null, Shader.TileMode.CLAMP,
            )
            canvas.drawPath(path, paint)
        }
        paint.shader = null
    }

    // ── Sun glow (radial, matching iOS) ──────────────────────────

    private fun drawSunGlow(
        canvas: Canvas, w: Float, h: Float, time: Double, szScale: Float,
        outerR: Float = 130f, innerR: Float = 55f, outerA: Float = 0.22f, innerA: Float = 0.28f,
    ) {
        val cx = w * 0.8f; val cy = h * 0.12f
        val pulse = (sin(time * 0.8) * 0.03).toFloat()

        // Outer glow
        val outerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(40f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((outerA + pulse) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        }
        canvas.drawCircle(cx, cy, outerR * szScale, outerPaint)

        // Inner core
        val innerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(20f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((innerA + pulse) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        }
        canvas.drawCircle(cx, cy, innerR * szScale, innerPaint)
    }

    // ── Moon glow ────────────────────────────────────────────────

    private fun drawMoonGlow(canvas: Canvas, w: Float, h: Float, time: Double, szScale: Float) {
        val cx = w * 0.8f; val cy = h * 0.12f

        val outerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(25f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(38, 255, 255, 255) // 0.15
        }
        canvas.drawCircle(cx, cy, 50f * szScale, outerPaint)

        val innerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(8f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(102, 255, 255, 255) // 0.4
        }
        canvas.drawCircle(cx, cy, 25f * szScale, innerPaint)
    }

    // ── Stars ────────────────────────────────────────────────────

    private fun drawStars(canvas: Canvas, w: Float, h: Float, time: Double, count: Int) {
        val rng = SeededRNG(42)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(count) {
            val x = (rng.nextDouble() * w).toFloat()
            val y = (rng.nextDouble() * h * 0.7).toFloat()
            val sz = (0.5 + rng.nextDouble() * 2.5).toFloat()
            val twinkleSpd = 0.5 + rng.nextDouble() * 2.0
            val phase = rng.nextDouble() * PI * 2
            val twinkle = ((sin(time * twinkleSpd + phase) + 1) / 2).toFloat()
            val opacity = 0.1f + twinkle * 0.3f
            val radius = sz * (0.8f + twinkle * 0.2f)

            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, radius, paint)
        }
    }

    // ── Clouds (drifting with wrap-around) ───────────────────────

    private data class CloudCfg(val cx: Double, val cy: Double, val scale: Double, val alpha: Double, val speed: Double)

    private fun drawClouds(canvas: Canvas, w: Float, h: Float, time: Double, configs: List<CloudCfg>) {
        for (cfg in configs) {
            val cloudScale = w * cfg.scale.toFloat()
            val totalW = w + cloudScale * 1.5f
            val rawX = ((cfg.cx * w + time * w * cfg.speed) % totalW - cloudScale * 0.75).toFloat()
            val wobble = (sin(time * 0.3 + cfg.cx * 10) * 8).toFloat()
            drawSingleCloud(canvas, rawX, h * cfg.cy.toFloat() + wobble, cloudScale, cfg.alpha.toFloat())
        }
    }

    private fun drawSingleCloud(canvas: Canvas, cx: Float, cy: Float, scale: Float, alpha: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(scale * 0.06f, BlurMaskFilter.Blur.NORMAL)
        }

        // Flat base
        paint.color = Color.argb((alpha * 0.7f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(cx - scale * 0.65f, cy + scale * 0.10f,
            cx + scale * 0.65f, cy + scale * 0.10f + scale * 0.28f, paint)

        // Main lobes
        paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
        canvas.drawCircle(cx - scale * 0.25f, cy, scale * 0.24f, paint)
        canvas.drawCircle(cx, cy - scale * 0.08f, scale * 0.30f, paint)
        canvas.drawCircle(cx + scale * 0.28f, cy + scale * 0.02f, scale * 0.22f, paint)

        // Top accent
        paint.color = Color.argb((alpha * 0.8f * 255).toInt(), 255, 255, 255)
        canvas.drawCircle(cx + scale * 0.04f, cy - scale * 0.20f, scale * 0.18f, paint)
    }

    // ── Overcast (blob masses + subtle haze, matching iOS) ──────

    private fun drawOvercast(canvas: Canvas, w: Float, h: Float, time: Double) {
        // Soft sun glow through clouds
        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(70f, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((0.15 + sin(time * 0.4) * 0.03) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        }
        canvas.drawCircle(w * 0.7f, h * 0.08f, 60f, glowPaint)

        // Cloud masses with blob rendering
        val massParams = listOf(
            arrayOf(0.08, 0.55, 0.14, 0.18, 0.3, 0.0),
            arrayOf(0.22, 0.50, 0.18, 0.16, 0.7, 1.2),
            arrayOf(0.38, 0.48, 0.26, 0.14, 0.45, 2.4),
            arrayOf(0.52, 0.52, 0.16, 0.13, 0.55, 3.6),
            arrayOf(0.66, 0.45, 0.28, 0.12, 0.35, 4.8),
            arrayOf(0.80, 0.42, 0.20, 0.10, 0.60, 6.0),
        )

        val rng = SeededRNG(88)
        for (mp in massParams) {
            val yFrac = mp[0]; val sc = mp[1]; val speed = mp[2]
            val alpha = mp[3]; val startX = mp[4]; val wobblePhase = mp[5]
            val massScale = w * sc.toFloat()
            val blurR = massScale * 0.12f
            val totalWidth = w * 2.2
            val raw = startX * w + time * speed * w
            val xNorm = (raw % totalWidth) / totalWidth
            val centerX = ((xNorm * 2.2 - 0.6) * w).toFloat()
            val wobble = (sin(time * 0.5 + wobblePhase) * h * 0.012).toFloat()
            val centerY = (h * yFrac).toFloat() + wobble

            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.FILL
                maskFilter = BlurMaskFilter(blurR, BlurMaskFilter.Blur.NORMAL)
                color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
            }

            val blobCount = 8 + (rng.nextDouble() * 3).toInt()
            repeat(blobCount) {
                val dx = ((rng.nextDouble() - 0.5) * 1.4).toFloat()
                val dy = ((rng.nextDouble() - 0.5) * 0.6).toFloat()
                val blobR = ((0.14 + rng.nextDouble() * 0.20) * massScale).toFloat()
                canvas.drawCircle(centerX + dx * massScale, centerY + dy * massScale, blobR, paint)
            }
        }

        // Very subtle haze
        val hazePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(100f, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((0.03 + sin(time * 0.15) * 0.01) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        }
        canvas.drawOval(w * 0.5f - w, h * 0.25f - h * 0.25f,
            w * 0.5f + w, h * 0.25f + h * 0.25f, hazePaint)
    }

    // ── Fog ──────────────────────────────────────────────────────

    private fun drawFog(canvas: Canvas, w: Float, h: Float, time: Double) {
        // Haze base
        val hazePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(80f, BlurMaskFilter.Blur.NORMAL)
        }
        hazePaint.color = Color.argb(((0.12 + sin(time * 0.2) * 0.03) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        canvas.drawOval(w * 0.5f - w * 1.1f, h * 0.3f - h * 0.35f,
            w * 0.5f + w * 1.1f, h * 0.3f + h * 0.35f, hazePaint)

        // Fog wisps
        val rng = SeededRNG(77)
        repeat(14) { i ->
            val yRaw = rng.nextDouble()
            val yFrac = 0.05 + yRaw * yRaw * 0.85
            val bandH = (50.0 + rng.nextDouble() * 70.0).toFloat()
            val speed = 0.08 + rng.nextDouble() * 0.14
            val wispW = (0.4 + rng.nextDouble() * 0.6).toFloat()
            val blur = (bandH * 0.16f + rng.nextDouble() * 6.0).toFloat()
            val baseAlpha = (0.13 + rng.nextDouble() * 0.12).toFloat()
            val startX = rng.nextDouble() * 2.4
            val wobblePhase = rng.nextDouble() * PI * 2

            val raw = startX + time * speed
            val xNorm = ((raw % 2.4) - 1.0).toFloat()
            val x = xNorm * w
            val wobble = (sin(time * 0.7 + wobblePhase) * h * 0.012).toFloat()
            val y = (h * yFrac).toFloat() + wobble

            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.FILL
                maskFilter = BlurMaskFilter(blur, BlurMaskFilter.Blur.NORMAL)
                color = Color.argb((baseAlpha * 255).toInt(), 255, 255, 255)
            }
            canvas.drawOval(x - wispW * w / 2, y - bandH / 2,
                x + wispW * w / 2, y + bandH / 2, paint)
        }
    }

    // ── Rain (deterministic falling) ─────────────────────────────

    private fun drawRain(
        canvas: Canvas, w: Float, h: Float, time: Double,
        count: Int, speedMin: Double, speedMax: Double,
        sizeMin: Double, sizeMax: Double,
        driftPerFrame: Double, lineBaseLen: Double, seed: Int,
    ) {
        val rng = SeededRNG(seed.toLong())
        val totalH = h + 30f
        val totalW = w + 20f
        val driftPerSec = driftPerFrame * 60.0
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { strokeCap = Paint.Cap.BUTT }

        repeat(count) {
            val initX = rng.nextDouble() * totalW - 10
            val initY = rng.nextDouble() * totalH - 15
            val speed = speedMin + rng.nextDouble() * (speedMax - speedMin)
            val sz = (sizeMin + rng.nextDouble() * (sizeMax - sizeMin)).toFloat()
            val opacity = (0.1 + rng.nextDouble() * 0.3).toFloat()
            val fallRate = speed * 60.0

            var y = ((initY + time * fallRate) % totalH).toFloat()
            if (y < -15f) y += totalH
            var x = ((initX + time * driftPerSec) % totalW).toFloat()
            if (x < -10f) x += totalW

            val lineLen = (lineBaseLen + speed).toFloat()
            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            paint.strokeWidth = sz
            canvas.drawLine(x, y, x + driftPerFrame.toFloat(), y + lineLen, paint)
        }
    }

    // ── Freezing rain ────────────────────────────────────────────

    private fun drawFreezingRain(canvas: Canvas, w: Float, h: Float, time: Double) {
        val icyBlue = Color.argb(255, 176, 224, 255)
        val rng = SeededRNG(301)
        val totalH = h + 30f; val totalW = w + 20f
        val driftPerSec = 0.6 * 60.0
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { strokeCap = Paint.Cap.BUTT }

        repeat(144) { // ~180 * 0.8
            val initX = rng.nextDouble() * totalW - 10
            val initY = rng.nextDouble() * totalH - 15
            val speed = 3.0 + rng.nextDouble() * 7.0
            val sz = (1.0 + rng.nextDouble() * 2.0).toFloat()
            val opacity = (0.1 + rng.nextDouble() * 0.3).toFloat()

            var y = ((initY + time * speed * 60) % totalH).toFloat()
            if (y < -15f) y += totalH
            var x = ((initX + time * driftPerSec) % totalW).toFloat()
            if (x < -10f) x += totalW

            val col = if (sz > 2f) icyBlue else Color.WHITE
            val lineLen = (10.0 + speed).toFloat()
            paint.color = Color.argb((opacity * 255).toInt(), Color.red(col), Color.green(col), Color.blue(col))
            paint.strokeWidth = sz
            canvas.drawLine(x, y, x + 0.6f, y + lineLen, paint)
        }

        // Icy sheen
        val sheenPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(80f, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((0.04 + sin(time * 0.5) * 0.02) * 255).toInt().coerceIn(0, 255), 176, 224, 255)
        }
        canvas.drawCircle(w * 0.3f, h * 0.7f, w * 0.25f, sheenPaint)
    }

    // ── Snow (deterministic falling with wobble) ─────────────────

    private fun drawSnow(canvas: Canvas, w: Float, h: Float, time: Double) {
        val rng = SeededRNG(201)
        val totalH = h + 20f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(80) { // ~100 * 0.8
            val initX = rng.nextDouble() * w
            val initY = rng.nextDouble() * totalH - 10
            val speed = 0.5 + rng.nextDouble() * 2.0
            val flakeSz = (2.0 + rng.nextDouble() * 5.0).toFloat()
            val opacity = (0.1 + rng.nextDouble() * 0.3).toFloat()
            val wobblePhase = rng.nextDouble() * PI * 2

            var y = ((initY + time * speed * 60) % totalH).toFloat()
            if (y < -10f) y += totalH
            val wobble = (sin(time * 1.5 + wobblePhase) * 0.8).toFloat()
            var x = (initX + wobble).toFloat()
            if (x < 0) x += w; if (x > w) x -= w

            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, flakeSz / 2, paint)
        }
    }

    // ── Blizzard (chaotic wind) ──────────────────────────────────

    private fun drawBlizzard(canvas: Canvas, w: Float, h: Float, time: Double) {
        val rng = SeededRNG(401)
        val totalH = h + 20f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(280) { // ~350 * 0.8
            val initX = rng.nextDouble() * w
            val initY = rng.nextDouble() * totalH - 10
            val speed = 1.5 + rng.nextDouble() * 4.0
            val flakeSz = (1.5 + rng.nextDouble() * 3.5).toFloat()
            val opacity = (0.15 + rng.nextDouble() * 0.45).toFloat()
            val wobblePhase = rng.nextDouble() * PI * 2

            var y = ((initY + time * speed * 60) % totalH).toFloat()
            if (y < -10f) y += totalH
            val wind = (sin(time * 1.8 + wobblePhase) * 2.5
                + sin(time * 3.7 + wobblePhase * 2.3) * 1.2 + 1.0).toFloat()
            var x = ((initX + wind * time * 10) % w).toFloat()
            if (x < 0) x += w

            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, flakeSz / 2, paint)
        }
    }

    // ── Whiteout haze ────────────────────────────────────────────

    private fun drawWhiteoutHaze(canvas: Canvas, w: Float, h: Float, time: Double) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(100f, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb(((0.06 + sin(time * 0.5) * 0.03) * 255).toInt().coerceIn(0, 255), 255, 255, 255)
        }
        canvas.drawRect(0f, 0f, w, h, paint)
    }

    // ── Lightning flash ──────────────────────────────────────────

    private fun drawLightning(canvas: Canvas, w: Float, h: Float, time: Double) {
        val cycle = time % 4.5
        if (cycle >= 0.3) return
        val flashA = (0.15 * (1.0 - cycle / 0.3)).toFloat()
        val paint = Paint().apply { color = Color.argb((flashA * 255).toInt(), 255, 255, 255) }
        canvas.drawRect(0f, 0f, w, h, paint)
    }

    // ── Hail ─────────────────────────────────────────────────────

    private fun drawHail(canvas: Canvas, w: Float, h: Float, time: Double) {
        val rng = SeededRNG(501)
        val totalH = h + 20f; val totalW = w + 10f
        val driftPerSec = 0.5 * 60.0
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(96) { // ~120 * 0.8
            val initX = rng.nextDouble() * totalW
            val initY = rng.nextDouble() * totalH - 10
            val speed = 4.0 + rng.nextDouble() * 8.0
            val stoneSz = (2.0 + rng.nextDouble() * 4.0).toFloat()
            val opacity = (0.1 + rng.nextDouble() * 0.3).toFloat()

            var y = ((initY + time * speed * 60) % totalH).toFloat()
            if (y < -10f) y += totalH
            var x = ((initX + time * driftPerSec) % totalW).toFloat()
            if (x < 0) x += totalW

            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, stoneSz / 2, paint)
        }
    }

    // ── Seeded RNG ───────────────────────────────────────────────

    private class SeededRNG(seed: Long) {
        private var state = if (seed == 0L) 1L else seed

        fun next(): Long {
            state = state xor (state shl 13)
            state = state xor (state shr 7)
            state = state xor (state shl 17)
            return state
        }

        fun nextDouble(): Double {
            return ((next() and 0xFFFFFFFFL) % 10000).toDouble() / 10000.0
        }
    }
}
