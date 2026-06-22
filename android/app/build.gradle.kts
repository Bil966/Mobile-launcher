// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.neonlauncher.geode_mod_manager"
    compileSdk = 36 // Ép buộc SDK 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.neonlauncher.geode_mod_manager"
        minSdk = 23
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    // Ép buộc tất cả plugin con dùng chung SDK 36
    subprojects {
        afterEvaluate { project ->
            if (project.hasProperty("android")) {
                project.android {
                    compileSdk = 36
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
