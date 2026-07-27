package by.mazokaleh.skarnik.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.text.TextAlign
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import by.mazokaleh.skarnik.MainActivity
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

private val AccentColor = ColorProvider(Color(0xFFF44C3E))
private val MutedColor = ColorProvider(Color(0xFF68686E))
private val BackgroundColor = ColorProvider(Color(0xFFFFFFFF))

private const val FallbackWord = "халэмус"
private const val FallbackTranslation = "гибель, конец"

class WordOfDayGlanceWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val word = state.preferences.getString("word", null) ?: FallbackWord
            val translation = state.preferences.getString("translation", null) ?: FallbackTranslation
            val wordId = state.preferences.getString("wordId", null) ?: "-1"

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(BackgroundColor)
                    .padding(16.dp)
                    .clickable(actionStartActivity(buildDeepLinkIntent(context, wordId))),
            ) {
                Text(
                    text = word.uppercase(),
                    maxLines = 2,
                    style = TextStyle(
                        color = AccentColor,
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp,
                        textAlign = TextAlign.Start,
                    ),
                )
                Text(
                    text = translation,
                    maxLines = 4,
                    style = TextStyle(
                        color = MutedColor,
                        fontSize = 14.sp,
                    ),
                )
            }
        }
    }

    private fun buildDeepLinkIntent(context: Context, wordId: String): Intent {
        // Explicit intent (setClass) bypasses intent-filter resolution entirely,
        // landing directly in MainActivity exactly as if Android had routed it
        // through the existing verified skarnik.app App Link — no new manifest
        // entries or Dart parsing code needed for tap-through.
        val uri = Uri.parse("https://skarnik.app/belrus/$wordId/")
        return Intent(Intent.ACTION_VIEW, uri).apply {
            setClass(context, MainActivity::class.java)
        }
    }
}
