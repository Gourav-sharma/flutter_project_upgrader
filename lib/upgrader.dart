import 'dart:developer';

class ProjectUpgrader {
  void check() {
    log("Checking project versions...");
    // TODO: parse build.gradle, Podfile etc and print current versions
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
          gradle = args[i + 1]; i++; break;
        case '--agp':
          agp = args[i + 1]; i++; break;
        case '--kotlin':
          kotlin = args[i + 1]; i++; break;
        case '--ios':
          ios = args[i + 1]; i++; break;
        case '--swift':
          swift = args[i + 1]; i++; break;
        case '--pods':
          updatePods = true; break;
      }
    }

    upgradeAndroid(gradleVersion: gradle, agpVersion: agp, kotlinVersion: kotlin);
    upgradeIOS(iosVersion: ios, swiftVersion: swift, updatePods: updatePods);
  }

  void upgradeAndroid({String? gradleVersion, String? agpVersion, String? kotlinVersion}) {
    log("⚡ Upgrading Android...");
    // TODO: implement replacing in build.gradle and gradle-wrapper.properties
  }

  void upgradeIOS({String? iosVersion, String? swiftVersion, bool updatePods = false}) {
    log("⚡ Upgrading iOS...");
    // TODO: implement Podfile + pbxproj updates
  }
}
