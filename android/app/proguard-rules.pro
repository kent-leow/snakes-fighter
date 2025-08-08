# Add rules here to prevent proguard from discarding or renaming members
# that are used from the Flutter SDK or Kotlin code.

# Keep all Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter specific rules for R8
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Google Play Core (for app bundles and dynamic features)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# If Play Core is not used, keep references but allow missing classes
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep Dart-related classes
-keep class **.dart.** { *; }

# Keep app-specific classes
-keep class com.snakesfight.game.** { *; }

# Standard Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Keep Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    !private <fields>;
    !private <methods>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
