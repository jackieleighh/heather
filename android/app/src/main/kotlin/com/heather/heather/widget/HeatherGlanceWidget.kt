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

/**
 * Returns the icon resource for a precipitation label.
 *
 * When the label contains a transition arrow (→), only the current
 * condition (before the arrow) is used for icon selection.
 */
private fun precipIconRes(label: String, isDay: Boolean): Int {
    val text = label.substringBefore("→")
    val lower = text.lowercase()
    return when {
        lower.contains("snow") || lower.contains("flurries") -> R.drawable.ic_weather_snow
        lower.contains("slush") -> R.drawable.ic_weather_rain
        lower.contains("drizzle") || lower.contains("slight rain") ->
            if (isDay) R.drawable.ic_weather_drizzle_day else R.drawable.ic_weather_drizzle_night
        else -> R.drawable.ic_weather_rain
    }
}

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
            modifier = GlanceModifier.fillMaxSize().padding(12.dp),
        ) {
            // Top: city + icon
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                WidgetText(
                    context = context,
                    text = data.cityName,
                    fontRes = R.font.quicksand_bold,
                    sizeSp = 12f,
                    color = 0xFFFFFFFF.toInt(),
                    contentDescription = data.cityName,
                )
                Spacer(modifier = GlanceModifier.defaultWeight())
                Image(
                    provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                    contentDescription = data.conditionName,
                    modifier = GlanceModifier.size(26.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(white90)),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Temperature
            WidgetText(
                context = context,
                text = "${data.temperature}°",
                fontRes = R.font.poppins_bold,
                sizeSp = 48f,
                color = 0xFFFFFFFF.toInt(),
                contentDescription = "${data.temperature} degrees",
            )

            // H/L
            WidgetText(
                context = context,
                text = "${data.high}°/${data.low}°",
                fontRes = R.font.quicksand_semibold,
                sizeSp = 13f,
                color = 0xE6FFFFFF.toInt(),
                contentDescription = "High ${data.high}, Low ${data.low}",
            )

            // Feels like
            WidgetText(
                context = context,
                text = "Feels like ${data.feelsLike}°",
                fontRes = R.font.quicksand_medium,
                sizeSp = 11f,
                color = 0xE6FFFFFF.toInt(),
                contentDescription = "Feels like ${data.feelsLike} degrees",
            )

            // Description or alert
            if (data.alertLabel != null) {
                WidgetText(
                    context = context,
                    text = data.alertLabel,
                    fontRes = R.font.quicksand_semibold,
                    sizeSp = 10f,
                    color = data.alertColor,
                    contentDescription = data.alertLabel,
                )
            } else {
                WidgetText(
                    context = context,
                    text = data.description.replaceFirstChar { it.uppercase() },
                    fontRes = R.font.quicksand_medium,
                    sizeSp = 11f,
                    color = 0xE6FFFFFF.toInt(),
                    contentDescription = data.description,
                )
            }
        }
    }

    // ── Medium layout (matching iOS MediumWidgetView) ────────────

    @Composable
    private fun MediumContent(data: WeatherWidgetData) {
        val context = LocalContext.current
        val hasTimeline = data.widgetSummary != null
        Column(
            modifier = GlanceModifier.fillMaxSize()
                .padding(vertical = 14.dp),
        ) {
            // City name
            WidgetText(
                context = context,
                text = data.cityName,
                fontRes = R.font.quicksand_bold,
                sizeSp = 12f,
                color = 0xFFFFFFFF.toInt(),
                contentDescription = data.cityName,
                modifier = GlanceModifier.padding(horizontal = 16.dp),
            )

            // Details row: temp+info on left, labels+icon on right
            Row(
                modifier = GlanceModifier.fillMaxWidth().padding(horizontal = 16.dp),
                verticalAlignment = Alignment.Top,
            ) {
                // Left: temp
                WidgetText(
                    context = context,
                    text = "${data.temperature}°",
                    fontRes = R.font.poppins_bold,
                    sizeSp = 42f,
                    color = 0xFFFFFFFF.toInt(),
                    contentDescription = "${data.temperature} degrees",
                )

                Spacer(modifier = GlanceModifier.width(6.dp))

                // Left: H/L, feels like, description/alert
                Column(modifier = GlanceModifier.defaultWeight().padding(bottom = 6.dp)) {
                    WidgetText(
                        context = context,
                        text = "${data.high}°/${data.low}°",
                        fontRes = R.font.quicksand_semibold,
                        sizeSp = 15f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = "High ${data.high}, Low ${data.low}",
                    )
                    WidgetText(
                        context = context,
                        text = "Feels like ${data.feelsLike}°",
                        fontRes = R.font.quicksand_medium,
                        sizeSp = 11f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = "Feels like ${data.feelsLike} degrees",
                    )
                    if (hasTimeline && data.alertLabel != null) {
                        DetailRow(
                            context,
                            iconRes = data.alertIconRes,
                            value = data.alertLabel,
                            tintColor = data.alertColor,
                            iconSize = 9, fontSize = 10f, spacing = 2,
                        )
                    } else {
                        WidgetText(
                            context = context,
                            text = data.description.replaceFirstChar { it.uppercase() },
                            fontRes = R.font.quicksand_medium,
                            sizeSp = 11f,
                            color = 0xE6FFFFFF.toInt(),
                            contentDescription = data.description,
                        )
                    }
                }

                // Right: details + icon
                Column(horizontalAlignment = Alignment.End) {
                    Row(verticalAlignment = Alignment.Bottom) {
                        Column(horizontalAlignment = Alignment.End) {
                            if (data.isDay) {
                                data.sunsetLabel?.let { label ->
                                    DetailRow(context, iconRes = R.drawable.ic_weather_sunset, value = label, iconSize = 9, fontSize = 11f, spacing = 3)
                                }
                                DetailRow(
                                    context,
                                    iconRes = R.drawable.ic_weather_uv,
                                    value = "UV ${data.uvIndexMax ?: data.uvIndex}",
                                    iconSize = 9, fontSize = 11f, spacing = 3,
                                )
                            } else {
                                data.sunriseLabel?.let { label ->
                                    DetailRow(context, iconRes = R.drawable.ic_weather_sunrise, value = label, iconSize = 9, fontSize = 11f, spacing = 3)
                                }
                                val moonIcon = R.drawable.ic_moon_waxing_crescent
                                val moonIllum = data.moonIllumination ?: moonIllumination()
                                DetailRow(context, iconRes = moonIcon, value = "${moonIllum}%", iconSize = 9, fontSize = 11f, spacing = 3)
                            }
                        }
                        Spacer(modifier = GlanceModifier.width(4.dp))
                        Image(
                            provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                            contentDescription = data.conditionName,
                            modifier = GlanceModifier.size(32.dp),
                            colorFilter = ColorFilter.tint(ColorProvider(white90)),
                        )
                    }
                    if (!hasTimeline) {
                        if (data.alertLabel != null) {
                            DetailRow(
                                context,
                                iconRes = data.alertIconRes,
                                value = data.alertLabel,
                                tintColor = data.alertColor,
                                iconSize = 9, fontSize = 11f, spacing = 3,
                            )
                        } else if (data.precipLabel != null) {
                            DetailRow(
                                context,
                                iconRes = precipIconRes(data.precipLabel, data.isDay),
                                value = data.precipLabel,
                                iconSize = 9, fontSize = 11f, spacing = 3,
                            )
                        } else {
                            Spacer(modifier = GlanceModifier.height(14.dp))
                        }
                    }
                }
            }

            Spacer(modifier = GlanceModifier.height(6.dp))

            // Summary tagline (full width, between info and timeline)
            if (hasTimeline) {
                val summary = data.widgetSummary
                if (summary != null && (data.summaryIsDay == null || data.summaryIsDay == data.isDay)) {
                    WidgetText(
                        context = context,
                        text = summary,
                        fontRes = R.font.quicksand_medium,
                        sizeSp = 12f,
                        color = 0xF2FFFFFF.toInt(),
                        contentDescription = summary,
                        maxLines = 2,
                        modifier = GlanceModifier.padding(horizontal = 16.dp),
                    )
                    Spacer(modifier = GlanceModifier.defaultWeight())
                }
            }

            // Bottom: timeline or hourly forecast
            if (hasTimeline && data.timelineSegments.isNotEmpty()) {
                TimelineBar(context, data)
            } else if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(6), compact = true)
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
                    WidgetText(
                        context = context,
                        text = data.cityName,
                        fontRes = R.font.quicksand_bold,
                        sizeSp = 15f,
                        color = 0xFFFFFFFF.toInt(),
                        contentDescription = data.cityName,
                    )

                    WidgetText(
                        context = context,
                        text = "${data.temperature}°",
                        fontRes = R.font.poppins_bold,
                        sizeSp = 58f,
                        color = 0xFFFFFFFF.toInt(),
                        contentDescription = "${data.temperature} degrees",
                    )

                    WidgetText(
                        context = context,
                        text = "${data.high}°/${data.low}°",
                        fontRes = R.font.quicksand_semibold,
                        sizeSp = 13f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = "High ${data.high}, Low ${data.low}",
                    )

                    WidgetText(
                        context = context,
                        text = "Feels like ${data.feelsLike}°",
                        fontRes = R.font.quicksand_medium,
                        sizeSp = 12f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = "Feels like ${data.feelsLike} degrees",
                    )

                    WidgetText(
                        context = context,
                        text = data.description.replaceFirstChar { it.uppercase() },
                        fontRes = R.font.quicksand_medium,
                        sizeSp = 12f,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = data.description,
                    )
                }

                // Right column: icon + details + summary
                Column(
                    horizontalAlignment = Alignment.End,
                    modifier = GlanceModifier.padding(start = 12.dp),
                ) {
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                        contentDescription = data.conditionName,
                        modifier = GlanceModifier.size(48.dp),
                        colorFilter = ColorFilter.tint(ColorProvider(white90)),
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
                        val moonIcon = R.drawable.ic_moon_waxing_crescent
                        val moonIllum = data.moonIllumination ?: moonIllumination()
                        DetailRow(context, iconRes = moonIcon, value = "${moonIllum}%")
                    }
                    if (data.alertLabel != null) {
                        DetailRow(
                            context,
                            iconRes = data.alertIconRes,
                            value = data.alertLabel,
                            tintColor = data.alertColor,
                        )
                    } else if (data.precipLabel != null) {
                        DetailRow(
                            context,
                            iconRes = precipIconRes(data.precipLabel, data.isDay),
                            value = data.precipLabel,
                        )
                    } else {
                        Spacer(modifier = GlanceModifier.height(16.dp))
                    }
                    // Summary tagline under detail rows
                    val summary = data.widgetSummary
                    if (summary != null && (data.summaryIsDay == null || data.summaryIsDay == data.isDay)) {
                        Spacer(modifier = GlanceModifier.height(4.dp))
                        WidgetText(
                            context = context,
                            text = summary,
                            fontRes = R.font.quicksand_medium,
                            sizeSp = 11f,
                            color = 0xF2FFFFFF.toInt(),
                            contentDescription = summary,
                            maxLines = 3,
                            textAlign = Paint.Align.RIGHT,
                            maxWidthDp = 170,
                        )
                    }
                }
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Quip
            WidgetText(
                context = context,
                text = data.quip,
                fontRes = R.font.poppins_regular,
                sizeSp = 16f,
                color = 0xF2FFFFFF.toInt(),
                contentDescription = data.quip,
                maxLines = 3,
            )

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Timeline (replaces hourly forecast)
            if (data.timelineSegments.isNotEmpty()) {
                TimelineBar(context, data)
            } else if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(6), compact = false)
            }
        }
    }

    // ── Shared components ────────────────────────────────────────

    @Composable
    private fun DetailRow(
        context: Context,
        iconRes: Int,
        value: String,
        tintColor: Int? = null,
        iconSize: Int = 11,
        fontSize: Float = 12f,
        spacing: Int = 4,
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(iconSize.dp),
                colorFilter = ColorFilter.tint(
                    ColorProvider(
                        if (tintColor != null) androidx.compose.ui.graphics.Color(tintColor)
                        else white90
                    )
                ),
            )
            Spacer(modifier = GlanceModifier.width(spacing.dp))
            WidgetText(
                context = context,
                text = value,
                fontRes = R.font.poppins_semibold,
                sizeSp = fontSize,
                color = tintColor ?: 0xE6FFFFFF.toInt(),
                contentDescription = value,
            )
        }
    }

    @Composable
    private fun HourlyRow(hours: List<HourlyEntry>, compact: Boolean) {
        val context = LocalContext.current
        val iconSize = if (compact) 24.dp else 28.dp
        val timeFontSize = if (compact) 10f else 11f
        val tempFontSize = if (compact) 11f else 13f

        Row(modifier = GlanceModifier.fillMaxWidth()) {
            hours.forEach { entry ->
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    WidgetText(
                        context = context,
                        text = entry.hourLabel,
                        fontRes = R.font.quicksand_medium,
                        sizeSp = timeFontSize,
                        color = 0xE6FFFFFF.toInt(),
                        contentDescription = entry.hourLabel,
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(entry.conditionName, entry.isDay)),
                        contentDescription = null,
                        modifier = GlanceModifier.size(iconSize),
                        colorFilter = ColorFilter.tint(ColorProvider(white90)),
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    WidgetText(
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

    // ── Text as bitmap ────────────────────────────────────────────

    @Composable
    private fun WidgetText(
        context: Context,
        text: String,
        fontRes: Int,
        sizeSp: Float,
        color: Int,
        contentDescription: String,
        modifier: GlanceModifier = GlanceModifier,
        maxLines: Int = 1,
        textAlign: Paint.Align = Paint.Align.LEFT,
        maxWidthDp: Int = 300,
    ) {
        val bitmap = renderTextBitmap(context, text, fontRes, sizeSp, color, maxLines, textAlign, maxWidthDp)
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
        textAlign: Paint.Align = Paint.Align.LEFT,
        maxWidthDp: Int = 300,
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
        val maxWidth = (maxWidthDp * context.resources.displayMetrics.density).toInt()
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
            val x = when (textAlign) {
                Paint.Align.RIGHT -> totalWidth - paint.measureText(line) - 1
                Paint.Align.CENTER -> (totalWidth - paint.measureText(line)) / 2
                else -> 0f
            }
            canvas.drawText(line, x, -metrics.ascent + lineHeight * i, paint)
        }
        return bitmap
    }

    private fun Int.pxToDp(context: Context): Int {
        return (this / context.resources.displayMetrics.density).toInt()
    }

    // ── Timeline bar (bitmap-rendered graph) ─────────────────────

    @Composable
    private fun TimelineBar(context: Context, data: WeatherWidgetData) {
        val widgetWidthPx = (LocalSize.current.width.value * context.resources.displayMetrics.density).toInt()
        val bitmap = renderTimelineBitmap(
            context = context,
            segments = data.timelineSegments,
            hasPrecip = data.hasPrecipInTimeline ?: false,
            utcOffsetSeconds = data.utcOffsetSeconds,
            widthPx = widgetWidthPx,
        )
        Image(
            provider = BitmapImageProvider(bitmap),
            contentDescription = "12 hour forecast",
            modifier = GlanceModifier.fillMaxWidth().height(bitmap.height.pxToDp(context).dp),
            contentScale = ContentScale.FillBounds,
        )
    }

    private fun renderTimelineBitmap(
        context: Context,
        segments: List<TimelineSegment>,
        hasPrecip: Boolean,
        utcOffsetSeconds: Int?,
        widthPx: Int = 0,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val sd = context.resources.displayMetrics.scaledDensity
        val bitmapW = if (widthPx > 0) widthPx else (300 * density).toInt().coerceAtLeast(1)
        val graphH = 32 * density
        val labelH = 12 * density
        val gap = 3 * density
        val totalH = (graphH + gap + labelH).toInt().coerceAtLeast(1)

        val bitmap = Bitmap.createBitmap(bitmapW, totalH, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val wf = bitmapW.toFloat()

        if (hasPrecip) {
            drawPrecipBars(context, canvas, segments, density, sd, wf, graphH)
        } else {
            drawTempCurve(context, canvas, segments, density, sd, wf, graphH)
        }

        // Time labels
        val timePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = ResourcesCompat.getFont(context, R.font.quicksand_medium) ?: Typeface.DEFAULT
            textSize = 9 * sd
            color = 0x99FFFFFF.toInt()
        }
        val labels = buildTimeLabels(utcOffsetSeconds)
        val labelY = graphH + gap + (-timePaint.fontMetrics.ascent)
        val tempPadX = 18 * density
        val precipPadRight = 8 * density
        val labelStartX = if (hasPrecip) 24 * density else tempPadX
        val labelAreaW = if (hasPrecip) wf - labelStartX - precipPadRight else wf - 2 * tempPadX

        labels.forEachIndexed { i, label ->
            val frac = if (labels.size <= 1) 0f else i.toFloat() / (labels.size - 1)
            val x = labelStartX + labelAreaW * frac
            timePaint.textAlign = when (i) {
                0 -> Paint.Align.LEFT
                labels.size - 1 -> Paint.Align.RIGHT
                else -> Paint.Align.CENTER
            }
            canvas.drawText(label, x, labelY, timePaint)
        }

        return bitmap
    }

    private fun drawPrecipBars(
        context: Context,
        canvas: Canvas,
        segments: List<TimelineSegment>,
        density: Float,
        sd: Float,
        width: Float,
        graphH: Float,
    ) {
        val labelW = 24 * density
        val padRight = 8 * density
        val graphW = width - labelW - padRight

        // Y-axis labels
        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = ResourcesCompat.getFont(context, R.font.poppins_semibold) ?: Typeface.DEFAULT
            textSize = 8 * sd
            color = 0xB3FFFFFF.toInt()
            textAlign = Paint.Align.RIGHT
        }
        val fm = labelPaint.fontMetrics
        val textH = -fm.ascent + fm.descent
        canvas.drawText("100%", labelW - 2 * density, -fm.ascent, labelPaint)
        canvas.drawText("50%", labelW - 2 * density, graphH / 2 - textH / 2 - fm.ascent, labelPaint)
        canvas.drawText("0%", labelW - 2 * density, graphH + fm.descent, labelPaint)

        // Sample at hourly intervals
        val targetMinutes = (0..720 step 60).toList()
        val probs = targetMinutes.map { target ->
            segments.minByOrNull { Math.abs(it.minuteOffset - target) }?.precipProbability ?: 0
        }

        val slotW = graphW / probs.size
        val barGap = 1.5f * density
        val barW = (slotW - barGap).coerceAtLeast(1f)

        // Grid line at 50%
        val gridPaint = Paint().apply {
            color = 0x26FFFFFF.toInt()
            strokeWidth = 0.5f * density
        }
        canvas.drawLine(labelW, graphH * 0.5f, labelW + graphW, graphH * 0.5f, gridPaint)

        // Bars
        val barPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        probs.forEachIndexed { i, prob ->
            val pct = prob / 100f
            val barH = (graphH * pct).coerceAtLeast(if (pct > 0) 2 * density else 0f)
            val alpha = ((0.45f + 0.45f * pct) * 255).toInt().coerceIn(0, 255)
            barPaint.color = (alpha shl 24) or 0x00FFFFFF

            val x = labelW + i * slotW + (slotW - barW) / 2
            canvas.drawRoundRect(x, graphH - barH, x + barW, graphH, 1.5f * density, 1.5f * density, barPaint)
        }

        // "Now" indicator line
        val nowPaint = Paint().apply {
            color = 0x80FFFFFF.toInt()
            strokeWidth = 1f * density
        }
        canvas.drawLine(labelW + slotW / 2, 0f, labelW + slotW / 2, graphH, nowPaint)
    }

    private fun drawTempCurve(
        context: Context,
        canvas: Canvas,
        segments: List<TimelineSegment>,
        density: Float,
        sd: Float,
        width: Float,
        graphH: Float,
    ) {
        val targetMinutes = listOf(0, 180, 360, 540, 720)
        val temps = targetMinutes.mapNotNull { target ->
            segments.minByOrNull { Math.abs(it.minuteOffset - target) }?.temperature
        }
        if (temps.size < 2) return

        val minTemp = temps.min().toFloat()
        val maxTemp = temps.max().toFloat()
        val range = (maxTemp - minTemp).coerceAtLeast(1f)

        // Horizontal padding so edge labels don't clip
        val padX = 18 * density
        val drawW = width - 2 * padX

        val points = temps.mapIndexed { i, temp ->
            val x = padX + drawW * i / (temps.size - 1)
            val y = graphH - ((temp - minTemp) / range) * graphH * 0.7f - graphH * 0.15f
            android.graphics.PointF(x, y)
        }

        // Smooth cubic Bezier curve
        val curvePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = 0x99FFFFFF.toInt()
            strokeWidth = 1.5f * density
            style = Paint.Style.STROKE
        }
        val path = android.graphics.Path()
        path.moveTo(points[0].x, points[0].y)
        for (i in 1 until points.size) {
            val cpx = (points[i - 1].x + points[i].x) / 2
            path.cubicTo(cpx, points[i - 1].y, cpx, points[i].y, points[i].x, points[i].y)
        }
        canvas.drawPath(path, curvePaint)

        // "Now" dot
        val dotPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = 0xFFFFFFFF.toInt()
            style = Paint.Style.FILL
        }
        canvas.drawCircle(points[0].x, points[0].y, 2.5f * density, dotPaint)

        // Temp labels at each point
        val tempPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            typeface = ResourcesCompat.getFont(context, R.font.poppins_semibold) ?: Typeface.DEFAULT
            textSize = 9 * sd
            color = 0xE6FFFFFF.toInt()
            textAlign = Paint.Align.CENTER
        }
        temps.forEachIndexed { i, temp ->
            canvas.drawText("${temp}°", points[i].x, points[i].y - 8 * density, tempPaint)
        }
    }

    private fun buildTimeLabels(utcOffsetSeconds: Int?): List<String> {
        val labels = mutableListOf("now")
        val tz = utcOffsetSeconds?.let {
            java.util.TimeZone.getTimeZone(
                "GMT${if (it >= 0) "+" else ""}${it / 3600}:${"%02d".format((Math.abs(it) % 3600) / 60)}"
            )
        } ?: java.util.TimeZone.getDefault()
        val cal = java.util.Calendar.getInstance(tz)
        for (offset in listOf(3, 6, 9, 12)) {
            val future = java.util.Calendar.getInstance(tz).apply {
                timeInMillis = cal.timeInMillis
                add(java.util.Calendar.HOUR_OF_DAY, offset)
            }
            val hour = future.get(java.util.Calendar.HOUR_OF_DAY)
            val h12 = if (hour % 12 == 0) 12 else hour % 12
            val ampm = if (hour >= 12) "pm" else "am"
            labels.add("$h12$ampm")
        }
        return labels
    }

    // ── Bitmap creation (gradient + weather effects + scrim) ─────

    private fun createWeatherBitmap(
        context: Context,
        hexColors: List<String>,
        conditionName: String,
        isDay: Boolean,
        width: Int,
        height: Int,
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
            paint.shader = LinearGradient(w, 0f, 0f, h, colors, null, Shader.TileMode.CLAMP)
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

private val white90 = androidx.compose.ui.graphics.Color(0xE6FFFFFF.toInt())
