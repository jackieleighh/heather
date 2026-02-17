package com.totms.heather.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class HeatherWidgetReceiver : HomeWidgetGlanceWidgetReceiver<HeatherGlanceWidget>() {
    override val glanceAppWidget = HeatherGlanceWidget()
}
