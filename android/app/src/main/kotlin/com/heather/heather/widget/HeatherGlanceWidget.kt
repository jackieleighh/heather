package com.totms.heather.widget

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
        Column(
            modifier = GlanceModifier.fillMaxSize().padding(14.dp),
        ) {
            // Top: city + icon
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                Text(
                    text = data.cityName,
                    style = TextStyle(
                        color = ColorProvider(white),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                    maxLines = 1,
                    modifier = GlanceModifier.defaultWeight(),
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
            Text(
                text = "${data.temperature}°",
                style = TextStyle(
                    color = ColorProvider(white),
                    fontSize = 40.sp,
                    fontWeight = FontWeight.Bold,
                ),
            )

            // H/L (matching iOS format: no H:/L: prefix)
            Text(
                text = "${data.high}°/${data.low}°",
                style = TextStyle(
                    color = ColorProvider(white80),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                ),
            )

            // Feels like
            Text(
                text = "Feels like ${data.feelsLike}°",
                style = TextStyle(
                    color = ColorProvider(white70),
                    fontSize = 9.sp,
                ),
            )

            // Description
            Text(
                text = data.description.replaceFirstChar { it.uppercase() },
                style = TextStyle(
                    color = ColorProvider(white70),
                    fontSize = 9.sp,
                ),
            )
        }
    }

    // ── Medium layout (matching iOS MediumWidgetView) ────────────

    @Composable
    private fun MediumContent(data: WeatherWidgetData) {
        Column(
            modifier = GlanceModifier.fillMaxSize()
                .padding(horizontal = 16.dp, vertical = 14.dp),
        ) {
            // City name
            Text(
                text = data.cityName,
                style = TextStyle(
                    color = ColorProvider(white),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                ),
                maxLines = 1,
            )

            // Details row: temp+info on left, labels+icon on right
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Bottom,
            ) {
                // Left: temp
                Text(
                    text = "${data.temperature}°",
                    style = TextStyle(
                        color = ColorProvider(white),
                        fontSize = 36.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )

                Spacer(modifier = GlanceModifier.width(6.dp))

                // Left: H/L, feels like, description
                Column(modifier = GlanceModifier.defaultWeight().padding(bottom = 6.dp)) {
                    Text(
                        text = "${data.high}°/${data.low}°",
                        style = TextStyle(
                            color = ColorProvider(white80),
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                    )
                    Text(
                        text = "Feels like ${data.feelsLike}°",
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 9.sp,
                        ),
                    )
                    Text(
                        text = data.description.replaceFirstChar { it.uppercase() },
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 9.sp,
                        ),
                    )
                }

                // Right: details + icon
                Column(horizontalAlignment = Alignment.End) {
                    if (data.isDay) {
                        data.sunsetLabel?.let { label ->
                            DetailRow(iconRes = R.drawable.ic_weather_sunset, value = label)
                        }
                        DetailRow(
                            iconRes = R.drawable.ic_weather_uv,
                            value = "UV ${data.uvIndexMax ?: data.uvIndex}",
                        )
                    } else {
                        data.sunriseLabel?.let { label ->
                            DetailRow(iconRes = R.drawable.ic_weather_sunrise, value = label)
                        }
                        val phase = getMoonPhase()
                        DetailRow(iconRes = phase.iconRes, value = "${moonIllumination()}%")
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
                    Text(
                        text = data.cityName,
                        style = TextStyle(
                            color = ColorProvider(white),
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                        maxLines = 1,
                    )

                    Text(
                        text = "${data.temperature}°",
                        style = TextStyle(
                            color = ColorProvider(white),
                            fontSize = 52.sp,
                            fontWeight = FontWeight.Bold,
                        ),
                    )

                    Text(
                        text = "${data.high}°/${data.low}°",
                        style = TextStyle(
                            color = ColorProvider(white90),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                    )

                    Text(
                        text = "Feels like ${data.feelsLike}°",
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 11.sp,
                        ),
                    )

                    Text(
                        text = data.description.replaceFirstChar { it.uppercase() },
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 11.sp,
                        ),
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
                            DetailRow(iconRes = R.drawable.ic_weather_sunset, value = label)
                        }
                        DetailRow(
                            iconRes = R.drawable.ic_weather_uv,
                            value = "UV ${data.uvIndexMax ?: data.uvIndex}",
                        )
                    } else {
                        data.sunriseLabel?.let { label ->
                            DetailRow(iconRes = R.drawable.ic_weather_sunrise, value = label)
                        }
                        val phase = getMoonPhase()
                        DetailRow(iconRes = phase.iconRes, value = "${moonIllumination()}%")
                    }
                }
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Quip (between info and hourly, matching iOS)
            Text(
                text = data.quip,
                style = TextStyle(
                    color = ColorProvider(white95),
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                ),
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
    private fun DetailRow(iconRes: Int, value: String) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(10.dp),
                colorFilter = ColorFilter.tint(ColorProvider(white70)),
            )
            Spacer(modifier = GlanceModifier.width(3.dp))
            Text(
                text = value,
                style = TextStyle(
                    color = ColorProvider(white80),
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Medium,
                ),
            )
        }
    }

    @Composable
    private fun HourlyRow(hours: List<HourlyEntry>, isDay: Boolean, compact: Boolean) {
        val iconSize = if (compact) 24.dp else 28.dp
        val timeFontSize = if (compact) 8.sp else 10.sp
        val tempFontSize = if (compact) 9.sp else 12.sp

        Row(modifier = GlanceModifier.fillMaxWidth()) {
            hours.forEach { entry ->
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Text(
                        text = entry.hourLabel,
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = timeFontSize,
                            textAlign = TextAlign.Center,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(entry.conditionName, isDay)),
                        contentDescription = null,
                        modifier = GlanceModifier.size(iconSize),
                        colorFilter = ColorFilter.tint(ColorProvider(white80)),
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 3.dp))
                    Text(
                        text = "${entry.temperature}°",
                        style = TextStyle(
                            color = ColorProvider(white),
                            fontSize = tempFontSize,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center,
                        ),
                    )
                }
            }
        }
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

        // 3. Draw logo overlay (bottom-right, 0.2 opacity)
        drawLogo(context, canvas, w, h)

        // 4. Draw text contrast scrim (simulates iOS drop shadows)
        WeatherEffectRenderer.drawTextScrim(canvas, w, h)

        return bitmap
    }

    private fun drawLogo(
        context: Context,
        canvas: Canvas,
        w: Float,
        h: Float,
    ) {
        val logoRes = ConditionIcons.personaLogoRes()
        val drawable = androidx.core.content.ContextCompat.getDrawable(context, logoRes) ?: return

        val intrinsicW = drawable.intrinsicWidth.toFloat()
        val intrinsicH = drawable.intrinsicHeight.toFloat()
        if (intrinsicW <= 0 || intrinsicH <= 0) return

        // Scale logo to ~60% of bitmap height, preserving aspect ratio
        val targetH = (h * 0.6f).toInt()
        val targetW = (targetH * (intrinsicW / intrinsicH)).toInt()

        // Position: bottom-right with slight offset
        val left = (w - targetW + targetW * 0.1f).toInt()
        val top = (h - targetH + targetH * 0.08f).toInt()

        drawable.setBounds(left, top, left + targetW, top + targetH)
        drawable.alpha = 51 // 0.2 * 255 = 51
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

private val white = androidx.compose.ui.graphics.Color.White
private val white95 = androidx.compose.ui.graphics.Color(0xF2FFFFFF.toInt())
private val white90 = androidx.compose.ui.graphics.Color(0xE6FFFFFF.toInt())
private val white80 = androidx.compose.ui.graphics.Color(0xCCFFFFFF.toInt())
private val white70 = androidx.compose.ui.graphics.Color(0xB3FFFFFF.toInt())
