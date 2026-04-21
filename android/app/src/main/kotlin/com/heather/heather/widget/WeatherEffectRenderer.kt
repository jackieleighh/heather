package com.totms.heather.widget

import android.graphics.*
import kotlin.math.*

/**
 * Renders weather effects onto a Canvas bitmap, matching the iOS widget's
 * WeatherEffectOverlay visual style. All effects are static (no time-based
 * animation) with deterministic seeded RNG for stable particle positions.
 */
object WeatherEffectRenderer {

    fun render(canvas: Canvas, conditionName: String, isDay: Boolean, w: Float, h: Float) {
        val szScale = min(w, h) / 400f

        when (conditionName) {
            "sunny" -> if (isDay) {
                drawSunRaysWedge(canvas, w, h, szScale)
                drawSunGlow(canvas, w, h, szScale)
            } else {
                drawStars(canvas, w, h, 50)
            }
            "mostlySunny" -> if (isDay) {
                drawMiniCloud(canvas, w * 0.22f, h * 0.26f, w * 0.24f, 0.22f)
                drawMiniCloud(canvas, w * 0.80f, h * 0.48f, w * 0.22f, 0.20f)
                drawMiniCloud(canvas, w * 0.48f, h * 0.61f, w * 0.20f, 0.18f)
            } else {
                drawStars(canvas, w, h, 50)
                drawMiniCloud(canvas, w * 0.22f, h * 0.26f, w * 0.24f, 0.18f)
                drawMiniCloud(canvas, w * 0.80f, h * 0.48f, w * 0.22f, 0.16f)
                drawMiniCloud(canvas, w * 0.48f, h * 0.61f, w * 0.20f, 0.14f)
            }
            "partlyCloudy" -> if (isDay) {
                drawMiniCloud(canvas, w * 0.18f, h * 0.26f, w * 0.26f, 0.26f)
                drawMiniCloud(canvas, w * 0.72f, h * 0.22f, w * 0.28f, 0.28f)
                drawMiniCloud(canvas, w * 0.51f, h * 0.55f, w * 0.24f, 0.24f)
                drawMiniCloud(canvas, w * 0.82f, h * 0.71f, w * 0.26f, 0.22f)
            } else {
                drawStars(canvas, w, h, 50)
                drawMiniCloud(canvas, w * 0.18f, h * 0.26f, w * 0.26f, 0.20f)
                drawMiniCloud(canvas, w * 0.72f, h * 0.22f, w * 0.28f, 0.22f)
                drawMiniCloud(canvas, w * 0.51f, h * 0.55f, w * 0.24f, 0.18f)
                drawMiniCloud(canvas, w * 0.82f, h * 0.71f, w * 0.26f, 0.18f)
            }
            "overcast" -> drawOvercast(canvas, w, h, szScale)
            "foggy" -> drawFog(canvas, w, h, szScale)
            "drizzle" -> drawRainStreaks(canvas, w, h, 30, 0.25f, 0.45f, 1.2f, 0.22f, 10f, 18f)
            "rain" -> drawRainStreaks(canvas, w, h, 55, 0.25f, 0.45f, 1.2f, 0.22f, 10f, 18f)
            "heavyRain" -> {
                drawRainStreaks(canvas, w, h, 75, 0.30f, 0.50f, 1.4f, 0.28f, 14f, 22f)
                drawBottomHaze(canvas, w, h, szScale, 0.08f)
            }
            "freezingRain" -> drawRainStreaks(canvas, w, h, 55, 0.25f, 0.45f, 1.2f, 0.22f, 10f, 18f)
            "snow" -> {
                drawSnowDots(canvas, w, h, 55, 0.35f, 0.60f, 1.2f, 2.8f)
                drawDarkOverlay(canvas, w, h, 0.10f)
            }
            "blizzard" -> {
                drawSnowDots(canvas, w, h, 65, 0.25f, 0.45f, 0.8f, 2.2f)
                drawWhiteHaze(canvas, w, h, szScale, 0.06f)
                drawDarkOverlay(canvas, w, h, 0.10f)
            }
            "thunderstorm" -> {
                drawRainStreaks(canvas, w, h, 35, 0.25f, 0.45f, 1.2f, 0.22f, 10f, 18f)
                drawSubtleLightningGlow(canvas, w, h, szScale, 0.10f)
            }
            "hail" -> {
                drawHailStones(canvas, w, h, 30)
                drawSubtleLightningGlow(canvas, w, h, szScale, 0.08f)
            }
        }
    }

    /** Adds a subtle dark scrim for text contrast. */
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

    // ── Sun Rays (wedge-shaped with gradient, matching iOS) ────

    private fun drawSunRaysWedge(canvas: Canvas, w: Float, h: Float, szScale: Float) {
        val cx = w * 0.8f
        val cy = h * 0.12f
        val innerR = 18f * szScale

        val angles  = doubleArrayOf(0.0, 0.63, 1.26, 1.88, 2.51, 3.14, 3.77, 4.40, 5.03, 5.65)
        val lengths = doubleArrayOf(240.0, 160.0, 220.0, 140.0, 230.0, 170.0, 210.0, 150.0, 200.0, 165.0)
        val spreads = doubleArrayOf(0.05, 0.035, 0.048, 0.03, 0.05, 0.038, 0.045, 0.035, 0.042, 0.035)
        val alphas  = doubleArrayOf(0.25, 0.16, 0.22, 0.13, 0.24, 0.18, 0.20, 0.14, 0.19, 0.15)

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(5f * szScale, BlurMaskFilter.Blur.NORMAL)
        }

        for (i in angles.indices) {
            val angle = angles[i]
            val outerR = (lengths[i] * szScale).toFloat()
            val halfSpread = spreads[i]
            val a = alphas[i].toFloat()

            val cosA = cos(angle).toFloat(); val sinA = sin(angle).toFloat()
            val cosL = cos(angle - halfSpread).toFloat(); val sinL = sin(angle - halfSpread).toFloat()
            val cosR = cos(angle + halfSpread).toFloat(); val sinR = sin(angle + halfSpread).toFloat()

            val path = Path().apply {
                moveTo(cx + cosL * innerR, cy + sinL * innerR)
                lineTo(cx + cosL * outerR, cy + sinL * outerR)
                lineTo(cx + cosR * outerR, cy + sinR * outerR)
                lineTo(cx + cosR * innerR, cy + sinR * innerR)
                close()
            }

            paint.shader = LinearGradient(
                cx + cosA * innerR, cy + sinA * innerR,
                cx + cosA * outerR, cy + sinA * outerR,
                intArrayOf(Color.argb((a * 255).toInt(), 255, 255, 255), Color.TRANSPARENT),
                null, Shader.TileMode.CLAMP,
            )
            canvas.drawPath(path, paint)
        }
        paint.shader = null
    }

    // ── Sun Glow (radial, matching iOS) ────────────────────────

    private fun drawSunGlow(canvas: Canvas, w: Float, h: Float, szScale: Float) {
        val cx = w * 0.8f
        val cy = h * 0.12f

        // Outer glow: outerAlpha(0.38) * 0.4 = 0.152
        val outerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(28f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.152f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawCircle(cx, cy, 90f * szScale, outerPaint)

        // Inner core: innerAlpha = 0.50
        val innerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(14f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.50f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawCircle(cx, cy, 38f * szScale, innerPaint)

        // Bright core
        val corePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(8f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.55f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawCircle(cx, cy, 22f * szScale, corePaint)
    }

    // ── Stars ──────────────────────────────────────────────────

    private fun drawStars(canvas: Canvas, w: Float, h: Float, count: Int) {
        val rng = SeededRNG(42)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(count) {
            val x = (rng.nextDouble() * w).toFloat()
            val y = (rng.nextDouble() * h * 0.7).toFloat()
            val sz = 0.5 + rng.nextDouble() * 2.0
            val phase = rng.nextDouble() * PI * 2
            val twinkle = (sin(phase) + 1) / 2
            val opacity = (0.08 + twinkle * 0.17).toFloat()
            val radius = (sz * (0.8 + twinkle * 0.2)).toFloat()

            paint.color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, radius, paint)
        }
    }

    // ── Mini Cloud (cumulus-style cluster, matching iOS) ────────

    private fun drawMiniCloud(canvas: Canvas, cx: Float, cy: Float, cloudScale: Float, alpha: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(cloudScale * 0.06f, BlurMaskFilter.Blur.NORMAL)
        }

        // Flat base oval
        paint.color = Color.argb((alpha * 0.7f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(
            cx - cloudScale * 0.65f,
            cy + cloudScale * 0.10f - cloudScale * 0.14f,
            cx + cloudScale * 0.65f,
            cy + cloudScale * 0.10f + cloudScale * 0.14f,
            paint,
        )

        // Three main lobes
        paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
        canvas.drawCircle(cx - cloudScale * 0.25f, cy, cloudScale * 0.24f, paint)
        canvas.drawCircle(cx, cy - cloudScale * 0.08f, cloudScale * 0.30f, paint)
        canvas.drawCircle(cx + cloudScale * 0.28f, cy + cloudScale * 0.02f, cloudScale * 0.22f, paint)

        // Top accent puff
        paint.color = Color.argb((alpha * 0.8f * 255).toInt(), 255, 255, 255)
        canvas.drawCircle(cx + cloudScale * 0.04f, cy - cloudScale * 0.20f, cloudScale * 0.18f, paint)
    }

    // ── Overcast (cloud blobs + haze, matching iOS) ────────────

    private fun drawOvercast(canvas: Canvas, w: Float, h: Float, szScale: Float) {
        // Soft sun glow
        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(50f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.16f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawCircle(w * 0.8f, h * 0.12f, 70f * szScale, glowPaint)

        // Cloud blobs at edges/corners
        drawOvercastCloudBlobs(canvas, w, h)

        // Upper haze
        val hazePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(100f * szScale, BlurMaskFilter.Blur.NORMAL)
        }
        hazePaint.color = Color.argb((0.04f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(w * 0.5f - w, 0f, w * 0.5f + w, h * 0.5f, hazePaint)

        // Lower haze
        hazePaint.color = Color.argb((0.03f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(w * 0.5f - w * 0.9f, h * 0.45f, w * 0.5f + w * 0.9f, h * 0.85f, hazePaint)
    }

    // ── Overcast Cloud Blobs ───────────────────────────────────

    private fun drawOvercastCloudBlobs(canvas: Canvas, w: Float, h: Float) {
        val rng = SeededRNG(88)
        val masses = arrayOf(
            floatArrayOf(0.15f, 0.06f, 0.55f, 0.16f),
            floatArrayOf(0.85f, 0.20f, 0.50f, 0.14f),
            floatArrayOf(0.10f, 0.38f, 0.48f, 0.13f),
            floatArrayOf(0.90f, 0.52f, 0.52f, 0.12f),
            floatArrayOf(0.20f, 0.68f, 0.46f, 0.11f),
            floatArrayOf(0.80f, 0.82f, 0.50f, 0.12f),
        )

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        for (mass in masses) {
            val scale = w * mass[2]
            val blurR = scale * 0.12f
            val centerX = w * mass[0]
            val centerY = h * mass[1]
            val alpha = mass[3]
            val blobCount = 10 + (rng.nextDouble() * 6).toInt()

            paint.maskFilter = BlurMaskFilter(blurR, BlurMaskFilter.Blur.NORMAL)
            paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)

            repeat(blobCount) {
                val dx = (rng.nextDouble() - 0.5) * 1.8
                val dy = (rng.nextDouble() - 0.5) * 0.8
                val blobRadius = ((0.16 + rng.nextDouble() * 0.22) * scale).toFloat()
                val bx = centerX + (dx * scale).toFloat()
                val by = centerY + (dy * scale).toFloat()

                canvas.drawCircle(bx, by, blobRadius, paint)
            }
        }
    }

    // ── Fog (static wisps, matching iOS) ───────────────────────

    private fun drawFog(canvas: Canvas, w: Float, h: Float, szScale: Float) {
        // Base atmospheric haze
        val hazePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(60f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.06f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawOval(-w * 0.2f, h * 0.1f, w * 1.2f, h * 0.6f, hazePaint)

        // 12 fog wisps — bottom-heavy distribution
        val rng = SeededRNG(77)
        val wispPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(12) {
            val yRaw = rng.nextDouble()
            val yBiased = yRaw * yRaw
            val yFrac = 0.05 + yBiased * 0.85
            val wispH = ((30.0 + rng.nextDouble() * 50.0) * szScale).toFloat()
            val wispW = (0.4 + rng.nextDouble() * 0.6).toFloat()
            val blur = (wispH * 0.3f + rng.nextDouble() * 4).toFloat()
            val alpha = (0.08 + rng.nextDouble() * 0.10).toFloat()
            val xPos = -0.2 + rng.nextDouble() * 1.4

            val x = (xPos * w).toFloat()
            val y = (h * yFrac).toFloat()

            wispPaint.maskFilter = BlurMaskFilter(blur, BlurMaskFilter.Blur.NORMAL)
            wispPaint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
            canvas.drawOval(
                x - wispW * w / 2f, y - wispH / 2f,
                x + wispW * w / 2f, y + wispH / 2f,
                wispPaint,
            )
        }

        // Extra wisps in bottom-right quadrant
        val brPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(12f * szScale, BlurMaskFilter.Blur.NORMAL)
        }
        brPaint.color = Color.argb((0.12f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(w * 0.35f, h * 0.58f, w * 0.90f, h * 0.58f + 35f * szScale, brPaint)

        brPaint.color = Color.argb((0.10f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(w * 0.45f, h * 0.72f, w * 0.95f, h * 0.72f + 28f * szScale, brPaint)

        brPaint.color = Color.argb((0.09f * 255).toInt(), 255, 255, 255)
        canvas.drawOval(w * 0.30f, h * 0.84f, w * 0.90f, h * 0.84f + 32f * szScale, brPaint)

        // Upper fog bank
        val upperPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(40f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((0.05f * 255).toInt(), 255, 255, 255)
        }
        canvas.drawOval(-w * 0.1f, -h * 0.05f, w * 1.1f, h * 0.25f, upperPaint)
    }

    // ── Rain Streaks (static diagonal lines, matching iOS) ─────

    private fun drawRainStreaks(
        canvas: Canvas, w: Float, h: Float,
        count: Int, minAlpha: Float, maxAlpha: Float,
        strokeWidth: Float, angle: Float, minLen: Float, maxLen: Float,
    ) {
        val rng = SeededRNG(55)
        val cols = ceil(sqrt(count.toDouble() * (w / h))).toInt()
        val rows = ceil(count.toDouble() / cols).toInt()
        val cellW = w / cols
        val cellH = h / rows
        var drawn = 0

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            strokeCap = Paint.Cap.BUTT
            this.strokeWidth = strokeWidth
        }

        for (row in 0 until rows) {
            for (col in 0 until cols) {
                if (drawn >= count) break
                val x = ((col + rng.nextDouble()) * cellW).toFloat()
                val y = ((row + rng.nextDouble()) * cellH).toFloat()
                val length = minLen + (rng.nextDouble() * (maxLen - minLen)).toFloat()
                val alpha = minAlpha + (rng.nextDouble() * (maxAlpha - minAlpha)).toFloat()

                val dx = (sin(angle.toDouble()) * length).toFloat()
                val dy = (cos(angle.toDouble()) * length).toFloat()

                paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
                canvas.drawLine(x, y, x + dx, y + dy, paint)
                drawn++
            }
        }
    }

    // ── Bottom Haze (heavy rain ground mist) ───────────────────

    private fun drawBottomHaze(canvas: Canvas, w: Float, h: Float, szScale: Float, opacity: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(30f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
        }
        canvas.drawOval(-w * 0.1f, h * 0.75f, w * 1.1f, h * 1.10f, paint)
    }

    // ── Snow Dots (static scattered circles, matching iOS) ─────

    private fun drawSnowDots(
        canvas: Canvas, w: Float, h: Float,
        count: Int, minAlpha: Float, maxAlpha: Float,
        minRadius: Float, maxRadius: Float,
    ) {
        val rng = SeededRNG(71)
        val cols = ceil(sqrt(count.toDouble() * (w / h))).toInt()
        val rows = ceil(count.toDouble() / cols).toInt()
        val cellW = w / cols
        val cellH = h / rows
        var drawn = 0

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        for (row in 0 until rows) {
            for (col in 0 until cols) {
                if (drawn >= count) break
                val x = ((col + rng.nextDouble()) * cellW).toFloat()
                val y = ((row + rng.nextDouble()) * cellH).toFloat()
                val radius = minRadius + (rng.nextDouble() * (maxRadius - minRadius)).toFloat()
                val alpha = minAlpha + (rng.nextDouble() * (maxAlpha - minAlpha)).toFloat()

                paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
                canvas.drawCircle(x, y, radius, paint)
                drawn++
            }
        }
    }

    // ── White Haze (blizzard whiteout) ─────────────────────────

    private fun drawWhiteHaze(canvas: Canvas, w: Float, h: Float, szScale: Float, opacity: Float) {
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(60f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
        }
        canvas.drawOval(-w * 0.1f, h * 0.1f, w * 1.1f, h * 0.9f, paint)
    }

    // ── Dark Overlay ───────────────────────────────────────────

    private fun drawDarkOverlay(canvas: Canvas, w: Float, h: Float, opacity: Float) {
        val paint = Paint().apply { color = Color.argb((opacity * 255).toInt(), 0, 0, 0) }
        canvas.drawRect(0f, 0f, w, h, paint)
    }

    // ── Subtle Lightning Glow ──────────────────────────────────

    private fun drawSubtleLightningGlow(canvas: Canvas, w: Float, h: Float, szScale: Float, opacity: Float) {
        val rng = SeededRNG(99)
        val x = (rng.nextDouble() * w * 0.6 + w * 0.2).toFloat()
        val y = (rng.nextDouble() * h * 0.4 + h * 0.1).toFloat()
        val glowR = 40f * szScale

        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            maskFilter = BlurMaskFilter(20f * szScale, BlurMaskFilter.Blur.NORMAL)
            color = Color.argb((opacity * 255).toInt(), 255, 255, 255)
        }
        canvas.drawCircle(x, y, glowR, paint)
    }

    // ── Hail Stones (static circles, matching iOS) ─────────────

    private fun drawHailStones(canvas: Canvas, w: Float, h: Float, count: Int) {
        val rng = SeededRNG(83)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

        repeat(count) {
            val x = (rng.nextDouble() * w).toFloat()
            val y = (rng.nextDouble() * h).toFloat()
            val radius = (2.0 + rng.nextDouble() * 2.0).toFloat()
            val alpha = (0.28 + rng.nextDouble() * 0.18).toFloat()

            paint.color = Color.argb((alpha * 255).toInt(), 255, 255, 255)
            canvas.drawCircle(x, y, radius, paint)
        }
    }

    // ── Seeded RNG (matches iOS xorshift64, unsigned) ──────────

    private class SeededRNG(seed: Long) {
        private var state: ULong = if (seed == 0L) 1UL else seed.toULong()

        fun next(): ULong {
            state = state xor (state shl 13)
            state = state xor (state shr 7)
            state = state xor (state shl 17)
            return state
        }

        fun nextDouble(): Double {
            return (next() % 10000UL).toDouble() / 10000.0
        }
    }
}
