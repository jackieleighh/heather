package com.totms.heather.widget

import com.totms.heather.R

object ConditionIcons {
    fun iconRes(conditionName: String, isDay: Boolean): Int = when (conditionName) {
        "sunny" -> if (isDay) R.drawable.ic_weather_sunny_day else R.drawable.ic_weather_sunny_night
        "mostlySunny", "partlyCloudy" -> if (isDay) R.drawable.ic_weather_partly_cloudy_day else R.drawable.ic_weather_partly_cloudy_night
        "overcast" -> R.drawable.ic_weather_overcast
        "foggy" -> R.drawable.ic_weather_foggy
        "drizzle" -> if (isDay) R.drawable.ic_weather_drizzle_day else R.drawable.ic_weather_drizzle_night
        "rain" -> if (isDay) R.drawable.ic_weather_rain_day else R.drawable.ic_weather_rain_night
        "heavyRain" -> if (isDay) R.drawable.ic_weather_heavy_rain_day else R.drawable.ic_weather_heavy_rain_night
        "freezingRain" -> R.drawable.ic_weather_freezing_rain
        "snow" -> R.drawable.ic_weather_snow
        "blizzard" -> R.drawable.ic_weather_blizzard
        "thunderstorm" -> if (isDay) R.drawable.ic_weather_thunderstorm_day else R.drawable.ic_weather_thunderstorm_night
        "hail" -> R.drawable.ic_weather_hail
        else -> R.drawable.ic_weather_overcast
    }

    fun personaLogoRes(): Int = R.drawable.persona_heather
}
