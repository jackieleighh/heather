package com.totms.heather.widget

import android.content.SharedPreferences
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale

data class HourlyEntry(
    val time: String,
    val temperature: Int,
    val weatherCode: Int,
) {
    val conditionName: String get() = WmoCodeMapper.conditionName(weatherCode)

    val hourLabel: String
        get() {
            val formats = listOf(
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm",
            )
            var parsed: java.util.Date? = null
            for (format in formats) {
                try {
                    val sdf = SimpleDateFormat(format, Locale.US)
                    parsed = sdf.parse(time)
                    if (parsed != null) break
                } catch (_: Exception) {}
            }
            if (parsed == null) return ""
            val hFmt = SimpleDateFormat("ha", Locale.US)
            return hFmt.format(parsed).lowercase()
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
) {
    val sunriseLabel: String? get() = sunrise?.let { formatTimeLabel(it) }
    val sunsetLabel: String? get() = sunset?.let { formatTimeLabel(it) }

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
                )
            } catch (_: Exception) {
                placeholder
            }
        }

        private fun formatTimeLabel(isoString: String): String? {
            val formats = listOf(
                "yyyy-MM-dd'T'HH:mm",
                "yyyy-MM-dd'T'HH:mm:ss",
            )
            var parsed: java.util.Date? = null
            for (format in formats) {
                try {
                    val sdf = SimpleDateFormat(format, Locale.US)
                    parsed = sdf.parse(isoString)
                    if (parsed != null) break
                } catch (_: Exception) {}
            }
            if (parsed == null) return null
            val display = SimpleDateFormat("h:mm a", Locale.US)
            return display.format(parsed)
        }
    }
}
