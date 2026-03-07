import 'dart:io';

import 'package:flutter_grab_bridge/flutter_grab_bridge.dart';

Future<void> main(List<String> args) async {
  final BridgeCommandResult result = await runFlutterGrabBridge(args);
  if (result.stdout.isNotEmpty) {
    stdout.writeln(result.stdout);
  }
  if (result.stderr.isNotEmpty) {
    stderr.writeln(result.stderr);
  }
  exitCode = result.exitCode;
}
