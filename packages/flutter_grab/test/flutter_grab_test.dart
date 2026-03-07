import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grab/flutter_grab.dart';

void main() {
  testWidgets('shows the launcher and toggles inspect mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      FlutterGrab.wrap(
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('Hello from flutter_grab'))),
        ),
      ),
    );

    expect(find.byKey(const Key('flutter_grab_launcher')), findsOneWidget);

    final FlutterGrabController controller = FlutterGrabScope.of(
      tester.element(find.byType(Scaffold)),
    );
    expect(controller.inspectMode, isFalse);

    await tester.tap(find.byKey(const Key('flutter_grab_launcher')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.inspectMode, isTrue);
  });

  test('copies and exports a prepared capture', () async {
    final Directory tempDirectory = await Directory.systemTemp.createTemp(
      'flutter_grab_test.',
    );
    final String exportPath =
        '${tempDirectory.path}${Platform.pathSeparator}latest_capture.json';

    final FlutterGrabController controller = FlutterGrabController()
      ..configure(FlutterGrabConfig(exportPath: exportPath), enabled: true)
      ..updateCapture(_sampleCapture(exportPath));

    final FlutterGrabActionResult copyResult = await controller.copyForCodex();
    final FlutterGrabActionResult exportResult = await controller
        .exportLatest();

    expect(copyResult.success, isTrue);
    expect(exportResult.success, isTrue);
    expect(File(exportPath).existsSync(), isTrue);
    expect(File(exportPath.replaceAll('.json', '.txt')).existsSync(), isTrue);
  });
}

FlutterGrabCapture _sampleCapture(String exportPath) {
  return FlutterGrabCapture(
    capturedAt: DateTime.utc(2026, 3, 6),
    app: const FlutterGrabAppInfo(
      name: 'demo',
      platform: 'macos',
      debugMode: true,
    ),
    route: const FlutterGrabRouteInfo(
      name: '/demo',
      runtimeTypeName: 'MaterialPageRoute',
      isCurrent: true,
      isActive: true,
    ),
    selection: const FlutterGrabSelection(
      widgetType: 'RichText',
      widgetLabel: 'Text',
      key: '[demo]',
      debugLabel: 'Text',
      localRect: FlutterGrabRect(left: 0, top: 0, width: 120, height: 20),
      globalRect: FlutterGrabRect(left: 12, top: 24, width: 120, height: 20),
      text: <String>['Hello from flutter_grab'],
    ),
    ancestors: const <FlutterGrabNodeSummary>[
      FlutterGrabNodeSummary(widgetType: 'Scaffold', widgetLabel: 'Scaffold'),
    ],
    theme: const FlutterGrabThemeSignals(
      brightness: 'light',
      directionality: 'ltr',
      primaryColor: '#FF2563EB',
      surfaceColor: '#FFFFFFFF',
      secondaryColor: '#FF0F766E',
      iconSize: 24,
      bodyFontSize: 14,
      titleFontSize: 18,
    ),
    semantics: const FlutterGrabSemanticsSummary(
      labels: <String>['Hello from flutter_grab'],
    ),
    tags: const <FlutterGrabTagRecord>[
      FlutterGrabTagRecord(name: 'sample-tag'),
    ],
    sourceHints: const FlutterGrabSourceHints(
      creationTracked: false,
      localCreationTracked: false,
      creatorDescription: 'Text',
    ),
    artifacts: FlutterGrabArtifacts(
      jsonPath: exportPath,
      textPath: exportPath.replaceAll('.json', '.txt'),
      screenshotSupported: false,
      screenshotPath: null,
    ),
    codexPrompt: 'Flutter Grab Capture\nSelected widget: RichText',
  );
}
