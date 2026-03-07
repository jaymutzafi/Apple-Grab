import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class FlutterGrabRect {
  const FlutterGrabRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  Map<String, Object> toJson() => <String, Object>{
    'left': left,
    'top': top,
    'width': width,
    'height': height,
  };

  String toDisplayString() =>
      'x=${left.toStringAsFixed(1)}, y=${top.toStringAsFixed(1)}, '
      'w=${width.toStringAsFixed(1)}, h=${height.toStringAsFixed(1)}';
}

@immutable
class FlutterGrabAppInfo {
  const FlutterGrabAppInfo({
    required this.name,
    required this.platform,
    required this.debugMode,
  });

  final String name;
  final String platform;
  final bool debugMode;

  Map<String, Object> toJson() => <String, Object>{
    'name': name,
    'platform': platform,
    'debugMode': debugMode,
  };
}

@immutable
class FlutterGrabRouteInfo {
  const FlutterGrabRouteInfo({
    required this.name,
    required this.runtimeTypeName,
    this.isCurrent,
    this.isActive,
  });

  final String? name;
  final String runtimeTypeName;
  final bool? isCurrent;
  final bool? isActive;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'runtimeType': runtimeTypeName,
    'isCurrent': isCurrent,
    'isActive': isActive,
  };
}

@immutable
class FlutterGrabNodeSummary {
  const FlutterGrabNodeSummary({
    required this.widgetType,
    required this.widgetLabel,
    this.key,
    this.tagName,
  });

  final String widgetType;
  final String widgetLabel;
  final String? key;
  final String? tagName;

  Map<String, Object?> toJson() => <String, Object?>{
    'widgetType': widgetType,
    'widgetLabel': widgetLabel,
    'key': key,
    'tagName': tagName,
  };
}

@immutable
class FlutterGrabSelection {
  const FlutterGrabSelection({
    required this.widgetType,
    required this.widgetLabel,
    required this.localRect,
    required this.globalRect,
    this.key,
    this.debugLabel,
    this.text = const <String>[],
  });

  final String widgetType;
  final String widgetLabel;
  final String? key;
  final String? debugLabel;
  final FlutterGrabRect localRect;
  final FlutterGrabRect globalRect;
  final List<String> text;

  Map<String, Object?> toJson() => <String, Object?>{
    'widgetType': widgetType,
    'widgetLabel': widgetLabel,
    'key': key,
    'debugLabel': debugLabel,
    'localRect': localRect.toJson(),
    'globalRect': globalRect.toJson(),
    'text': text,
  };
}

@immutable
class FlutterGrabThemeSignals {
  const FlutterGrabThemeSignals({
    required this.brightness,
    required this.directionality,
    required this.primaryColor,
    required this.surfaceColor,
    required this.secondaryColor,
    required this.iconSize,
    required this.bodyFontSize,
    required this.titleFontSize,
  });

  final String brightness;
  final String directionality;
  final String primaryColor;
  final String surfaceColor;
  final String secondaryColor;
  final double? iconSize;
  final double? bodyFontSize;
  final double? titleFontSize;

  Map<String, Object?> toJson() => <String, Object?>{
    'brightness': brightness,
    'directionality': directionality,
    'primaryColor': primaryColor,
    'surfaceColor': surfaceColor,
    'secondaryColor': secondaryColor,
    'iconSize': iconSize,
    'bodyFontSize': bodyFontSize,
    'titleFontSize': titleFontSize,
  };
}

@immutable
class FlutterGrabSemanticsSummary {
  const FlutterGrabSemanticsSummary({
    this.labels = const <String>[],
    this.hints = const <String>[],
    this.values = const <String>[],
    this.flags = const <String>[],
  });

  final List<String> labels;
  final List<String> hints;
  final List<String> values;
  final List<String> flags;

  Map<String, Object> toJson() => <String, Object>{
    'labels': labels,
    'hints': hints,
    'values': values,
    'flags': flags,
  };
}

@immutable
class FlutterGrabTagRecord {
  const FlutterGrabTagRecord({
    required this.name,
    this.description,
    this.tags = const <String>[],
    this.notes,
    this.data = const <String, Object?>{},
  });

  final String name;
  final String? description;
  final List<String> tags;
  final String? notes;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'description': description,
    'tags': tags,
    'notes': notes,
    'data': data,
  };
}

@immutable
class FlutterGrabSourceHints {
  const FlutterGrabSourceHints({
    required this.creationTracked,
    required this.localCreationTracked,
    this.creatorDescription,
  });

  final bool creationTracked;
  final bool localCreationTracked;
  final String? creatorDescription;

  Map<String, Object?> toJson() => <String, Object?>{
    'creationTracked': creationTracked,
    'localCreationTracked': localCreationTracked,
    'creatorDescription': creatorDescription,
  };
}

@immutable
class FlutterGrabArtifacts {
  const FlutterGrabArtifacts({
    required this.jsonPath,
    required this.textPath,
    required this.screenshotSupported,
    this.screenshotPath,
  });

  final String jsonPath;
  final String textPath;
  final bool screenshotSupported;
  final String? screenshotPath;

  Map<String, Object?> toJson() => <String, Object?>{
    'jsonPath': jsonPath,
    'textPath': textPath,
    'screenshot': <String, Object?>{
      'supported': screenshotSupported,
      'path': screenshotPath,
    },
  };
}

@immutable
class FlutterGrabCapture {
  const FlutterGrabCapture({
    this.schemaVersion = 1,
    required this.capturedAt,
    required this.app,
    required this.route,
    required this.selection,
    required this.ancestors,
    required this.theme,
    required this.semantics,
    required this.tags,
    required this.sourceHints,
    required this.artifacts,
    required this.codexPrompt,
  });

  final int schemaVersion;
  final DateTime capturedAt;
  final FlutterGrabAppInfo app;
  final FlutterGrabRouteInfo route;
  final FlutterGrabSelection selection;
  final List<FlutterGrabNodeSummary> ancestors;
  final FlutterGrabThemeSignals theme;
  final FlutterGrabSemanticsSummary semantics;
  final List<FlutterGrabTagRecord> tags;
  final FlutterGrabSourceHints sourceHints;
  final FlutterGrabArtifacts artifacts;
  final String codexPrompt;

  FlutterGrabCapture copyWith({String? codexPrompt}) {
    return FlutterGrabCapture(
      schemaVersion: schemaVersion,
      capturedAt: capturedAt,
      app: app,
      route: route,
      selection: selection,
      ancestors: ancestors,
      theme: theme,
      semantics: semantics,
      tags: tags,
      sourceHints: sourceHints,
      artifacts: artifacts,
      codexPrompt: codexPrompt ?? this.codexPrompt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'app': app.toJson(),
    'route': route.toJson(),
    'selection': selection.toJson(),
    'ancestors': ancestors.map((node) => node.toJson()).toList(),
    'theme': theme.toJson(),
    'semantics': semantics.toJson(),
    'tags': tags.map((tag) => tag.toJson()).toList(),
    'sourceHints': sourceHints.toJson(),
    'artifacts': artifacts.toJson(),
    'codexPrompt': codexPrompt,
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

@immutable
class FlutterGrabActionResult {
  const FlutterGrabActionResult({
    required this.success,
    required this.message,
    this.path,
  });

  final bool success;
  final String message;
  final String? path;
}
