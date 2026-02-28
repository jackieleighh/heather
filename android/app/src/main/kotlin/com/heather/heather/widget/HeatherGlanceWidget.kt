package com.totms.heather.widget

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.graphics.Typeface
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.res.ResourcesCompat
import androidx.glance.BitmapImageProvider
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.totms.heather.MainActivity
import com.totms.heather.R
import es.antonborri.home_widget.actionStartActivity

class HeatherGlanceWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val data = WeatherWidgetData.fromPreferences(state.preferences)
            WidgetContent(data)
        }
    }

    @Composable
    private fun WidgetContent(data: WeatherWidgetData) {
        val size = LocalSize.current
        val context = LocalContext.current

        // Gradient direction: diagonal for sunny/mostlySunny, vertical for others (matching iOS)
        val diagonalGradient = data.conditionName == "sunny" || data.conditionName == "mostlySunny"
                || size.width < 250.dp // Small widget always uses diagonal

        // Match bitmap aspect ratio to widget size so the background
        // doesn't stretch/distort the logo overlay.
        val bitmapLong = 500
        val aspectRatio = size.width.value / size.height.value
        val bitmapW: Int
        val bitmapH: Int
        if (aspectRatio >= 1f) {
            bitmapW = bitmapLong
            bitmapH = (bitmapLong / aspectRatio).toInt().coerceAtLeast(1)
        } else {
            bitmapH = bitmapLong
            bitmapW = (bitmapLong * aspectRatio).toInt().coerceAtLeast(1)
        }

        val gradientBitmap = createWeatherBitmap(
            context = context,
            hexColors = data.gradientColors,
            conditionName = data.conditionName,
            isDay = data.isDay,
            width = bitmapW,
            height = bitmapH,
            diagonalGradient = diagonalGradient,
        )

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(BitmapImageProvider(gradientBitmap))
                .clickable(actionStartActivity<MainActivity>(context))
                .cornerRadius(16.dp),
        ) {
            when {
                size.width >= 250.dp && size.height >= 250.dp -> LargeContent(data)
                size.width >= 250.dp -> MediumContent(data)
                else -> SmallContent(data)
            }
        }
    }

    // ── Small layout (matching iOS SmallWidgetView) ──────────────

    @Composable
    private fun SmallContent(data: WeatherWidgetData) {
        val context = LocalContext.current
        Column(
            modifier = GlanceModifier.fillMaxSize().padding(14.dp),
        ) {
            // Top: city + icon
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                PoppinsText(
                    context = context,
                    text = data.cityName,
                    fontRes = R.font.poppins_medium,
                    sizeSp = 12f,
                    color = 0xFFFFFFFF.toInt(),
                    modifier = GlanceModifier.defaultWeight(),
                    contentDescription = data.cityName,
                )
                Image(
                    provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                    contentDescription = data.conditionName,
                    modifier = GlanceModifier.size(26.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(white80)),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Temperature
            PoppinsText(
                context = context,
                text = "${data.temperature}°",
                fontRes = R.font.poppins_semibold,
                sizeSp = 50f,
                color = 0xFFFFFFFF.toInt(),
                contentDescription = "${data.temperature} degrees",
            )

            // H/L
            PoppinsText(
                context = context,
                text = "${data.high}°/${data.low}°",
                fontRes = R.font.poppins_medium,
                sizeSp = 12f,
                color = 0xCCFFFFFF.toInt(),
                contentDescription = "High ${data.high}, Low ${data.low}",
            )

            // Feels like
            PoppinsText(
                context = context,
                text = "Feels like ${data.feelsLike}°",
                fontRes = R.font.poppins_regular,
                sizeSp = 10f,
                color = 0xB3FFFFFF.toInt(),
                contentDescription = "Feels like ${data.feelsLike} degrees",
            )

            // Description
            PoppinsText(
                context = context,
                text = data.description.replaceFirstChar { it.uppercase() },
                fontRes = R.font.poppins_regular,
                sizeSp = 10f,
                color = 0xB3FFFFFF.toInt(),
                contentDescription = data.description,
            )
        }
    }

    // ── Medium layout (matching iOS MediumWidgetView) ────────────

    @Composable
    private fun MediumContent(data: WeatherWidgetData) {
        val context = LocalContext.current
        Column(
            modifier = GlanceModifier.fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 14.dp),
        ) {
            // City name
            PoppinsText(
                context = context,
                text = data.cityName,
                fontRes = R.font.poppins_medium,
                sizeSp = 12f,
                color = 0xFFFFFFFF.toInt(),
                contentDescription = data.cityName,
            )

            // Details row: temp+info on left, labels+icon on right
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Bottom,
            ) {
                // Left: temp
                PoppinsText(
                    context = context,
                    text = "${data.temperature}°",
                    fontRes = R.font.poppins_semibold,
                    sizeSp = 42f,
                    color = 0xFFFFFFFF.toInt(),
                    contentDescription = "${data.temperature} degrees",
                )

                Spacer(modifier = GlanceModifier.width(6.dp))

                // Left: H/L, feels like, description
                Column(modifier = GlanceModifier.defaultWeight().padding(bottom = 6.dp)) {
                    PoppinsText(
                        context = context,
                        text = "${data.high}°/${data.low}°",
                        fontRes = R.font.poppins_medium,
                        sizeSp = 12f,
                        color = 0xCCFFFFFF.toInt(),
                        contentDescription = "High ${data.high}, Low ${data.low}",
                    )
                    PoppinsText(
                        context = context,
                        text = "Feels like ${data.feelsLike}°",
                        fontRes = R.font.poppins_regular,
                        sizeSp = 10f,
                        color = 0xB3FFFFFF.toInt(),
                        contentDescription = "Feels like ${data.feelsLike} degrees",
                    )
                    PoppinsText(
                        context = context,
                        text = data.description.replaceFirstChar { it.uppercase() },
                        fontRes = R.font.poppins_regular,
                        sizeSp = 10f,
                        color = 0xB3FFFFFF.toInt(),
                        contentDescription = data.description,
                    )
                }

                // Right: details + icon
                Column(horizontalAlignment = Alignment.End) {
                    if (data.isDay) {
                        data.sunsetLabel?.let { label ->
                            DetailRow(context, iconRes = R.drawable.ic_weather_sunset, value = label)
                        }
                        DetailRow(
                            context,
                            iconRes = R.drawable.ic_weather_uv,
                            value = "UV ${data.uvIndexMax ?: data.uvIndex}",
                        )
                    } else {
                        data.sunriseLabel?.let { label ->
                            DetailRow(context, iconRes = R.drawable.ic_weather_sunrise, value = label)
                        }
                        val phase = getMoonPhase()
                        DetailRow(context, iconRes = phase.iconRes, value = "${moonIllumination()}%")
                    }
                }

                Spacer(modifier = GlanceModifier.width(4.dp))

                Image(
                    provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                    contentDescription = data.conditionName,
                    modifier = GlanceModifier.size(32.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(white80)),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Hourly forecast (6 items, matching iOS)
            if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(6), data.isDay, compact = true)
            }
        }
    }

    // ── Large layout (matching iOS LargeWidgetView) ──────────────

    @Composable
    private fun LargeContent(data: WeatherWidgetData) {
        val context = LocalContext.current
        Column(
            modifier = GlanceModifier.fillMaxSize().padding(16.dp),
        ) {
            // Two-column layout: left info, right icon+details
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                // Left column
                Column(modifier = GlanceModifier.defaultWeight()) {
                    PoppinsText(
                        context = context,
                        text = data.cityName,
                        fontRes = R.font.poppins_medium,
                        sizeSp = 15f,
                        color = 0xFFFFFFFF.toInt(),
                        contentDescription = data.cityName,
                    )

                    PoppinsText(
                        context = context,
                        text = "${data.temperature}°",
                        fontRes = R.font.poppins_semibold,
                        sizeSp = 58f,
                        color = 0xFFFFFFFF.toInt(),
                        contentDescription = "${data.temperature} degrees",
                    )

                    PoppinsText(
                        context = context,
                        text = "${data.high}°/${data.low}°",
                        fontRes = R.font.poppins_medium,
                        sizeSp = 13f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = "High ${data.high}, Low ${data.low}",
                    )

                    PoppinsText(
                        context = context,
                        text = "Feels like ${data.feelsLike}°",
                        fontRes = R.font.poppins_regular,
                        sizeSp = 12f,
                        color = 0xB3FFFFFF.toInt(),
                        contentDescription = "Feels like ${data.feelsLike} degrees",
                    )

                    PoppinsText(
                        context = context,
                        text = data.description.replaceFirstChar { it.uppercase() },
                        fontRes = R.font.poppins_regular,
                        sizeSp = 12f,
                        color = 0xB3FFFFFF.toInt(),
                        contentDescription = data.description,
                    )
                }

                // Right column: icon + details
                Column(horizontalAlignment = Alignment.End) {
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                        contentDescription = data.conditionName,
                        modifier = GlanceModifier.size(48.dp),
                        colorFilter = ColorFilter.tint(ColorProvider(white80)),
                    )
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    if (data.isDay) {
                        data.sunsetLabel?.let { label ->
                            DetailRow(context, iconRes = R.drawable.ic_weather_sunset, value = label)
                        }
                        DetailRow(
                            context,
                            iconRes = R.drawable.ic_weather_uv,
                            value = "UV ${data.uvIndexMax ?: data.uvIndex}",
                        )
                    } else {
                        data.sunriseLabel?.let { label ->
                            DetailRow(context, iconRes = R.drawable.ic_weather_sunrise, value = label)
                        }
                        val phase = getMoonPhase()
                        DetailRow(context, iconRes = phase.iconRes, value = "${moonIllumination()}%")
                    }
                }
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Quip (between info and hourly, matching iOS)
            PoppinsText(
                context = context,
                text = data.quip,
                fontRes = R.font.poppins_medium,
                sizeSp = 14f,
                color = 0xF2FFFFFF.toInt(),
                contentDescription = data.quip,
                maxLines = 3,
            )

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Hourly forecast (6 items, matching iOS)
            if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(6), data.isDay, compact = false)
            }
        }
    }

    // ── Shared components ────────────────────────────────────────

    @Composable
    private fun DetailRow(context: Context, iconRes: Int, value: String) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(11.dp),
                colorFilter = ColorFilter.tint(ColorProvider(white70)),
            )
            Spacer(modifier = GlanceModifier.width(3.dp))
            PoppinsText(
                context = context,
                text = value,
                fontRes = R.font.poppins_semibold,
                sizeSp = 11f,
                color = 0xCCFFFFFF.toInt(),
                contentDescription = value,
            )
        }
    }

    @Composable
    private fun HourlyRow(hours: List<HourlyEntry>, isDay: Boolean, compact: Boolean) {
        val context = LocalContext.current
        val iconSize = if (compact) 24.dp else 28.dp
        val timeFontSize = if (compact) 9f else 11f
        val tempFontSize = if (compact) 10f else 13f

        Row(modifier = GlanceModifier.fillMaxWidth()) {
            hours.forEach { entry ->
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    PoppinsText(
                        context = context,
                        text = entry.hourLabel,
                        fontRes = R.font.poppins_regular,
                        sizeSp = timeFontSize,
                        color = 0xB3FFFFFF.toInt(),
                        contentDescription = entry.hourLabel,
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(entry.conditionName, isDay)),
                        contentDescription = null,
                        modifier = GlanceModifier.size(iconSize),
                        colorFilter = ColorFilter.tint(ColorProvider(white80)),
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    PoppinsText(
                        context = context,
                        text = "${entry.temperature}°",
                        fontRes = R.font.poppins_semibold,
                        sizeSp = tempFontSize,
                        color = 0xFFFFFFFF.toInt(),
                        contentDescription = "${entry.temperature} degrees",
                    )
                }
            }
        }
    }

    // ── Poppins text as bitmap ─────────────────────────────────────

    @Composable
    private fun PoppinsText(
        context: Context,
        text: String,
        fontRes: Int,
        sizeSp: Float,
        color: Int,
        contentDescription: String,
        modifier: GlanceModifier = GlanceModifier,
        maxLines: Int = 1,
    ) {
        val bitmap = renderTextBitmap(context, text, fontRes, sizeSp, color, maxLines)
        Image(
            provider = BitmapImageProvider(bitmap),
            contentDescription = contentDescription,
            modifier = modifier.height(bitmap.height.pxToDp(context).dp),
            contentScale = ContentScale.Fit,
        )
    }

    private fun renderTextBitmap(
        context: Context,
        text: String,
        fontRes: Int,
        sizeSp: Float,
        color: Int,
        maxLines: Int,
    ): Bitmap {
        val scaledDensity = context.resources.displayMetrics.scaledDensity
        val typeface = ResourcesCompat.getFont(context, fontRes) ?: Typeface.DEFAULT
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.typeface = typeface
            this.textSize = sizeSp * scaledDensity
            this.color = color
        }

        if (maxLines == 1) {
            val width = (paint.measureText(text) + 2).toInt().coerceAtLeast(1)
            val metrics = paint.fontMetrics
            val height = (metrics.descent - metrics.ascent + metrics.leading + 2).toInt().coerceAtLeast(1)
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            canvas.drawText(text, 0f, -metrics.ascent, paint)
            return bitmap
        }

        // Multi-line: wrap text manually
        val maxWidth = (300 * context.resources.displayMetrics.density).toInt()
        val words = text.split(" ")
        val lines = mutableListOf<String>()
        var currentLine = ""

        for (word in words) {
            val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"
            if (paint.measureText(testLine) <= maxWidth) {
                currentLine = testLine
            } else {
                if (currentLine.isNotEmpty()) lines.add(currentLine)
                currentLine = word
                if (lines.size >= maxLines) break
            }
        }
        if (currentLine.isNotEmpty() && lines.size < maxLines) {
            lines.add(currentLine)
        }

        val metrics = paint.fontMetrics
        val lineHeight = metrics.descent - metrics.ascent + metrics.leading
        val totalHeight = (lineHeight * lines.size + 2).toInt().coerceAtLeast(1)
        val totalWidth = lines.maxOfOrNull { paint.measureText(it).toInt() }?.plus(2)?.coerceAtLeast(1) ?: 1

        val bitmap = Bitmap.createBitmap(totalWidth, totalHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        lines.forEachIndexed { i, line ->
            canvas.drawText(line, 0f, -metrics.ascent + lineHeight * i, paint)
        }
        return bitmap
    }

    private fun Int.pxToDp(context: Context): Int {
        return (this / context.resources.displayMetrics.density).toInt()
    }

    // ── Bitmap creation (gradient + weather effects + scrim) ─────

    private fun createWeatherBitmap(
        context: Context,
        hexColors: List<String>,
        conditionName: String,
        isDay: Boolean,
        width: Int,
        height: Int,
        diagonalGradient: Boolean,
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val w = width.toFloat()
        val h = height.toFloat()

        // 1. Draw gradient background
        val colors = hexColors.map { parseHexColor(it) }.toIntArray()
        if (colors.size < 2) {
            canvas.drawColor(colors.firstOrNull() ?: android.graphics.Color.parseColor("#5B86E5"))
        } else {
            val paint = Paint()
            paint.shader = if (diagonalGradient) {
                LinearGradient(w, 0f, 0f, h, colors, null, Shader.TileMode.CLAMP)
            } else {
                LinearGradient(0f, 0f, 0f, h, colors, null, Shader.TileMode.CLAMP)
            }
            canvas.drawRect(0f, 0f, w, h, paint)
        }

        // 2. Draw weather effects
        WeatherEffectRenderer.render(canvas, conditionName, isDay, w, h)

        // 3. Draw logo overlay (more visible at night)
        drawLogo(context, canvas, w, h, isDay)

        // 4. Draw text contrast scrim (simulates iOS drop shadows)
        WeatherEffectRenderer.drawTextScrim(canvas, w, h)

        return bitmap
    }

    private fun drawLogo(
        context: Context,
        canvas: Canvas,
        w: Float,
        h: Float,
        isDay: Boolean,
    ) {
        val logoRes = ConditionIcons.personaLogoRes()
        val drawable = androidx.core.content.ContextCompat.getDrawable(context, logoRes) ?: return

        val intrinsicW = drawable.intrinsicWidth.toFloat()
        val intrinsicH = drawable.intrinsicHeight.toFloat()
        if (intrinsicW <= 0 || intrinsicH <= 0) return

        // Scale logo: ~70% for medium (wide) widgets, ~60% otherwise
        val isWide = w / h > 1.4f
        val scale = if (isWide) 0.7f else 0.6f
        val targetH = (h * scale).toInt()
        val targetW = (targetH * (intrinsicW / intrinsicH)).toInt()

        // Position: bottom-right with slight offset
        val left = (w - targetW + targetW * 0.05f).toInt()
        val top = (h - targetH + targetH * 0.08f).toInt()

        drawable.setBounds(left, top, left + targetW, top + targetH)
        drawable.alpha = if (isDay) 51 else 102 // day: 0.2, night: 0.4
        drawable.draw(canvas)
    }

    private fun parseHexColor(hex: String): Int {
        val cleaned = hex.removePrefix("#")
        return when (cleaned.length) {
            8 -> android.graphics.Color.parseColor("#$cleaned")
            6 -> android.graphics.Color.parseColor("#FF$cleaned")
            else -> android.graphics.Color.parseColor("#FF5B86E5")
        }
    }
}

private val white80 = androidx.compose.ui.graphics.Color(0xCCFFFFFF.toInt())
private val white70 = androidx.compose.ui.graphics.Color(0xB3FFFFFF.toInt())
