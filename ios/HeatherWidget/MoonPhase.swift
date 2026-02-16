import Foundation

enum MoonPhase: String {
    case newMoon = "New"
    case waxingCrescent = "Wax Cres"
    case firstQuarter = "1st Qtr"
    case waxingGibbous = "Wax Gib"
    case fullMoon = "Full"
    case waningGibbous = "Wan Gib"
    case thirdQuarter = "3rd Qtr"
    case waningCrescent = "Wan Cres"

    var sfSymbol: String {
        switch self {
        case .newMoon: return "moonphase.new.moon"
        case .waxingCrescent: return "moonphase.waxing.crescent"
        case .firstQuarter: return "moonphase.first.quarter"
        case .waxingGibbous: return "moonphase.waxing.gibbous"
        case .fullMoon: return "moonphase.full.moon"
        case .waningGibbous: return "moonphase.waning.gibbous"
        case .thirdQuarter: return "moonphase.last.quarter"
        case .waningCrescent: return "moonphase.waning.crescent"
        }
    }
}

/// Synodic month length in days.
private let synodicMonth = 29.53058770576

/// Reference new moon: Jan 18, 2026 19:51 UTC.
private let referenceNewMoon: Date = {
    var c = DateComponents()
    c.year = 2026; c.month = 1; c.day = 18
    c.hour = 19; c.minute = 51
    c.timeZone = TimeZone(identifier: "UTC")
    return Calendar.current.date(from: c)!
}()

func moonAge(for date: Date = Date()) -> Double {
    let seconds = date.timeIntervalSince(referenceNewMoon)
    let days = seconds / 86400
    let age = days.truncatingRemainder(dividingBy: synodicMonth)
    return age < 0 ? age + synodicMonth : age
}

func getMoonPhase(for date: Date = Date()) -> MoonPhase {
    let fraction = moonAge(for: date) / synodicMonth

    if fraction < 0.04 { return .newMoon }
    if fraction < 0.21 { return .waxingCrescent }
    if fraction < 0.29 { return .firstQuarter }
    if fraction < 0.46 { return .waxingGibbous }
    if fraction < 0.54 { return .fullMoon }
    if fraction < 0.71 { return .waningGibbous }
    if fraction < 0.79 { return .thirdQuarter }
    if fraction < 0.96 { return .waningCrescent }
    return .newMoon
}

func moonIllumination(for date: Date = Date()) -> Int {
    let age = moonAge(for: date)
    let fraction = age / synodicMonth
    let illum = (1 - cos(2 * .pi * fraction)) / 2 * 100
    return Int(illum.rounded())
}
