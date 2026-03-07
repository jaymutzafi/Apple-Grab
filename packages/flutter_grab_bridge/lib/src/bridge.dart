import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class BridgeCommandResult {
  const BridgeCommandResult({
    required this.exitCode,
    this.stdout = '',
    this.stderr = '',
  });

  final int exitCode;
  final String stdout;
  final String stderr;
}

Future<BridgeCommandResult> runFlutterGrabBridge(
  List<String> args, {
  Directory? workingDirectory,
  void Function(String message)? onOutput,
}) async {
  final Directory directory = workingDirectory ?? Directory.current;
  final void Function(String message) emit = onOutput ?? (_) {};
  if (args.isEmpty) {
    return BridgeCommandResult(exitCode: 1, stderr: _usage);
  }

  switch (args.first) {
    case 'latest':
      final bool asJson = args.contains('--json');
      return _readLatest(directory, asJson: asJson);
    case 'doctor':
      return _doctor(directory);
    case 'watch':
      final bool asJson = args.contains('--json');
      return _watch(directory, asJson: asJson, onOutput: emit);
    default:
      return BridgeCommandResult(exitCode: 1, stderr: _usage);
  }
}

Future<BridgeCommandResult> _readLatest(
  Directory directory, {
  required bool asJson,
}) async {
  final _BridgePaths paths = _BridgePaths.forDirectory(directory);
  final File target = asJson ? File(paths.jsonPath) : File(paths.textPath);
  if (!await target.exists()) {
    return BridgeCommandResult(
      exitCode: 1,
      stderr:
          'No flutter_grab capture was found yet.\n'
          'Expected: ${target.path}\n'
          'Run your app in debug mode, select a widget, then export a capture.',
    );
  }

  return BridgeCommandResult(exitCode: 0, stdout: await target.readAsString());
}

Future<BridgeCommandResult> _doctor(Directory directory) async {
  final _BridgePaths paths = _BridgePaths.forDirectory(directory);
  final bool hasPubspec = await File(
    p.join(directory.path, 'pubspec.yaml'),
  ).exists();
  final bool hasJson = await File(paths.jsonPath).exists();
  final bool hasText = await File(paths.textPath).exists();

  final Map<String, Object?> payload = <String, Object?>{
    'project': directory.path,
    'looksLikeFlutterProject': hasPubspec,
    'jsonPath': paths.jsonPath,
    'textPath': paths.textPath,
    'jsonExists': hasJson,
    'textExists': hasText,
  };

  final StringBuffer out = StringBuffer()
    ..writeln('flutter_grab bridge doctor')
    ..writeln('Project: ${directory.path}')
    ..writeln('Flutter project detected: ${hasPubspec ? 'yes' : 'no'}')
    ..writeln('Expected JSON export: ${paths.jsonPath}')
    ..writeln('Expected text export: ${paths.textPath}')
    ..writeln('JSON export found: ${hasJson ? 'yes' : 'no'}')
    ..writeln('Text export found: ${hasText ? 'yes' : 'no'}')
    ..writeln()
    ..writeln('Machine-readable status:')
    ..writeln(const JsonEncoder.withIndent('  ').convert(payload));

  return BridgeCommandResult(exitCode: 0, stdout: out.toString().trimRight());
}

Future<BridgeCommandResult> _watch(
  Directory directory, {
  required bool asJson,
  required void Function(String message) onOutput,
}) async {
  final _BridgePaths paths = _BridgePaths.forDirectory(directory);
  final File target = File(asJson ? paths.jsonPath : paths.textPath);

  onOutput(
    'Watching ${target.path} for flutter_grab captures. Press Ctrl+C to stop.',
  );
  if (await target.exists()) {
    onOutput(await target.readAsString());
  }

  final Completer<BridgeCommandResult> done = Completer<BridgeCommandResult>();

  late final StreamSubscription<FileSystemEvent> subscription;
  late final StreamSubscription<ProcessSignal> signalSubscription;

  Future<void> finish(BridgeCommandResult result) async {
    await subscription.cancel();
    await signalSubscription.cancel();
    if (!done.isCompleted) {
      done.complete(result);
    }
  }

  subscription = target.parent
      .watch()
      .where(
        (FileSystemEvent event) =>
            p.normalize(event.path) == p.normalize(target.path),
      )
      .listen(
        (FileSystemEvent _) async {
          if (await target.exists()) {
            onOutput('---');
            onOutput(await target.readAsString());
          }
        },
        onError: (Object error, StackTrace stackTrace) async {
          await finish(
            BridgeCommandResult(
              exitCode: 1,
              stderr: 'Failed while watching flutter_grab exports: $error',
            ),
          );
        },
      );

  signalSubscription = ProcessSignal.sigint.watch().listen((_) async {
    await finish(const BridgeCommandResult(exitCode: 0));
  });

  return done.future;
}

class _BridgePaths {
  const _BridgePaths({required this.jsonPath, required this.textPath});

  factory _BridgePaths.forDirectory(Directory directory) {
    final String base = p.join(
      directory.path,
      '.dart_tool',
      'flutter_grab',
      'latest_capture',
    );
    return _BridgePaths(jsonPath: '$base.json', textPath: '$base.txt');
  }

  final String jsonPath;
  final String textPath;
}

const String _usage = '''
Usage:
  dart run flutter_grab_bridge latest [--json]
  dart run flutter_grab_bridge doctor
  dart run flutter_grab_bridge watch [--json]
''';
