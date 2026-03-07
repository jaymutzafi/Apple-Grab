import 'models.dart';

Future<FlutterGrabActionResult> writeCaptureFiles({
  required String jsonPath,
  required String jsonContents,
  required String textPath,
  required String textContents,
}) async {
  return const FlutterGrabActionResult(
    success: false,
    message:
        'Local export is unavailable on this platform. Use Copy for Codex instead.',
  );
}
