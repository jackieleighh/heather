package com.totms.heather.widget

import com.totms.heather.R
import java.util.Calendar
import java.util.TimeZone
import kotlin.math.cos
import kotlin.math.roundToInt

enum class MoonPhaseType(val label: String, val iconRes: Int) {
    NEW_MOON("New", R.drawable.ic_moon_new),
    WAXING_CRESCENT("Wax Cres", R.drawable.ic_moon_waxing_crescent),
    FIRST_QUARTER("1st Qtr", R.drawable.ic_moon_first_quarter),
    WAXING_GIBBOUS("Wax Gib", R.drawable.ic_moon_waxing_gibbous),
    FULL_MOON("Full", R.drawable.ic_moon_full),
    WANING_GIBBOUS("Wan Gib", R.drawable.ic_moon_waning_gibbous),
    LAST_QUARTER("3rd Qtr", R.drawable.ic_moon_last_quarter),
    WANING_CRESCENT("Wan Cres", R.drawable.ic_moon_waning_crescent);
}

private const val SYNODIC_MONTH = 29.53058770576

/** Reference new moon: Jan 18, 2026 19:51 UTC */
private val referenceNewMoonMillis: Long by lazy {
    val cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
    cal.set(2026, Calendar.JANUARY, 18, 19, 51, 0)
    cal.set(Calendar.MILLISECOND, 0)
    cal.timeInMillis
}

fun moonAge(timeMillis: Long = System.currentTimeMillis()): Double {
    val days = (timeMillis - referenceNewMoonMillis) / 86_400_000.0
    val age = days.mod(SYNODIC_MONTH)
    return if (age < 0) age + SYNODIC_MONTH else age
}

fun getMoonPhase(timeMillis: Long = System.currentTimeMillis()): MoonPhaseType {
    val fraction = moonAge(timeMillis) / SYNODIC_MONTH
    return when {
        fraction < 0.04 -> MoonPhaseType.NEW_MOON
        fraction < 0.21 -> MoonPhaseType.WAXING_CRESCENT
        fraction < 0.29 -> MoonPhaseType.FIRST_QUARTER
        fraction < 0.46 -> MoonPhaseType.WAXING_GIBBOUS
        fraction < 0.54 -> MoonPhaseType.FULL_MOON
        fraction < 0.71 -> MoonPhaseType.WANING_GIBBOUS
        fraction < 0.79 -> MoonPhaseType.LAST_QUARTER
        fraction < 0.96 -> MoonPhaseType.WANING_CRESCENT
        else -> MoonPhaseType.NEW_MOON
    }
}

fun moonIllumination(timeMillis: Long = System.currentTimeMillis()): Int {
    val age = moonAge(timeMillis)
    val fraction = age / SYNODIC_MONTH
    val illum = (1 - cos(2 * Math.PI * fraction)) / 2.0 * 100.0
    return illum.roundToInt()
}
