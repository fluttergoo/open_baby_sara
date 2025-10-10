    import java.util.Properties
    import java.io.FileInputStream

    plugins {
        id("com.android.application")
        // START: FlutterFire Configuration
        id("com.google.gms.google-services")
        // END: FlutterFire Configuration
        id("kotlin-android")
        // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
        id("dev.flutter.flutter-gradle-plugin")
    }

    android {
        namespace = "com.suleymansurucu.sarababy"
        compileSdk = flutter.compileSdkVersion
        ndkVersion = "27.0.12077973"
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = JavaVersion.VERSION_11.toString()
        }

        defaultConfig {
            // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
            applicationId = "com.suleymansurucu.sarababy"
            // You can update the following values to match your application needs.
            // For more information, see: https://flutter.dev/to/review-gradle-config.
            minSdk = 23
            targetSdk = flutter.targetSdkVersion
            versionCode = 5
            versionName = "1.2.0"

        }



        signingConfigs {
            create("release") {
                val keystoreFile = rootProject.file("app/key.properties")
                if (keystoreFile.exists()) {
                    val keystoreProperties = Properties().apply {
                        load(FileInputStream(keystoreFile))
                    }

                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                } else {
                    println("⚠️  key.properties not found. Release signing config will be skipped.")
                }
            }
        }

        buildTypes {
            getByName("release") {
                isMinifyEnabled = true
                isShrinkResources = true
                if (signingConfigs.findByName("release")?.storeFile != null) {
                    signingConfig = signingConfigs.getByName("release")
                }
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
        }

    }

    flutter {
        source = "../.."
    }
