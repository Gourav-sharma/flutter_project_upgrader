import 'dart:io';
import 'package:flutter_project_upgrader/upgrader.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: flutter pub run flutter_project_upgrader <command> [options]');
    print('Commands: check, upgrade');
    exit(0);
  }

  final command = args.first;
  final options = args.sublist(1);

  switch (command) {
    case 'check':
      ProjectUpgrader().check();
      break;
    case 'upgrade':
      ProjectUpgrader().upgradeFromArgs(options);
      break;
    default:
      print('Unknown command: $command');
  }
}
