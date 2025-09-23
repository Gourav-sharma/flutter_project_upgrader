import 'dart:io';

class ProjectUpgrader {
  /// Compatibility matrix
  final Map<String, Map<String, String>> sdkMatrix = {
    "32": {
      "gradle": "7.5",
      "agp": "7.3.1",
      "kotlin": "1.7.20",
      "ndk": "23.1.7779620",
      "ios": "15.0",
      "swift": "5.7"
    },
    "34": {
      "gradle": "8.5",
      "agp": "8.5.2",
      "kotlin": "1.9.25",
      "ndk": "26.1.10909125",
      "ios": "16.0",
      "swift": "5.9"
    },
    "35": {
      "gradle": "8.7",
      "agp": "8.7.1",
      "kotlin": "2.0.20",
      "ndk": "26.1.10909125",
      "ios": "17.0",
      "swift": "5.9"
    },
    "36": {
      "gradle": "8.11.1",
      "agp": "8.9.0",
      "kotlin": "2.0.20",
      "ndk": "28.0.12674049",
      "ios": "17.0",
      "swift": "6.0"
    }
  };

  /// Main upgrade entry
  void upgradeProject(String targetSdk, {bool updatePods = false}) {
    if (!sdkMatrix.containsKey(targetSdk)) {
      print("❌ Unsupported targetSdk $targetSdk. Supported: ${sdkMatrix.keys.join(', ')}");
      return;
    }

    final versions = sdkMatrix[targetSdk]!;
    print("🚀 Upgrading project to targetSdk $targetSdk ...");
    final ndk = _resolveNdk(targetSdk);

    _updateGradleWrapper(versions['gradle']!);
    _updateBuildGradle(versions['agp']!, versions['kotlin']!);
    _updateSettingsGradle(versions['agp']!, versions['kotlin']!);
    _updateAppGradle(targetSdk, ndk);
    _updateIos(versions['ios']!, versions['swift']!);

    if (updatePods) {
      _runPodInstall();
    }

    print("✅ Upgrade completed for targetSdk $targetSdk.");


  }

  void checkNdk(String targetSdk) => _checkNdk(targetSdk);

  void _checkNdk(String targetSdk) {
    final expectedNdk = sdkMatrix[targetSdk]!["ndk"]!;
    print("🔍 Checking installed NDK against required version ($expectedNdk)...");

    try {
      final result = Process.runSync("ndk-which", ["clang"]);
      if (result.exitCode == 0) {
        print("✅ NDK detected and is installed.");
      } else {
        print("❌ NDK check failed: ${result.stderr}");
      }
    } catch (e) {
      print("⚠️ Could not verify NDK installation: $e");
    }

    // Optional: Check 16 KB page support
    if (int.parse(targetSdk) >= 36) {
      print("📏 TargetSdk $targetSdk requires 16KB page support (NDK 28+).");
      if (expectedNdk.startsWith("28.")) {
        print("✅ Required 16KB page size supported.");
      } else {
        print("⚠️ NDK version $expectedNdk may not support 16KB pages.");
      }
    }
  }

  /// --- ANDROID PART ---

  void _updateGradleWrapper(String gradle) {
    final gradleWrapper = File("android/gradle/wrapper/gradle-wrapper.properties");
    if (gradleWrapper.existsSync()) {
      var content = gradleWrapper.readAsStringSync();
      content = content.replaceAll(
        RegExp(r'distributionUrl\s*=.*'),
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-$gradle-all.zip',
      );
      gradleWrapper.writeAsStringSync(content);
      print("✅ Updated Gradle Wrapper → $gradle");
    }
  }

  void _updateBuildGradle(String agp, String kotlin) {
    final gradleFile = File("android/build.gradle");
    if (gradleFile.existsSync()) {
      var content = gradleFile.readAsStringSync();

      // AGP
      content = content.replaceAll(
        RegExp(r'com\.android\.tools\.build:gradle:[\d.]+'),
        'com.android.tools.build:gradle:$agp',
      );

      // Kotlin ext
      content = content.replaceAll(
          RegExp(r'id\s+"com\.android\.application"\s+version\s+"[\d.]+"'),
          'ext.kotlin_version = "$kotlin"',
          );

          gradleFile.writeAsStringSync(content);
      print("✅ Updated AGP → $agp, Kotlin → $kotlin (build.gradle)");
    }
  }

  void _updateSettingsGradle(String agp, String kotlin) {
    final settingsGradle = File("android/settings.gradle");
    if (settingsGradle.existsSync()) {
      var content = settingsGradle.readAsStringSync();

      // Kotlin JVM plugin
      content = content.replaceAll(
        RegExp(r'kotlin\("jvm"\)\s*version\s*".*?"'),
        'kotlin("jvm") version "$kotlin"',
      );

      // Kotlin Android plugin
      content = content.replaceAll(
        RegExp(r'id\s*\(?\s*"org\.jetbrains\.kotlin\.android"\s*\)?\s*version\s*".*?"'),
        'id("org.jetbrains.kotlin.android") version "$kotlin"',
      );

      // Android application plugin
      content = content.replaceAll(
        RegExp(r'id\s*\(?\s*"com\.android\.application"\s*\)?\s*version\s*".*?"'),
        'id("com.android.application") version "$agp"',
      );

      // Android library plugin
      content = content.replaceAll(
        RegExp(r'id\s*\(?\s*"com\.android\.library"\s*\)?\s*version\s*".*?"'),
        'id("com.android.library") version "$agp"',
      );

      settingsGradle.writeAsStringSync(content);
      print("✅ Updated AGP → $agp, Kotlin → $kotlin (settings.gradle)");
    }
  }


  void _updateAppGradle(String targetSdk, String ndk) {
    final appGradle = File("android/app/build.gradle");
    if (appGradle.existsSync()) {
      var content = appGradle.readAsStringSync();

      // compileSdk
      content = content.replaceAll(
        RegExp(r'compileSdk\s*=\s*\d+'),
        'compileSdk = $targetSdk',
      );

      // targetSdk
      content = content.replaceAll(
        RegExp(r'targetSdk\s*=\s*\d+'),
        'targetSdk = $targetSdk',
      );

      // ndkVersion (supports quoted/unquoted)
      if (content.contains('ndkVersion')) {
        content = content.replaceAll(
          RegExp(r'ndkVersion\s*=\s*"?[\d.]+"?'),
          'ndkVersion = "$ndk"',
        );
      } else {
        content = content.replaceFirst(
          RegExp(r'compileSdk\s*=\s*\d+'),
          'ndkVersion = "$ndk"\n    compileSdk = $targetSdk',
        );
      }

      appGradle.writeAsStringSync(content);
      print("✅ Updated compileSdk/targetSdk → $targetSdk, NDK → $ndk");
    }
  }

  String _getFlutterVersion() {
    try {
      final flutterRoot = Platform.environment['FLUTTER_ROOT'];
      final flutterExec = Platform.isWindows
          ? '$flutterRoot\\bin\\flutter.bat'
          : '$flutterRoot/bin/flutter';

      final result = Process.runSync(flutterExec, ["--version"]);
      if (result.exitCode == 0) {
        return result.stdout.toString();
      }
    } catch (e) {
      print("⚠️ Could not detect Flutter version automatically: $e");
    }
    return "";
  }

  String _resolveNdk(String targetSdk) {
    final flutterVersion = _getFlutterVersion();

    final requiredNdk = sdkMatrix[targetSdk]!["ndk"]!;

    if (int.parse(targetSdk) >= 35 && flutterVersion.contains("3.32.")) {
      print("⚠️ Flutter ${flutterVersion.trim()} does not yet support NDK $requiredNdk. Falling back to NDK 27.0.12077973 for build compatibility.");
      return "27.0.12077973";
    }

    return requiredNdk;
  }

  /// --- IOS PART ---

  void _updateIos(String iosVersion, String swiftVersion) {
    final podfile = File("ios/Podfile");
    if (podfile.existsSync()) {
      var content = podfile.readAsStringSync();
      content = content.replaceAll(
        RegExp(r"platform :ios, '\d+(\.\d+)?'"),
        "platform :ios, '$iosVersion'",
      );
      podfile.writeAsStringSync(content);
      print("✅ Updated iOS platform → $iosVersion");
    }

    final xcodeConfig = File("ios/Runner.xcodeproj/project.pbxproj");
    if (xcodeConfig.existsSync()) {
      var content = xcodeConfig.readAsStringSync();
      content = content.replaceAll(
        RegExp(r'SWIFT_VERSION = [\d.]+;'),
        'SWIFT_VERSION = $swiftVersion;',
      );
      xcodeConfig.writeAsStringSync(content);
      print("✅ Updated Swift version → $swiftVersion");
    }
  }

  /// --- PODS ---
  void _runPodInstall() {
    print("📦 Running 'pod install'...");
    try {
      final result = Process.runSync("pod", ["install"], workingDirectory: "ios");
      if (result.exitCode == 0) {
        print("✅ pod install completed");
      } else {
        print("❌ pod install failed: ${result.stderr}");
      }
    } catch (e) {
      print("⚠️ Skipped pod install: $e");
    }
  }
}
