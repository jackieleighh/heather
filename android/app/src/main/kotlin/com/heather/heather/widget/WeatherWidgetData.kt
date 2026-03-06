package com.totms.heather.widget

import android.content.SharedPreferences
import com.totms.heather.R
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

data class HourlyEntry(
    val time: String,
    val temperature: Int,
    val weatherCode: Int,
    val isDay: Boolean,
) {
    val conditionName: String get() = WmoCodeMapper.conditionName(weatherCode)

    /// Hour label extracted directly from the ISO time string (no timezone parsing).
    val hourLabel: String
        get() {
            val tIndex = time.indexOf('T')
            if (tIndex < 0 || tIndex + 1 >= time.length) return ""
            val afterT = time.substring(tIndex + 1)
            val colonIndex = afterT.indexOf(':')
            if (colonIndex < 0) return ""
            val hour = afterT.substring(0, colonIndex).toIntOrNull() ?: return ""
            val displayHour = if (hour % 12 == 0) 12 else hour % 12
            val ampm = if (hour < 12) "am" else "pm"
            return "$displayHour$ampm"
        }
}

data class WeatherWidgetData(
    val temperature: Int,
    val feelsLike: Int,
    val high: Int,
    val low: Int,
    val conditionName: String,
    val description: String,
    val isDay: Boolean,
    val humidity: Int,
    val windSpeed: Int,
    val uvIndex: Int,
    val quip: String,
    val persona: String,
    val cityName: String,
    val gradientColors: List<String>,
    val hourly: List<HourlyEntry>,
    val sunrise: String?,
    val sunset: String?,
    val uvIndexMax: Int?,
    val utcOffsetSeconds: Int?,
    val precipLabel: String?,
    val alertLabel: String?,
    val alertSeverity: String?,
) {
    val alertColor: Int
        get() = when (alertSeverity?.lowercase()) {
            "extreme" -> 0xFFEF4444.toInt()
            "severe" -> 0xFFF97316.toInt()
            else -> 0xFFFFEB3B.toInt()
        }

    val alertIconRes: Int
        get() = when (alertSeverity?.lowercase()) {
            "extreme" -> R.drawable.ic_weather_alert_extreme
            else -> R.drawable.ic_weather_alert
        }

    val locationTimeZone: TimeZone
        get() = utcOffsetSeconds?.let {
            TimeZone.getTimeZone("GMT${if (it >= 0) "+" else ""}${it / 3600}:${"%02d".format((Math.abs(it) % 3600) / 60)}")
        } ?: TimeZone.getDefault()

    val sunriseLabel: String? get() = sunrise?.let { formatTimeLabel(it, locationTimeZone) }
    val sunsetLabel: String? get() = sunset?.let { formatTimeLabel(it, locationTimeZone) }

    companion object {
        val placeholder = WeatherWidgetData(
            temperature = 72,
            feelsLike = 70,
            high = 78,
            low = 62,
            conditionName = "sunny",
            description = "Clear sky",
            isDay = true,
            humidity = 45,
            windSpeed = 8,
            uvIndex = 3,
            quip = "It's giving main character energy out there.",
            persona = "heather",
            cityName = "Los Angeles",
            gradientColors = listOf("#FF5B86E5", "#FF36D1DC"),
            hourly = emptyList(),
            sunrise = null,
            sunset = null,
            uvIndexMax = null,
            utcOffsetSeconds = null,
            precipLabel = null,
            alertLabel = null,
            alertSeverity = null,
        )

        fun fromPreferences(prefs: SharedPreferences): WeatherWidgetData {
            val jsonString = prefs.getString("widget_data", null) ?: return placeholder
            return try {
                val json = JSONObject(jsonString)
                val hourlyArray = json.optJSONArray("hourly")
                val hourlyList = mutableListOf<HourlyEntry>()
                if (hourlyArray != null) {
                    for (i in 0 until hourlyArray.length()) {
                        val h = hourlyArray.getJSONObject(i)
                        hourlyList.add(
                            HourlyEntry(
                                time = h.getString("time"),
                                temperature = h.getInt("temperature"),
                                weatherCode = h.getInt("weatherCode"),
                                isDay = h.optBoolean("isDay", true),
                            )
                        )
                    }
                }
                val gradientArray = json.optJSONArray("gradientColors")
                val gradientList = mutableListOf<String>()
                if (gradientArray != null) {
                    for (i in 0 until gradientArray.length()) {
                        gradientList.add(gradientArray.getString(i))
                    }
                }
                WeatherWidgetData(
                    temperature = json.optInt("temperature", 0),
                    feelsLike = json.optInt("feelsLike", 0),
                    high = json.optInt("high", 0),
                    low = json.optInt("low", 0),
                    conditionName = json.optString("conditionName", "sunny"),
                    description = json.optString("description", ""),
                    isDay = json.optBoolean("isDay", true),
                    humidity = json.optInt("humidity", 0),
                    windSpeed = json.optInt("windSpeed", 0),
                    uvIndex = json.optInt("uvIndex", 0),
                    quip = json.optString("quip", ""),
                    persona = json.optString("persona", "heather"),
                    cityName = json.optString("cityName", ""),
                    gradientColors = gradientList.ifEmpty { listOf("#FF5B86E5", "#FF36D1DC") },
                    hourly = hourlyList,
                    sunrise = json.optString("sunrise", "").ifEmpty { null },
                    sunset = json.optString("sunset", "").ifEmpty { null },
                    uvIndexMax = if (json.has("uvIndexMax")) json.optInt("uvIndexMax") else null,
                    utcOffsetSeconds = if (json.has("utcOffsetSeconds")) json.optInt("utcOffsetSeconds") else null,
                    precipLabel = json.optString("precipLabel", "").ifEmpty { null },
                    alertLabel = json.optString("alertLabel", "").ifEmpty { null },
                    alertSeverity = json.optString("alertSeverity", "").ifEmpty { null },
                )
            } catch (_: Exception) {
                placeholder
            }
        }

        private fun formatTimeLabel(isoString: String, tz: TimeZone): String? {
            val formats = listOf(
                "yyyy-MM-dd'T'HH:mm",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            )
            var parsed: java.util.Date? = null
            for (format in formats) {
                try {
                    val sdf = SimpleDateFormat(format, Locale.US)
                    sdf.timeZone = tz
                    parsed = sdf.parse(isoString)
                    if (parsed != null) break
                } catch (_: Exception) {}
            }
            if (parsed == null) return null
            val display = SimpleDateFormat("h:mm a", Locale.US)
            display.timeZone = tz
            return display.format(parsed)
        }
    }
}
