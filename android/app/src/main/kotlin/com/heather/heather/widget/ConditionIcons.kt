package com.totms.heather.widget

import com.totms.heather.R

object ConditionIcons {
    fun iconRes(conditionName: String, isDay: Boolean): Int = when (conditionName) {
        "sunny" -> if (isDay) R.drawable.ic_weather_sunny_day else R.drawable.ic_weather_sunny_night
        "mostlySunny" -> if (isDay) R.drawable.ic_weather_mostly_sunny_day else R.drawable.ic_weather_mostly_sunny_night
        "partlyCloudy" -> if (isDay) R.drawable.ic_weather_partly_cloudy_day else R.drawable.ic_weather_partly_cloudy_night
        "overcast" -> R.drawable.ic_weather_overcast
        "foggy" -> R.drawable.ic_weather_foggy
        "drizzle" -> if (isDay) R.drawable.ic_weather_drizzle_day else R.drawable.ic_weather_drizzle_night
        "rain" -> R.drawable.ic_weather_rain
        "heavyRain" -> R.drawable.ic_weather_heavy_rain
        "freezingRain" -> R.drawable.ic_weather_freezing_rain
        "snow" -> R.drawable.ic_weather_snow
        "blizzard" -> R.drawable.ic_weather_blizzard
        "thunderstorm" -> R.drawable.ic_weather_thunderstorm
        "hail" -> R.drawable.ic_weather_hail
        else -> R.drawable.ic_weather_overcast
    }

    fun personaLogoRes(persona: String): Int = when (persona) {
        "jade" -> R.drawable.ic_persona_jade
        "luna" -> R.drawable.ic_persona_luna
        "aurelia" -> R.drawable.ic_persona_aurelia
        else -> R.drawable.ic_persona_heather
    }
}
