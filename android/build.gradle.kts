allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // The `home_widget` plugin pulls `androidx.glance:glance-appwidget:1.+`, whose
    // dynamic range now resolves to a 1.3.0 alpha that requires compileSdk 37 +
    // AGP 9.1.0. Pin every module to the latest stable glance so the project stays
    // on the Flutter-default compileSdk/AGP. Revisit once home_widget pins it.
    configurations.all {
        resolutionStrategy {
            force("androidx.glance:glance-appwidget:1.1.1")
            force("androidx.glance:glance:1.1.1")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
