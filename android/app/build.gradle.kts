plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.tracing_app_new"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.example.tracing_app_new"
        minSdk = 26 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
            merges += "META-INF/LICENSE"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// حل مشكلة التكرار (Duplicate Classes) بين video_player و Jitsi
configurations.all {
    resolutionStrategy {
        // إجبار كل المكتبات على استخدام نسخة واحدة من مشغل الفيديو
        force("androidx.media3:media3-exoplayer-rtsp:1.1.1")
        force("androidx.media3:media3-exoplayer:1.1.1")
        force("androidx.media3:media3-common:1.1.1")
        force("androidx.media3:media3-datasource:1.1.1")
    }
    
    // استبعاد النسخة المتعارضة من أي مكان يحاول جلبها
    exclude(group = "androidx.media3", module = "media3-exoplayer-rtsp")
}