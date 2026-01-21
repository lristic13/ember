package com.lristic.ember

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.TextView
import org.json.JSONArray

class EmberWidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set result to canceled in case user backs out
        setResult(RESULT_CANCELED)

        setContentView(R.layout.activity_widget_config)

        // Get the widget ID from the intent
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        // Load available activities
        val activities = loadAvailableActivities()

        val listView = findViewById<ListView>(R.id.activity_list)

        if (activities.isEmpty()) {
            // Show message that user needs to open app first
            val emptyList = listOf(ActivityItem(
                id = "",
                name = "Open the app first to create activities",
                emoji = ""
            ))
            listView.adapter = ActivityAdapter(this, emptyList)
            listView.setOnItemClickListener { _, _, _, _ ->
                // Open the main app
                val intent = Intent(this, MainActivity::class.java)
                startActivity(intent)
                finish()
            }
            return
        }

        // Set up the list
        val adapter = ActivityAdapter(this, activities)
        listView.adapter = adapter

        listView.setOnItemClickListener { _, _, position, _ ->
            val activity = activities[position]
            selectActivity(activity)
        }
    }

    private fun loadAvailableActivities(): List<ActivityItem> {
        // home_widget stores data in SharedPreferences with this name
        val prefs = applicationContext.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("available_activities", null)

        if (jsonString.isNullOrEmpty()) {
            return emptyList()
        }

        return try {
            val jsonArray = JSONArray(jsonString)
            val list = mutableListOf<ActivityItem>()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)

                // Handle null values properly - optString returns "null" for JSON null
                val id = obj.optString("id", "").takeIf { it != "null" } ?: ""
                val name = obj.optString("name", "Unknown").takeIf { it != "null" } ?: "Unknown"
                val emoji = obj.optString("emoji", "").takeIf { it != "null" } ?: ""

                if (id.isNotEmpty()) {
                    list.add(ActivityItem(id = id, name = name, emoji = emoji))
                }
            }

            list
        } catch (e: Exception) {
            e.printStackTrace()
            emptyList()
        }
    }

    private fun selectActivity(activity: ActivityItem) {
        // Save the selected activity ID for this widget
        val prefs = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("widget_${appWidgetId}_activity_id", activity.id)
            .apply()

        // Update the widget
        val appWidgetManager = AppWidgetManager.getInstance(this)
        EmberWidgetReceiver().onUpdate(
            this,
            appWidgetManager,
            intArrayOf(appWidgetId),
            prefs
        )

        // Return success
        val resultValue = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        setResult(RESULT_OK, resultValue)
        finish()
    }

    data class ActivityItem(
        val id: String,
        val name: String,
        val emoji: String
    )

    private class ActivityAdapter(
        context: Context,
        private val activities: List<ActivityItem>
    ) : ArrayAdapter<ActivityItem>(context, R.layout.item_activity, activities) {

        override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
            val view = convertView ?: View.inflate(context, R.layout.item_activity, null)

            val activity = activities[position]

            view.findViewById<TextView>(R.id.activity_emoji).text = activity.emoji
            view.findViewById<TextView>(R.id.activity_name).text = activity.name

            return view
        }
    }
}
