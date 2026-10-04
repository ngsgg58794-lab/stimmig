import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val keyProps = Properties().apply {
    val f = rootProject.file("keystore.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "de.juliawimmer.stimmig"
    compileSdk = 35

    defaultConfig {
        applicationId = "de.juliawimmer.stimmig"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.1"
    }

    signingConfigs {
        if (keyProps.isNotEmpty()) create("release") {
            storeFile = rootProject.file(keyProps.getProperty("storeFile"))
            storePassword = keyProps.getProperty("storePassword")
            keyAlias = keyProps.getProperty("keyAlias")
            keyPassword = keyProps.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            if (keyProps.isNotEmpty()) signingConfig = signingConfigs.getByName("release")
        }
    }

    // Web-App (../web) wird direkt als Asset eingebunden
    sourceSets["main"].assets.srcDir("../../web")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    implementation("androidx.webkit:webkit:1.11.0")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
}
