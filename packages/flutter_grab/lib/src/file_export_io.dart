import 'dart:io';

import 'package:path/path.dart' as p;

import 'models.dart';

Future<FlutterGrabActionResult> writeCaptureFiles({
  required String jsonPath,
  required String jsonContents,
  required String textPath,
  required String textContents,
}) async {
  final String projectRoot = p.normalize(p.absolute(Directory.current.path));
  final String resolvedJsonPath = p.normalize(p.absolute(jsonPath));
  final String resolvedTextPath = p.normalize(p.absolute(textPath));

  bool isWithinProject(String targetPath) {
    return targetPath == projectRoot || p.isWithin(projectRoot, targetPath);
  }

  if (!isWithinProject(resolvedJsonPath) ||
      !isWithinProject(resolvedTextPath)) {
    return const FlutterGrabActionResult(
      success: false,
      message:
          'Export paths must stay inside the current project folder. '
          'Use a relative path such as .dart_tool/flutter_grab/latest_capture.json.',
    );
  }

  final File jsonFile = File(resolvedJsonPath);
  final File textFile = File(resolvedTextPath);

  await jsonFile.parent.create(recursive: true);
  await textFile.parent.create(recursive: true);

  await jsonFile.writeAsString(jsonContents);
  await textFile.writeAsString(textContents);

  return FlutterGrabActionResult(
    success: true,
    message: 'Exported capture files for Codex.',
    path: jsonFile.path,
  );
}
