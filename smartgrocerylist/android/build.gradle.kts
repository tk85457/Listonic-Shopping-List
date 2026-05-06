plugins {
    // Add the dependency for the Google services Gradle plugin
}

buildscript {
    dependencies {
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    // AGP 8+ requires namespace in every Android module.
    // Some older plugins (for example from pub cache) still omit it.
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val getNamespace =
            androidExtension.javaClass.methods.firstOrNull {
                it.name == "getNamespace" && it.parameterCount == 0
            } ?: return@afterEvaluate
        val currentNamespace = getNamespace.invoke(androidExtension) as? String
        if (!currentNamespace.isNullOrBlank()) return@afterEvaluate

        val setNamespace =
            androidExtension.javaClass.methods.firstOrNull {
                it.name == "setNamespace" && it.parameterCount == 1
            } ?: return@afterEvaluate
        val fallbackNamespace = "com.tk854.listonic.${project.name.replace('-', '_')}"
        setNamespace.invoke(androidExtension, fallbackNamespace)
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
