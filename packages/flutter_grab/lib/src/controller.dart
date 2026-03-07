import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'config.dart';
import 'file_export_stub.dart' if (dart.library.io) 'file_export_io.dart';
import 'models.dart';

class FlutterGrabController extends ChangeNotifier {
  FlutterGrabController();

  FlutterGrabConfig _config = const FlutterGrabConfig();
  FlutterGrabCapture? _latestCapture;
  bool _inspectMode = false;
  bool _enabled = false;
  String? _lastMessage;

  bool get enabled => _enabled;
  bool get inspectMode => _inspectMode;
  FlutterGrabCapture? get latestCapture => _latestCapture;
  String? get lastMessage => _lastMessage;

  void configure(FlutterGrabConfig config, {required bool enabled}) {
    _config = config;
    _enabled = enabled;
  }

  void setInspectMode(bool value) {
    if (!_enabled || _inspectMode == value) {
      return;
    }
    _inspectMode = value;
    notifyListeners();
  }

  void toggleInspectMode() => setInspectMode(!_inspectMode);

  void updateCapture(FlutterGrabCapture capture) {
    _latestCapture = capture;
    _lastMessage = 'Captured ${capture.selection.widgetType}.';
    notifyListeners();
  }

  void clearCapture() {
    _latestCapture = null;
    notifyListeners();
  }

  void setMessage(String? message) {
    _lastMessage = message;
    notifyListeners();
  }

  Future<FlutterGrabActionResult> copyForCodex() async {
    final FlutterGrabCapture? capture = _latestCapture;
    if (capture == null) {
      const FlutterGrabActionResult result = FlutterGrabActionResult(
        success: false,
        message: 'Select a widget before copying context.',
      );
      _lastMessage = result.message;
      notifyListeners();
      return result;
    }

    await Clipboard.setData(ClipboardData(text: capture.codexPrompt));
    const FlutterGrabActionResult result = FlutterGrabActionResult(
      success: true,
      message: 'Copied a Codex-ready context block to the clipboard.',
    );
    _lastMessage = result.message;
    notifyListeners();
    return result;
  }

  Future<FlutterGrabActionResult> exportLatest() async {
    final FlutterGrabCapture? capture = _latestCapture;
    if (capture == null) {
      const FlutterGrabActionResult result = FlutterGrabActionResult(
        success: false,
        message: 'Select a widget before exporting a capture.',
      );
      _lastMessage = result.message;
      notifyListeners();
      return result;
    }

    final String jsonPath = _config.exportPath;
    final String textPath = _textPathForJsonPath(jsonPath);
    final FlutterGrabActionResult result = await writeCaptureFiles(
      jsonPath: jsonPath,
      jsonContents: capture.toPrettyJson(),
      textPath: textPath,
      textContents: capture.codexPrompt,
    );
    _lastMessage = result.message;
    notifyListeners();
    return result;
  }

  String _textPathForJsonPath(String jsonPath) {
    final String extension = p.extension(jsonPath);
    if (extension.toLowerCase() == '.json') {
      return p.setExtension(jsonPath, '.txt');
    }
    return '$jsonPath.txt';
  }
}
