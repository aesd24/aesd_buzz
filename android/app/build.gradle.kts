import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("Loaded key.properties")
    println("storeFile: " + keystoreProperties.getProperty("storeFile"))
    println("keyAlias: " + keystoreProperties.getProperty("keyAlias"))
    // Don't log full passwords
    println("storePassword exists: " + (keystoreProperties.getProperty("storePassword") != null))
    println("keyPassword exists: " + (keystoreProperties.getProperty("keyPassword") != null))
} else {
    println("key.properties NOT FOUND at " + keystorePropertiesFile.absolutePath)
}

val hasValidSigningConfig = keystorePropertiesFile.exists() &&
    keystoreProperties.getProperty("storeFile") != null &&
    keystoreProperties.getProperty("storePassword") != null &&
    keystoreProperties.getProperty("keyAlias") != null &&
    keystoreProperties.getProperty("keyPassword") != null

android {
    namespace = "com.aesd.buzz"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.3.13750724"

    signingConfigs {
        create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile")!!)
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.aesd.buzz"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packaging {
        jniLibs {
             // keepDebugSymbols += "**/*.so"
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
