plugins {
    id("com.android.application")
    kotlin("android")
}


android {
    compileSdkVersion(30)
    defaultConfig {
        applicationId = "uk.co.amlcurran.pocketish.androidApp"
        minSdkVersion(24)
        targetSdkVersion(30)
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }
    buildFeatures {
        compose = true
        viewBinding = true
    }
    composeOptions {
        kotlinCompilerVersion =  "1.5.10"
        kotlinCompilerExtensionVersion = "1.0.0-rc01"
    }
}

dependencies {
    implementation(project(":shared"))
    implementation("com.google.android.material:material:1.3.0")
    implementation("androidx.appcompat:appcompat:1.3.0")
    implementation("androidx.constraintlayout:constraintlayout:2.0.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.3.0")

    implementation("androidx.compose.ui:ui:1.0.0-rc01")
    implementation("androidx.compose.ui:ui-tooling:1.0.0-rc01")
    implementation("androidx.compose.foundation:foundation:1.0.0-rc01")
    implementation("androidx.compose.material:material:1.0.0-rc01")
    implementation("androidx.compose.material:material-icons-core:1.0.0-rc01")
    implementation("androidx.compose.material:material-icons-extended:1.0.0-rc01")
}
