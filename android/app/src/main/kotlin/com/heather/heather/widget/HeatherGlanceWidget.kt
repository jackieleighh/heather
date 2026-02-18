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
import androidx.compose.ui.unit.DpSize
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

    companion object {
        private val SMALL = DpSize(110.dp, 110.dp)
        private val MEDIUM = DpSize(250.dp, 110.dp)
        private val LARGE = DpSize(250.dp, 250.dp)
    }

    override val sizeMode = SizeMode.Responsive(setOf(SMALL, MEDIUM, LARGE))

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
        val gradientBitmap = createGradientBitmap(data.gradientColors, 500, 500)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(BitmapImageProvider(gradientBitmap))
                .clickable(actionStartActivity<MainActivity>(context))
                .cornerRadius(16.dp)
                .padding(12.dp),
        ) {
            // Persona logo overlay (bottom-right, matching iOS style)
            Box(
                modifier = GlanceModifier.fillMaxSize(),
                contentAlignment = Alignment.BottomEnd,
            ) {
                val logoSize = when {
                    size.width >= 250.dp && size.height >= 250.dp -> 160.dp
                    size.width >= 250.dp -> 100.dp
                    else -> 100.dp
                }
                Image(
                    provider = ImageProvider(ConditionIcons.personaLogoRes(data.persona)),
                    contentDescription = null,
                    modifier = GlanceModifier.size(logoSize),
                )
            }

            when {
                size.width >= 250.dp && size.height >= 250.dp -> LargeContent(data)
                size.width >= 250.dp -> MediumContent(data)
                else -> SmallContent(data)
            }
        }
    }

    @Composable
    private fun SmallContent(data: WeatherWidgetData) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
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
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                    maxLines = 1,
                    modifier = GlanceModifier.defaultWeight(),
                )
                Image(
                    provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                    contentDescription = data.conditionName,
                    modifier = GlanceModifier.size(30.dp),
                    colorFilter = ColorFilter.tint(ColorProvider(white80)),
                )
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Large temp
            Text(
                text = "${data.temperature}°",
                style = TextStyle(
                    color = ColorProvider(white),
                    fontSize = 44.sp,
                    fontWeight = FontWeight.Bold,
                ),
            )

            // H/L
            Text(
                text = "H:${data.high}° L:${data.low}°",
                style = TextStyle(
                    color = ColorProvider(white80),
                    fontSize = 11.sp,
                ),
            )
        }
    }

    @Composable
    private fun MediumContent(data: WeatherWidgetData) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
        ) {
            // Top row: left info + right icon/details
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                // Left: city, temp, H/L, feels like
                Column(modifier = GlanceModifier.defaultWeight()) {
                    Text(
                        text = data.cityName,
                        style = TextStyle(
                            color = ColorProvider(white),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                        maxLines = 1,
                    )

                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = "${data.temperature}°",
                            style = TextStyle(
                                color = ColorProvider(white),
                                fontSize = 36.sp,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                        Spacer(modifier = GlanceModifier.width(4.dp))
                        Text(
                            text = "${data.high}°/${data.low}°",
                            style = TextStyle(
                                color = ColorProvider(white80),
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Medium,
                            ),
                            modifier = GlanceModifier.padding(bottom = 6.dp),
                        )
                    }

                    Text(
                        text = "Feels like ${data.feelsLike}°",
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 10.sp,
                        ),
                    )
                }

                // Right: icon + sun/moon details
                Column(horizontalAlignment = Alignment.End) {
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(data.conditionName, data.isDay)),
                        contentDescription = data.conditionName,
                        modifier = GlanceModifier.size(32.dp),
                        colorFilter = ColorFilter.tint(ColorProvider(white80)),
                    )
                    Spacer(modifier = GlanceModifier.height(2.dp))
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

            // Quip
            Text(
                text = data.quip,
                style = TextStyle(
                    color = ColorProvider(white90),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                ),
                maxLines = 2,
            )

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Hourly forecast row
            if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(8), data.isDay, compact = true)
            }
        }
    }

    @Composable
    private fun LargeContent(data: WeatherWidgetData) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
        ) {
            // City name
            Text(
                text = data.cityName,
                style = TextStyle(
                    color = ColorProvider(white),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Medium,
                ),
                maxLines = 1,
            )

            Spacer(modifier = GlanceModifier.height(2.dp))

            // Temp row with icon + details on right
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.Top,
            ) {
                // Left: temp, H/L, feels like, description
                Column(modifier = GlanceModifier.defaultWeight()) {
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text(
                            text = "${data.temperature}°",
                            style = TextStyle(
                                color = ColorProvider(white),
                                fontSize = 52.sp,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                        Spacer(modifier = GlanceModifier.width(6.dp))
                        Text(
                            text = "${data.high}°/${data.low}°",
                            style = TextStyle(
                                color = ColorProvider(white90),
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                            ),
                            modifier = GlanceModifier.padding(bottom = 10.dp),
                        )
                    }

                    Text(
                        text = "Feels like ${data.feelsLike}°",
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 12.sp,
                        ),
                    )

                    Text(
                        text = data.description.replaceFirstChar { it.uppercase() },
                        style = TextStyle(
                            color = ColorProvider(white70),
                            fontSize = 12.sp,
                        ),
                    )
                }

                // Right: icon + sun/moon details
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

            // Hourly forecast row
            if (data.hourly.isNotEmpty()) {
                HourlyRow(data.hourly.take(8), data.isDay, compact = false)
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            // Quip
            Text(
                text = data.quip,
                style = TextStyle(
                    color = ColorProvider(white95),
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Medium,
                ),
                maxLines = 3,
            )

            Spacer(modifier = GlanceModifier.defaultWeight())
        }
    }

    @Composable
    private fun DetailRow(iconRes: Int, value: String) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Image(
                provider = ImageProvider(iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(11.dp),
                colorFilter = ColorFilter.tint(ColorProvider(white80)),
            )
            Spacer(modifier = GlanceModifier.width(3.dp))
            Text(
                text = value,
                style = TextStyle(
                    color = ColorProvider(white80),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                ),
            )
        }
    }

    @Composable
    private fun HourlyRow(hours: List<HourlyEntry>, isDay: Boolean, compact: Boolean) {
        val iconSize = if (compact) 12.dp else 16.dp
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
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 2.dp))
                    Image(
                        provider = ImageProvider(ConditionIcons.iconRes(entry.conditionName, isDay)),
                        contentDescription = null,
                        modifier = GlanceModifier.size(iconSize),
                        colorFilter = ColorFilter.tint(ColorProvider(white70)),
                    )
                    Spacer(modifier = GlanceModifier.height(if (compact) 1.dp else 2.dp))
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

    private fun createGradientBitmap(hexColors: List<String>, width: Int, height: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val colors = hexColors.map { parseHexColor(it) }.toIntArray()
        if (colors.size < 2) {
            canvas.drawColor(colors.firstOrNull() ?: android.graphics.Color.parseColor("#5B86E5"))
            return bitmap
        }
        val paint = Paint()
        paint.shader = LinearGradient(
            width.toFloat(), 0f,
            0f, height.toFloat(),
            colors,
            null,
            Shader.TileMode.CLAMP,
        )
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
        return bitmap
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
private val white95 = androidx.compose.ui.graphics.Color(0xF2FFFFFF)
private val white90 = androidx.compose.ui.graphics.Color(0xE6FFFFFF)
private val white80 = androidx.compose.ui.graphics.Color(0xCCFFFFFF)
private val white70 = androidx.compose.ui.graphics.Color(0xB3FFFFFF)
