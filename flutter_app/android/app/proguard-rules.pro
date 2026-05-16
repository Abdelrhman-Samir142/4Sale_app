# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class plugins.flutter.io.**  { *; }

# Dart
-keep class * extends io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$ActivityResultListener { *; }

# Ignore missing Play Core classes (Fixes R8 release build error)
-dontwarn com.google.android.play.core.**
