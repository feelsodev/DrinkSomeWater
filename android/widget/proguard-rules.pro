# ===================================
# DrinkSomeWater Widget Module ProGuard Rules
# ===================================

# ===== Kotlin =====
-keepattributes *Annotation*
-keepattributes Signature
-keep class kotlin.Metadata { *; }

# ===== Kotlinx Serialization =====
-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
}

# ===== Glance Widget =====
-keep class androidx.glance.** { *; }
-keep class androidx.glance.appwidget.** { *; }
-keepclassmembers class * extends androidx.glance.appwidget.GlanceAppWidget { *; }
-keepclassmembers class * extends androidx.glance.appwidget.GlanceAppWidgetReceiver { *; }

# Keep widget components
-keep class com.onceagain.drinksomewater.widget.** { *; }
-keepclassmembers class com.onceagain.drinksomewater.widget.** { *; }

# ===== AppWidgetProvider =====
-keep class * extends android.appwidget.AppWidgetProvider { *; }

# ===== ActionCallback =====
-keep class * extends androidx.glance.appwidget.action.ActionCallback { *; }
