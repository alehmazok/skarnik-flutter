package by.mazokaleh.skarnik.widget

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class WordOfDayWidgetReceiver : HomeWidgetGlanceWidgetReceiver<WordOfDayGlanceWidget>() {
    override val glanceAppWidget = WordOfDayGlanceWidget()
}
