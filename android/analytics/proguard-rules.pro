# ===================================
# DrinkSomeWater Analytics Module ProGuard Rules
# ===================================

# ===== Kotlin =====
-keepattributes *Annotation*
-keep class kotlin.Metadata { *; }

# ===== Firebase Analytics =====
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-dontwarn com.google.firebase.analytics.**

# Keep analytics event classes
-keep class com.onceagain.drinksomewater.analytics.** { *; }
-keepclassmembers class com.onceagain.drinksomewater.analytics.** { *; }

# Keep enum members for analytics events
-keepclassmembers enum com.onceagain.drinksomewater.analytics.** {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
