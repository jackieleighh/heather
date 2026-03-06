import SwiftUI
import WidgetKit

struct HeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: WeatherEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(data: entry.data)
            case .systemMedium:
                MediumWidgetView(data: entry.data, entryDate: entry.date)
            case .systemLarge:
                LargeWidgetView(data: entry.data, entryDate: entry.date)
            default:
                SmallWidgetView(data: entry.data)
            }
        }
        .widgetURL(URL(string: "heather://home"))
    }
}
