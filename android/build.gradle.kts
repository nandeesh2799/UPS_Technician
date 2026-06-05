plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val configureSdk = { p: Project ->
        if (p.plugins.hasPlugin("com.android.library")) {
            p.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 36
            }
        }
    }
    
    val currentProject = this
    if (currentProject.state.executed) {
        configureSdk(currentProject)
    } else {
        currentProject.afterEvaluate {
            configureSdk(currentProject)
        }
    }
    
    currentProject.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
