package com.mindful.android.models

import android.util.Log
import com.mindful.android.enums.ReminderType
import org.json.JSONObject

/**
 * Represents app-level restriction configuration, such as usage time and access limits.
 */
data class AppRestriction(
    /**
     * Package name of the app.
     */
    val appPackage: String = "",

    /**
     * Daily timer limit for the app, in seconds.
     */
    val timerSec: Int = 0,

    /**
     * Launch limit per day.
     */
    val launchLimit: Int = 0,

    /**
     * Time of day (in minutes) from midnight when the app usage is allowed to start.
     */
    val activePeriodStart: Int = 0,

    /**
     * Time of day (in minutes) from midnight when the app usage is blocked.
     */
    val activePeriodEnd: Int = 0,

    /**
     * Type of usage reminders to show while using timed app.
     */
    val reminderType: ReminderType = ReminderType.NOTIFICATION,

    /**
     * ID of the restriction group this app belongs to (nullable).
     */
    val associatedGroupId: Int? = null,

    /**
     * Duration of the Pause Point breather in seconds. 0 means Pause Point is disabled.
     */
    val pausePointSec: Int = 0,

    /**
     * Cooldown in minutes between consecutive Pause Point firings for this app.
     */
    val pausePointCooldownMin: Int = 30,
) {
    companion object {
        /**
         * Constructs an [AppRestriction] from a JSON string.
         */
        fun fromJson(json: String): AppRestriction {
            val jsonObject = JSONObject(json)
            return AppRestriction(
                appPackage = jsonObject.optString("appPackage", ""),
                timerSec = jsonObject.optInt("timerSec", 0),
                launchLimit = jsonObject.optInt("launchLimit", 0),
                activePeriodStart = jsonObject.optInt("activePeriodStart", 0),
                activePeriodEnd = jsonObject.optInt("activePeriodEnd", 0),
                reminderType = ReminderType.fromName(jsonObject.optString("reminderType", "toast")),
                associatedGroupId = if (jsonObject.isNull("associatedGroupId")) null else jsonObject.optInt(
                    "associatedGroupId"
                ),
                pausePointSec = jsonObject.optInt("pausePointSec", 0),
                pausePointCooldownMin = jsonObject.optInt("pausePointCooldownMin", 30),
            )
        }
    }
}
