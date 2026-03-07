import 'package:flutter/foundation.dart';

enum FlutterGrabScreenshotPolicy { off, automatic }

@immutable
class FlutterGrabConfig {
  const FlutterGrabConfig({
    this.enableFloatingLauncher = true,
    this.enableKeyboardShortcut = true,
    this.exportPath = '.dart_tool/flutter_grab/latest_capture.json',
    this.screenshotPolicy = FlutterGrabScreenshotPolicy.off,
    this.themeSignalDepth = 1,
    this.includeSemantics = true,
    this.includeRouteInfo = true,
  });

  final bool enableFloatingLauncher;
  final bool enableKeyboardShortcut;
  final String exportPath;
  final FlutterGrabScreenshotPolicy screenshotPolicy;
  final int themeSignalDepth;
  final bool includeSemantics;
  final bool includeRouteInfo;
}
