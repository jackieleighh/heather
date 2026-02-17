package com.totms.heather.widget

object WmoCodeMapper {
    fun conditionName(wmoCode: Int): String = when (wmoCode) {
        0 -> "sunny"
        1 -> "mostlySunny"
        2 -> "partlyCloudy"
        3 -> "overcast"
        45, 48 -> "foggy"
        51, 53, 55, 80 -> "drizzle"
        56, 57, 66, 67 -> "freezingRain"
        61, 63, 81 -> "rain"
        65, 82 -> "heavyRain"
        71, 73, 77, 85 -> "snow"
        75, 86 -> "blizzard"
        95 -> "thunderstorm"
        96, 99 -> "hail"
        else -> "unknown"
    }
}
