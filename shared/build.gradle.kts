import org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget
import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform")
    kotlin("plugin.serialization") version "1.6.0"
    id("com.android.library")
}

kotlin {
    android()
    val xcf = XCFramework()
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64(),
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
            xcf.add(this)
        }
    }
    js {
        browser {
            binaries.executable()
            commonWebpackConfig {
            }
        }
    }
    sourceSets {
        val ktorVersion = "1.6.7"
        val coroutinesVersion = "1.6.0"

        val commonMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-core:$ktorVersion")
                implementation("io.ktor:ktor-client-serialization:$ktorVersion")
                implementation("io.ktor:ktor-client-logging:$ktorVersion")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesVersion-native-mt")
                implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.1.0")

            }
        }
        val androidMain by getting {
            dependencies {
                implementation("io.ktor:ktor-client-android:$ktorVersion")
                implementation("com.google.android.material:material:1.3.0")
                implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:$coroutinesVersion")
            }
        }
        val iosX64Main by getting
        val iosArm64Main by getting
        val macosX64Main by getting
        val macosArm64Main by getting
        val iosSimulatorArm64Main by getting
        val iosMain by creating {
            dependsOn(commonMain)
            iosX64Main.dependsOn(this)
            iosArm64Main.dependsOn(this)
            iosSimulatorArm64Main.dependsOn(this)
            macosArm64Main.dependsOn(this)
            macosX64Main.dependsOn(this)
            dependencies {
                implementation("io.ktor:ktor-client-ios:$ktorVersion")
            }
        }
//        val jsMain by getting {
//            dependencies {
//                implementation("org.jetbrains:kotlin-react:17.0.1-pre.148-kotlin-1.4.21")
//                implementation("org.jetbrains:kotlin-react-dom:17.0.1-pre.148-kotlin-1.4.21")
//                implementation(npm("react", "17.0.1"))
//                implementation(npm("react-dom", "17.0.1"))
//                implementation("org.jetbrains:kotlin-styled:5.2.1-pre.148-kotlin-1.4.21")
//                implementation(npm("styled-components", "~5.2.1"))
//
//                implementation("io.ktor:ktor-client-js:$ktorVersion")
//                implementation("io.ktor:ktor-client-json-js:$ktorVersion")
//                implementation("io.ktor:ktor-client-serialization-js:$ktorVersion")
//            }
//        }
    }
}

android {
    compileSdkVersion(30)
    sourceSets["main"].manifest.srcFile("src/androidMain/AndroidManifest.xml")
    defaultConfig {
        minSdkVersion(24)
        targetSdkVersion(30)
    }
}