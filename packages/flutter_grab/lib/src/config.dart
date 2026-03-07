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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FlutterGrabConfig &&
            other.enableFloatingLauncher == enableFloatingLauncher &&
            other.enableKeyboardShortcut == enableKeyboardShortcut &&
            other.exportPath == exportPath &&
            other.screenshotPolicy == screenshotPolicy &&
            other.themeSignalDepth == themeSignalDepth &&
            other.includeSemantics == includeSemantics &&
            other.includeRouteInfo == includeRouteInfo;
  }

  @override
  int get hashCode => Object.hash(
    enableFloatingLauncher,
    enableKeyboardShortcut,
    exportPath,
    screenshotPolicy,
    themeSignalDepth,
    includeSemantics,
    includeRouteInfo,
  );
}
