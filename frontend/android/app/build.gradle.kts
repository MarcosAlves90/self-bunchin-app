import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeystorePropertiesFile = rootProject.file("key.properties")
val releaseKeystoreProperties = Properties()
val releaseKeystoreConfigured = releaseKeystorePropertiesFile.exists()

if (releaseKeystoreConfigured) {
    FileInputStream(releaseKeystorePropertiesFile).use { stream ->
        releaseKeystoreProperties.load(stream)
    }
}

if (gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) } && !releaseKeystoreConfigured) {
    error(
        "Missing android/key.properties. Copy android/key.properties.example to android/key.properties " +
            "and configure release signing before building a release artifact."
    )
}

android {
    namespace = "com.bunchin.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (releaseKeystoreConfigured) {
            create("release") {
                keyAlias = releaseKeystoreProperties["keyAlias"] as String
                keyPassword = releaseKeystoreProperties["keyPassword"] as String
                storeFile = file(releaseKeystoreProperties["storeFile"] as String)
                storePassword = releaseKeystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.bunchin.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeystoreConfigured) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }
}

flutter {
    source = "../.."
}
