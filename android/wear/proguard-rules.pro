# ===================================
# DrinkSomeWater Wear OS Module ProGuard Rules
# ===================================

# ===== Kotlin =====
-keepattributes *Annotation*
-keepattributes Signature
-keep class kotlin.Metadata { *; }

# ===== Kotlinx Serialization =====
-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
}

# ===== Wear OS =====
-keep class androidx.wear.** { *; }
-keep class androidx.wear.compose.** { *; }
-dontwarn androidx.wear.**

# ===== Wear Tiles =====
-keep class androidx.wear.tiles.** { *; }
-keep class * extends androidx.wear.tiles.TileService { *; }
-keepclassmembers class * extends androidx.wear.tiles.TileService { *; }

# ===== Wearable Data Layer =====
-keep class com.google.android.gms.wearable.** { *; }
-dontwarn com.google.android.gms.wearable.**

# ===== MessageClient / DataClient =====
-keep class * implements com.google.android.gms.wearable.MessageClient$OnMessageReceivedListener { *; }
-keep class * implements com.google.android.gms.wearable.DataClient$OnDataChangedListener { *; }

# ===== Keep Wear components =====
-keep class com.onceagain.drinksomewater.wear.** { *; }
-keepclassmembers class com.onceagain.drinksomewater.wear.** { *; }

# ===== WearableListenerService =====
-keep class * extends com.google.android.gms.wearable.WearableListenerService { *; }

# ===== Hilt =====
-keep class dagger.hilt.** { *; }
-keep class javax.inject.** { *; }
