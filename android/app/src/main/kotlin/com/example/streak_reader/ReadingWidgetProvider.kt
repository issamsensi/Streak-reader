package com.example.streak_reader

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ReadingWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val isNewDay = widgetData.getString("widget_date", null) != today
        val progress = if (isNewDay) 0 else widgetData.getInt("progress_percent", 0)
        val progressLabel = if (isNewDay) {
            "0 / ${widgetData.getInt("goal_minutes", 10)} min"
        } else {
            widgetData.getString("progress_label", "0 / 10 min")
        }
        val launchIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            widgetData.getInt("continue_book_id", -1).takeIf { it > 0 }?.let {
                data = android.net.Uri.parse("streakreader://continue?bookId=$it")
            }
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.reading_widget).apply {
                setTextViewText(R.id.widget_streak, "${widgetData.getInt("streak", 0)}")
                setTextViewText(
                    R.id.widget_progress,
                    progressLabel,
                )
                setProgressBar(
                    R.id.widget_progress_bar,
                    100,
                    progress,
                    false,
                )
                setTextViewText(
                    R.id.widget_continue,
                    widgetData.getString("continue_book_title", "Continue reading"),
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
