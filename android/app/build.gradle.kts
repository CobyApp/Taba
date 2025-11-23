plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.coby.taba"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.coby.taba"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: "../keystore.jks"
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            val keyAlias = System.getenv("KEY_ALIAS") ?: ""
            val keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            
            if (file(keystorePath).exists() && keystorePassword.isNotEmpty()) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            // Release 빌드는 항상 release signing config 사용
            // keystore가 없으면 빌드 실패 (CI/CD에서는 필수)
            val keystorePath = System.getenv("KEYSTORE_PATH") ?: "../keystore.jks"
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
            
            if (file(keystorePath).exists() && keystorePassword.isNotEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // CI/CD 환경에서는 keystore가 필수이므로 빌드 실패
                if (System.getenv("CI") == "true" || System.getenv("GITHUB_ACTIONS") == "true") {
                    throw GradleException("Release keystore is required for CI/CD builds. Please set KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, and KEY_PASSWORD environment variables.")
                }
                // 로컬 개발 환경에서는 경고만 표시하고 debug 서명 사용 (선택사항)
                println("⚠️ WARNING: Release keystore not found. Using debug signing. This AAB cannot be uploaded to Google Play.")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
