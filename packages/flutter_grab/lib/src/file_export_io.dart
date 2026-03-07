import 'dart:io';

import 'package:path/path.dart' as p;

import 'models.dart';

Future<FlutterGrabActionResult> writeCaptureFiles({
  required String jsonPath,
  required String jsonContents,
  required String textPath,
  required String textContents,
}) async {
  final File jsonFile = File(p.normalize(p.absolute(jsonPath)));
  final File textFile = File(p.normalize(p.absolute(textPath)));

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
