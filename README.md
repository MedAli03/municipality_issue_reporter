# flutter_application

A new Flutter project.

## Build requirements (Android)

- JDK 17 is required for Android builds.
- In Android Studio, set **Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JDK** to a JDK 17 install.
- Or set `JAVA_HOME` before running Gradle/Flutter:
  - PowerShell: `$env:JAVA_HOME="C:\\Path\\To\\JDK17"`
- You can also set `org.gradle.java.home` in `android/gradle.properties` to pin Gradle to JDK 17.
- Firebase integration is postponed to the final step; no `google-services.json` is needed right now.
- Generate Hive adapters with: `flutter pub run build_runner build --delete-conflicting-outputs`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
