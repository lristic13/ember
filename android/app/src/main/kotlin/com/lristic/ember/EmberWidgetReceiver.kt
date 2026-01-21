package com.lristic.ember

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class EmberWidgetReceiver : HomeWidgetProvider() {

    companion object {
        const val ACTION_QUICK_LOG = "com.lristic.ember.ACTION_QUICK_LOG"
        const val EXTRA_HABIT_ID = "habitId"
        const val EXTRA_WIDGET_ID = "widgetId"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_QUICK_LOG) {
            val habitId = intent.getStringExtra(EXTRA_HABIT_ID)
            val widgetId = intent.getIntExtra(EXTRA_WIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)

            if (!habitId.isNullOrEmpty()) {
                handleQuickLog(context, habitId, widgetId)
            }
        } else {
            super.onReceive(context, intent)
        }
    }

    private fun handleQuickLog(context: Context, habitId: String, widgetId: Int) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        // Get activity data
        val activityJson = prefs.getString("activity_$habitId", null) ?: return
        val json = JSONObject(activityJson)

        val isCompletion = json.optBoolean("isCompletion", false)
        val todayValue = if (json.isNull("todayValue")) 0.0 else json.optDouble("todayValue", 0.0)

        // Calculate new value
        val newValue = if (isCompletion) {
            if (todayValue > 0) 0.0 else 1.0
        } else {
            todayValue + 1.0
        }

        // Update the activity data with new today value
        json.put("todayValue", newValue)

        // Update week values array for today
        val weekValuesArray = json.optJSONArray("weekValues") ?: JSONArray()
        val todayIndex = getTodayWeekIndex()

        // Create new week values array with updated today value
        val newWeekValues = JSONArray()
        for (i in 0 until 7) {
            if (i == todayIndex) {
                newWeekValues.put(newValue)
            } else if (i < weekValuesArray.length()) {
                newWeekValues.put(weekValuesArray.optDouble(i, 0.0))
            } else {
                newWeekValues.put(0.0)
            }
        }
        json.put("weekValues", newWeekValues)

        // Save updated activity data
        prefs.edit().putString("activity_$habitId", json.toString()).apply()

        // Add to pending logs for sync when app opens
        addPendingLog(prefs, habitId, newValue)

        // Refresh the widget
        val appWidgetManager = AppWidgetManager.getInstance(context)
        if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
            onUpdate(context, appWidgetManager, intArrayOf(widgetId), prefs)
        }
    }

    private fun getTodayWeekIndex(): Int {
        val calendar = Calendar.getInstance()
        // Calendar.DAY_OF_WEEK: Sunday=1, Monday=2, ..., Saturday=7
        // We want Monday=0, Tuesday=1, ..., Sunday=6
        val dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK)
        return if (dayOfWeek == Calendar.SUNDAY) 6 else dayOfWeek - 2
    }

    private fun addPendingLog(prefs: SharedPreferences, habitId: String, value: Double) {
        val pendingLogsJson = prefs.getString("pending_widget_logs", null)
        val pendingLogs = if (pendingLogsJson != null) {
            try {
                JSONArray(pendingLogsJson)
            } catch (e: Exception) {
                JSONArray()
            }
        } else {
            JSONArray()
        }

        // Add new log entry
        val logEntry = JSONObject().apply {
            put("habitId", habitId)
            put("value", value)
            put("timestamp", System.currentTimeMillis())
        }
        pendingLogs.put(logEntry)

        prefs.edit().putString("pending_widget_logs", pendingLogs.toString()).apply()
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ember_widget)

            try {
                // Get the selected activity ID for this widget instance
                val activityId = widgetData.getString("widget_${widgetId}_activity_id", null)

                if (!activityId.isNullOrEmpty()) {
                    // Load activity data
                    val activityJson = widgetData.getString("activity_$activityId", null)

                    if (!activityJson.isNullOrEmpty()) {
                        val json = JSONObject(activityJson)
                        updateWidgetViews(context, views, json, activityId, widgetId)
                    } else {
                        showNotConfigured(views)
                    }
                } else {
                    showNotConfigured(views)
                }

                // Set click listener for the whole widget to open app
                val openIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("ember://open?habitId=${activityId ?: ""}")
                )
                views.setOnClickPendingIntent(R.id.widget_container, openIntent)
            } catch (e: Exception) {
                e.printStackTrace()
                showNotConfigured(views)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun updateWidgetViews(
        context: Context,
        views: RemoteViews,
        json: JSONObject,
        activityId: String,
        widgetId: Int
    ) {
        // Handle null values properly - optString returns "null" for JSON null
        val name = json.optString("name", "Activity").takeIf { it != "null" } ?: "Activity"
        val isCompletion = json.optBoolean("isCompletion", false)
        val unit = json.optString("unit", "").takeIf { it != "null" } ?: ""
        val todayValue = if (json.isNull("todayValue")) 0.0 else json.optDouble("todayValue", 0.0)
        val gradientId = json.optString("gradientId", "ember").takeIf { it != "null" } ?: "ember"
        val weekValuesArray = json.optJSONArray("weekValues") ?: JSONArray()

        // Set activity name
        views.setTextViewText(R.id.activity_name, name)

        // Set status text
        val statusText = if (isCompletion) {
            if (todayValue > 0) "Done today" else "Not yet"
        } else {
            val value = todayValue.toInt()
            if (unit.isNotEmpty()) "$value $unit" else "$value today"
        }
        views.setTextViewText(R.id.activity_status, statusText)

        // Set button icon
        views.setImageViewResource(R.id.quick_log_button, if (isCompletion) R.drawable.ic_check else R.drawable.ic_add)

        // Get gradient color for heatmap cells
        val color = getGradientColor(gradientId)

        // Set quick log button click - use custom action instead of HomeWidgetBackgroundIntent
        val quickLogIntent = Intent(context, EmberWidgetReceiver::class.java).apply {
            action = ACTION_QUICK_LOG
            putExtra(EXTRA_HABIT_ID, activityId)
            putExtra(EXTRA_WIDGET_ID, widgetId)
        }
        val quickLogPendingIntent = PendingIntent.getBroadcast(
            context,
            widgetId, // Use widgetId as request code for uniqueness
            quickLogIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
        views.setOnClickPendingIntent(R.id.quick_log_button, quickLogPendingIntent)

        // Update heatmap cells
        val cellIds = listOf(
            R.id.cell_0, R.id.cell_1, R.id.cell_2, R.id.cell_3,
            R.id.cell_4, R.id.cell_5, R.id.cell_6
        )

        for (i in 0 until 7) {
            val value = if (i < weekValuesArray.length()) {
                weekValuesArray.optDouble(i, 0.0)
            } else {
                0.0
            }

            val cellColor = if (value > 0) {
                // Filled cell with gradient color at 80% opacity
                Color.argb(204, Color.red(color), Color.green(color), Color.blue(color))
            } else {
                // Empty cell
                Color.parseColor("#1A1A1F")
            }

            views.setInt(cellIds[i], "setBackgroundColor", cellColor)
        }
    }

    private fun showNotConfigured(views: RemoteViews) {
        views.setTextViewText(R.id.activity_name, "Select Activity")
        views.setTextViewText(R.id.activity_status, "Tap to configure")
        views.setImageViewResource(R.id.quick_log_button, R.drawable.ic_add)
    }

    private fun getGradientColor(gradientId: String): Int {
        return when (gradientId) {
            "ember" -> Color.parseColor("#FF6B1A")
            "coral" -> Color.parseColor("#FF6B6B")
            "sunflower" -> Color.parseColor("#FFD93D")
            "mint" -> Color.parseColor("#6BCC78")
            "ocean" -> Color.parseColor("#4D96FF")
            "lavender" -> Color.parseColor("#B085F5")
            "rose" -> Color.parseColor("#FF8FAB")
            "teal" -> Color.parseColor("#4DD1E0")
            "sand" -> Color.parseColor("#D4A673")
            "silver" -> Color.parseColor("#B0B0B0")
            "ruby" -> Color.parseColor("#E63836")
            "peach" -> Color.parseColor("#FFAB91")
            "lime" -> Color.parseColor("#ADEB00")
            "sky" -> Color.parseColor("#82D4FA")
            "violet" -> Color.parseColor("#7D4DFF")
            "magenta" -> Color.parseColor("#FF4082")
            "amber" -> Color.parseColor("#FFB300")
            "sage" -> Color.parseColor("#A6D6A6")
            "slate" -> Color.parseColor("#8FA3AD")
            "copper" -> Color.parseColor("#B87333")
            else -> Color.parseColor("#FF6B1A")
        }
    }
}
