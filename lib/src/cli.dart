import '../flutter_project_upgrader.dart';

void runCli(List<String> arguments) {
  final upgrader = ProjectUpgrader();

  if (arguments.isEmpty) {
    print('Usage: dart run flutter_project_upgrader upgrade [options]');
    print('''
Options:
  --gradle <version>
  --agp <version>
  --kotlin <version>
  --ios <version>
  --swift <version>
  --pods
''');
    return;
  }

  if (arguments.first == 'upgrade') {
    upgrader.upgradeFromArgs(arguments.skip(1).toList());
  } else if (arguments.first == 'check') {
    upgrader.check();
  } else {
    print('❌ Unknown command: ${arguments.first}');
  }
}
