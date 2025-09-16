// import 'dart:developer';
// import 'dart:io';
//
// class ProjectUpgrader {
//   void check() {
//     log("Checking project versions...");
//     // TODO: parse current versions if you want to show
//   }
//
//   void upgradeFromArgs(List<String> args) {
//     String? gradle;
//     String? agp;
//     String? kotlin;
//     String? ios;
//     String? swift;
//     bool updatePods = false;
//
//     for (int i = 0; i < args.length; i++) {
//       switch (args[i]) {
//         case '--gradle':
//           gradle = args[i + 1];
//           i++;
//           break;
//         case '--agp':
//           agp = args[i + 1];
//           i++;
//           break;
//         case '--kotlin':
//           kotlin = args[i + 1];
//           i++;
//           break;
//         case '--ios':
//           ios = args[i + 1];
//           i++;
//           break;
//         case '--swift':
//           swift = args[i + 1];
//           i++;
//           break;
//         case '--pods':
//           updatePods = true;
//           break;
//       }
//     }
//
//     performUpgrade(
//       gradle: gradle,
//       agp: agp,
//       kotlin: kotlin,
//       ios: ios,
//       swift: swift,
//       pods: updatePods,
//     );
//   }
//
//   void performUpgrade({
//     String? gradle,
//     String? agp,
//     String? kotlin,
//     String? ios,
//     String? swift,
//     bool pods = false,
//   }) {
//     print("🔧 Performing upgrade...");
//
//     if (gradle != null || agp != null || kotlin != null) {
//       upgradeAndroid(
//         gradleVersion: gradle,
//         agpVersion: agp,
//         kotlinVersion: kotlin,
//       );
//     }
//
//     if (ios != null || swift != null || pods) {
//       upgradeIOS(
//         iosVersion: ios,
//         swiftVersion: swift,
//         updatePods: pods,
//       );
//     }
//   }
//
//   // ---------------- ANDROID ----------------
//   void upgradeAndroid({
//     String? gradleVersion,
//     String? agpVersion,
//     String? kotlinVersion,
//   }) {
//     print("⚡ Upgrading Android...");
//
//     // gradle-wrapper.properties
//     if (gradleVersion != null) {
//       final gradleFile =
//       File('android/gradle/wrapper/gradle-wrapper.properties');
//       if (gradleFile.existsSync()) {
//         var content = gradleFile.readAsStringSync();
//         content = content.replaceAllMapped(
//           RegExp(r'distributionUrl=.*gradle-[\d.]+-all.zip'),
//               (match) =>
//           'distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradleVersion-all.zip',
//         );
//         gradleFile.writeAsStringSync(content);
//         print("✅ Gradle updated to $gradleVersion");
//       }
//     }
//
//     // build.gradle (project level)
//     final buildFile = File('android/build.gradle');
//     if (buildFile.existsSync()) {
//       var content = buildFile.readAsStringSync();
//
//       if (agpVersion != null) {
//         content = content.replaceAllMapped(
//           RegExp(r'com.android.tools.build:gradle:[\d.]+'),
//               (match) => 'com.android.tools.build:gradle:$agpVersion',
//         );
//         print("✅ AGP (build.gradle) updated to $agpVersion");
//       }
//
//       if (kotlinVersion != null) {
//         content = content.replaceAllMapped(
//           RegExp("ext\\.kotlin_version\\s*=\\s*[\"'][0-9.]+[\"']"),
//               (match) => 'ext.kotlin_version = "$kotlinVersion"',
//         );
//         print("✅ Kotlin (build.gradle) updated to $kotlinVersion");
//       }
//
//       buildFile.writeAsStringSync(content);
//     }
//
//     // settings.gradle (plugins)
//     final settingsFile = File('android/settings.gradle');
//     if (settingsFile.existsSync()) {
//       var content = settingsFile.readAsStringSync();
//
//       if (agpVersion != null) {
//         content = content.replaceAllMapped(
//           RegExp(r'id\s+"com\.android\.application"\s+version\s+"[\d.]+"'),
//               (match) => 'id "com.android.application" version "$agpVersion"',
//         );
//         content = content.replaceAllMapped(
//           RegExp(r'id\s+"com\.android\.library"\s+version\s+"[\d.]+"'),
//               (match) => 'id "com.android.library" version "$agpVersion"',
//         );
//         print("✅ AGP (settings.gradle) updated to $agpVersion");
//       }
//
//       if (kotlinVersion != null) {
//         content = content.replaceAllMapped(
//           RegExp(
//               r'id\s+"org\.jetbrains\.kotlin\.android"\s+version\s+"[\d.]+"'),
//               (match) =>
//           'id "org.jetbrains.kotlin.android" version "$kotlinVersion"',
//         );
//         print("✅ Kotlin (settings.gradle) updated to $kotlinVersion");
//       }
//
//       settingsFile.writeAsStringSync(content);
//     }
//   }
//
//   // ---------------- IOS ----------------
//   void upgradeIOS({
//     String? iosVersion,
//     String? swiftVersion,
//     bool updatePods = false,
//   }) {
//     print("⚡ Upgrading iOS...");
//
//     // Podfile
//     if (iosVersion != null) {
//       final podFile = File('ios/Podfile');
//       if (podFile.existsSync()) {
//         var content = podFile.readAsStringSync();
//         content = content.replaceAllMapped(
//           RegExp(r"platform :ios, '\d+(\.\d+)?'"),
//               (match) => "platform :ios, '$iosVersion'",
//         );
//         podFile.writeAsStringSync(content);
//         print("✅ iOS platform updated to $iosVersion");
//       }
//     }
//
//     // Swift version in project.pbxproj
//     if (swiftVersion != null) {
//       final pbxFile = File('ios/Runner.xcodeproj/project.pbxproj');
//       if (pbxFile.existsSync()) {
//         var content = pbxFile.readAsStringSync();
//         content = content.replaceAllMapped(
//           RegExp(r'SWIFT_VERSION = [\d.]+;'),
//               (match) => 'SWIFT_VERSION = $swiftVersion;',
//         );
//         pbxFile.writeAsStringSync(content);
//         print("✅ Swift updated to $swiftVersion");
//       }
//     }
//
//     if (updatePods) {
//       if (Platform.isMacOS) {
//         print("📦 Running pod install...");
//         final result =
//         Process.runSync('pod', ['install'], workingDirectory: 'ios');
//         if (result.exitCode == 0) {
//           print("✅ Pods installed successfully");
//         } else {
//           print("❌ pod install failed:\n${result.stderr}");
//         }
//       } else {
//         print("ℹ️ Skipping pod install (only available on macOS)");
//       }
//     }
//   }
// }


import 'dart:developer';
import 'dart:io';

class ProjectUpgrader {
  void check() {
    log("Checking project versions...");
    // TODO: parse current versions if you want to show
  }

  void upgradeFromArgs(List<String> args) {
    String? gradle;
    String? agp;
    String? kotlin;
    String? ios;
    String? swift;
    bool updatePods = false;

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--gradle':
          gradle = args[i + 1];
          i++;
          break;
        case '--agp':
          agp = args[i + 1];
          i++;
          break;
        case '--kotlin':
          kotlin = args[i + 1];
          i++;
          break;
        case '--ios':
          ios = args[i + 1];
          i++;
          break;
        case '--swift':
          swift = args[i + 1];
          i++;
          break;
        case '--pods':
          updatePods = true;
          break;
      }
    }

    performUpgrade(
      gradle: gradle,
      agp: agp,
      kotlin: kotlin,
      ios: ios,
      swift: swift,
      pods: updatePods,
    );
  }

  void performUpgrade({
    String? gradle,
    String? agp,
    String? kotlin,
    String? ios,
    String? swift,
    bool pods = false,
  }) {
    print("🔧 Performing upgrade...");

    if (gradle != null || agp != null || kotlin != null) {
      upgradeAndroid(
        gradleVersion: gradle,
        agpVersion: agp,
        kotlinVersion: kotlin,
      );
    }

    if (ios != null || swift != null || pods) {
      upgradeIOS(
        iosVersion: ios,
        swiftVersion: swift,
        updatePods: pods,
      );
    }
  }

  // ---------------- ANDROID ----------------
  void upgradeAndroid({
    String? gradleVersion,
    String? agpVersion,
    String? kotlinVersion,
  }) {
    print("⚡ Upgrading Android...");

    // gradle-wrapper.properties
    if (gradleVersion != null) {
      final gradleFile =
      File('android/gradle/wrapper/gradle-wrapper.properties');
      if (gradleFile.existsSync()) {
        var content = gradleFile.readAsStringSync();
        content = content.replaceAllMapped(
          RegExp(r'distributionUrl=.*gradle-[\d.]+-all.zip'),
              (match) =>
          'distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradleVersion-all.zip',
        );
        gradleFile.writeAsStringSync(content);
        print("✅ Gradle updated to $gradleVersion");
      }
    }

    // build.gradle (project level)
    final buildFile = File('android/build.gradle');
    if (buildFile.existsSync()) {
      var content = buildFile.readAsStringSync();

      if (agpVersion != null) {
        content = content.replaceAllMapped(
          RegExp(r'com.android.tools.build:gradle:[\d.]+'),
              (match) => 'com.android.tools.build:gradle:$agpVersion',
        );
        print("✅ AGP (build.gradle) updated to $agpVersion");
      }

      if (kotlinVersion != null) {
        content = content.replaceAllMapped(
          RegExp(r'id\s+"com\.android\.library"\s+version\s+"[\d.]+"'),
              (match) => 'ext.kotlin_version = "$kotlinVersion"',
        );
        print("✅ Kotlin (build.gradle) updated to $kotlinVersion");
      }

      buildFile.writeAsStringSync(content);
    }

    // settings.gradle (plugins)
    final settingsFile = File('android/settings.gradle');
    if (settingsFile.existsSync()) {
      var content = settingsFile.readAsStringSync();

      if (agpVersion != null) {
        // Update com.android.application
        content = content.replaceAllMapped(
          RegExp(r'id\s+"com\.android\.application"\s+version\s+"[\d.]+"'),
              (match) => 'id "com.android.application" version "$agpVersion"',
        );
        // Update com.android.library
        content = content.replaceAllMapped(
          RegExp(r'id\s+"com\.android\.library"\s+version\s+"[\d.]+"'),
              (match) => 'id "com.android.library" version "$agpVersion"',
        );
        print("✅ AGP (settings.gradle) updated to $agpVersion");
      }

      if (kotlinVersion != null) {
        content = content.replaceAllMapped(
          RegExp(r'id\s+"org\.jetbrains\.kotlin\.android"\s+version\s+"[\d.]+"'),
              (match) => 'id "org.jetbrains.kotlin.android" version "$kotlinVersion"',
        );
        print("✅ Kotlin (settings.gradle) updated to $kotlinVersion");
      }

      settingsFile.writeAsStringSync(content);
    }
  }

  // ---------------- IOS ----------------
  void upgradeIOS({
    String? iosVersion,
    String? swiftVersion,
    bool updatePods = false,
  }) {
    print("⚡ Upgrading iOS...");

    // Podfile
    if (iosVersion != null) {
      final podFile = File('ios/Podfile');
      if (podFile.existsSync()) {
        var content = podFile.readAsStringSync();
        content = content.replaceAllMapped(
          RegExp(r"platform :ios, '\d+(\.\d+)?'"),
              (match) => "platform :ios, '$iosVersion'",
        );
        podFile.writeAsStringSync(content);
        print("✅ iOS platform updated to $iosVersion");
      }
    }

    // Swift version in project.pbxproj
    if (swiftVersion != null) {
      final pbxFile = File('ios/Runner.xcodeproj/project.pbxproj');
      if (pbxFile.existsSync()) {
        var content = pbxFile.readAsStringSync();
        content = content.replaceAllMapped(
          RegExp(r'SWIFT_VERSION = [\d.]+;'),
              (match) => 'SWIFT_VERSION = $swiftVersion;',
        );
        pbxFile.writeAsStringSync(content);
        print("✅ Swift updated to $swiftVersion");
      }
    }

    if (updatePods) {
      if (Platform.isMacOS) {
        print("📦 Running pod install...");
        final result =
        Process.runSync('pod', ['install'], workingDirectory: 'ios');
        if (result.exitCode == 0) {
          print("✅ Pods installed successfully");
        } else {
          print("❌ pod install failed:\n${result.stderr}");
        }
      } else {
        print("ℹ️ Skipping pod install (only available on macOS)");
      }
    }
  }
}
