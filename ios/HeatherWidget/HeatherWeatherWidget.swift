import SwiftUI
import WidgetKit

struct WeatherEntry: TimelineEntry {
    let date: Date
    let data: WeatherData
    let isPlaceholder: Bool
}

struct HeatherWeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), data: .placeholder, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> Void) {
        let data = WeatherData.load() ?? .placeholder
        let entry = WeatherEntry(date: Date(), data: data, isPlaceholder: context.isPreview)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void) {
        let data = WeatherData.load() ?? .placeholder
        let entry = WeatherEntry(date: Date(), data: data, isPlaceholder: false)
        // Refresh after 30 minutes if the app doesn't push sooner
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct HeatherWeatherWidget: Widget {
    let kind = "HeatherWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatherWeatherProvider()) { entry in
            HeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Heather Weather")
        .description("Your sassy weather at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
