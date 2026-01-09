# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Your app
-keep class com.vschool.school.** { *; }

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Remove debug info
-keepattributes !LocalVariableTable,!LocalVariableTypeTable

############################
# Razorpay SDK
############################
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

############################
# AndroidX Lifecycle (required by Razorpay)
############################
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

############################
# Kotlin Metadata (safe)
############################
-keep class kotlin.Metadata { *; }
