import '../flutter_project_upgrader.dart';

void runCli(List<String> arguments) {
  final upgrader = ProjectUpgrader();

  if (arguments.isEmpty) {
    print('Usage: dart run flutter_project_upgrader <command> [options]');
    print('''
Commands:
  upgrade       Upgrade project versions
  check         Print current project versions

Options (for upgrade):
  --targetSdk <version>   Upgrade using compatibility matrix (32–36)
  --pods                  Run pod install (macOS only)
''');
    return;
  }

  switch (arguments.first) {
    case 'upgrade':
      final args = arguments.skip(1).toList();

      final targetSdkIndex = args.indexOf('--targetSdk');
      if (targetSdkIndex == -1 || targetSdkIndex + 1 >= args.length) {
        print('❌ Missing required --targetSdk <version> argument');
        return;
      }

      final targetSdk = args[targetSdkIndex + 1];
      final runPods = args.contains('--pods');

      upgrader.upgradeProject(targetSdk, updatePods: runPods);
      break;

    default:
      print('❌ Unknown command: ${arguments.first}');
      break;
  }
}
