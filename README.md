# flutter_project_upgrader

A Flutter plugin to **easily upgrade your Flutter project’s dependencies and platform configurations** such as **Gradle, AGP (Android Gradle Plugin), Kotlin, iOS platform version, Swift version, and CocoaPods**.

This tool helps developers keep their Flutter projects up to date without manually editing multiple files like:

- `android/gradle/wrapper/gradle-wrapper.properties`
- `android/build.gradle`
- `android/settings.gradle`
- `ios/Podfile`
- `ios/Runner.xcodeproj/project.pbxproj`

---

## ✨ Features
- 🔧 Upgrade **Gradle version** in `gradle-wrapper.properties`
- ⚡ Upgrade **AGP (Android Gradle Plugin)** in both `build.gradle` and `settings.gradle`
- 📌 Upgrade **Kotlin version** in both `build.gradle` and `settings.gradle`
- 🍏 Upgrade **iOS deployment target** in `Podfile`
- 🧑‍💻 Upgrade **Swift version** in `project.pbxproj`
- 📦 Optionally run **pod install** after updating iOS configs

---

## 🚀 Getting Started

Add this package as a **dev dependency** in your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_project_upgrader:
    path: ./flutter_project_upgrader

```

```usage
flutter pub run flutter_project_upgrader:upgrade --gradle 7.5.0 --agp 7.2.0 --kotlin 1.8.22 --ios 16.0 --swift 5.7 --pods
```

```
Note: 
if you don't see any changes after successfull output in terminal, then please close all files and reopen them.
```