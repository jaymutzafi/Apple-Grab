import 'dart:io';

import 'package:flutter_grab_bridge/flutter_grab_bridge.dart';
import 'package:test/test.dart';

void main() {
  test('doctor reports expected paths', () async {
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'flutter_grab_bridge_doctor.',
    );
    await File(
      '${tempDirectory.path}${Platform.pathSeparator}pubspec.yaml',
    ).writeAsString('name: demo');

    final BridgeCommandResult result = await runFlutterGrabBridge(
      const <String>['doctor'],
      workingDirectory: tempDirectory,
    );

    expect(result.exitCode, 0);
    expect(result.stdout, contains('Flutter project detected: yes'));
    expect(result.stdout, contains('.dart_tool'));
  });

  test('latest reads exported text or json payloads', () async {
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'flutter_grab_bridge_latest.',
    );
    final Directory captureDirectory = Directory(
      '${tempDirectory.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}flutter_grab',
    );
    await captureDirectory.create(recursive: true);
    final File textFile = File(
      '${captureDirectory.path}${Platform.pathSeparator}latest_capture.txt',
    );
    final File jsonFile = File(
      '${captureDirectory.path}${Platform.pathSeparator}latest_capture.json',
    );
    await textFile.writeAsString('prompt body');
    await jsonFile.writeAsString('{"ok":true}');

    final BridgeCommandResult textResult = await runFlutterGrabBridge(
      const <String>['latest'],
      workingDirectory: tempDirectory,
    );
    final BridgeCommandResult jsonResult = await runFlutterGrabBridge(
      const <String>['latest', '--json'],
      workingDirectory: tempDirectory,
    );

    expect(textResult.exitCode, 0);
    expect(textResult.stdout, contains('prompt body'));
    expect(jsonResult.exitCode, 0);
    expect(jsonResult.stdout, contains('"ok":true'));
  });
}
