import Foundation

struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let daily: DailyWeather
    let hourly: HourlyWeather?

    struct CurrentWeather: Codable {
        let temperature_2m: Double
        let relative_humidity_2m: Int
        let apparent_temperature: Double
        let is_day: Int
        let weather_code: Int
        let wind_speed_10m: Double
        let uv_index: Double
    }

    struct DailyWeather: Codable {
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let sunrise: [String]?
        let sunset: [String]?
        let uv_index_max: [Double]?
    }

    struct HourlyWeather: Codable {
        let time: [String]
        let temperature_2m: [Double]
        let weather_code: [Int]
    }
}

struct WeatherFetcher {

    static func fetch(latitude: Double, longitude: Double) async -> OpenMeteoResponse? {
        let urlString = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(latitude)&longitude=\(longitude)"
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m,uv_index"
            + "&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max"
            + "&hourly=temperature_2m,weather_code"
            + "&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto&forecast_days=2"

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }
            return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - WMO Code Mapping

    static func conditionName(from wmoCode: Int) -> String {
        switch wmoCode {
        case 0: return "sunny"
        case 1: return "mostlySunny"
        case 2: return "partlyCloudy"
        case 3: return "overcast"
        case 45, 48: return "foggy"
        case 51, 53, 55, 80: return "drizzle"
        case 56, 57, 66, 67: return "freezingRain"
        case 61, 63, 81: return "rain"
        case 65, 82: return "heavyRain"
        case 71, 73, 77, 85: return "snow"
        case 75, 86: return "blizzard"
        case 95: return "thunderstorm"
        case 96, 99: return "hail"
        default: return "unknown"
        }
    }

    static func description(from wmoCode: Int) -> String {
        switch wmoCode {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Foggy"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snowfall"
        case 73: return "Moderate snowfall"
        case 75: return "Heavy snowfall"
        case 77: return "Snow grains"
        case 80: return "Slight rain showers"
        case 81: return "Moderate rain showers"
        case 82: return "Violent rain showers"
        case 85: return "Slight snow showers"
        case 86: return "Heavy snow showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown"
        }
    }
}
