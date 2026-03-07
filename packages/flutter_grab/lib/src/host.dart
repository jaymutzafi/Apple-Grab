import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets show WidgetsApp;

import 'config.dart';
import 'controller.dart';
import 'models.dart';
import 'paths.dart';
import 'scope.dart';
import 'tag.dart';

const double _edgeHitMargin = 2.0;
const int _maxAncestorCount = 50;

class FlutterGrab {
  static Widget wrap({required Widget child, FlutterGrabConfig? config}) {
    if (!kDebugMode) {
      return child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: _FlutterGrabHost(
        config: config ?? const FlutterGrabConfig(),
        child: child,
      ),
    );
  }
}

class _FlutterGrabHost extends StatefulWidget {
  const _FlutterGrabHost({required this.child, required this.config});

  final Widget child;
  final FlutterGrabConfig config;

  @override
  State<_FlutterGrabHost> createState() => _FlutterGrabHostState();
}

class _FlutterGrabHostState extends State<_FlutterGrabHost> {
  final FlutterGrabController _controller = FlutterGrabController();
  final GlobalKey _contentKey = GlobalKey(debugLabel: 'flutter_grab_content');
  final GlobalKey _overlayKey = GlobalKey(debugLabel: 'flutter_grab_overlay');

  List<RenderObject> _hoveredCandidates = const <RenderObject>[];
  RenderObject? _selectedRenderObject;

  @override
  void initState() {
    super.initState();
    _controller.configure(widget.config, enabled: true);
  }

  @override
  void didUpdateWidget(covariant _FlutterGrabHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _controller.configure(widget.config, enabled: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FlutterGrabScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.topLeft,
            children: <Widget>[
              RepaintBoundary(
                key: _contentKey,
                child: IgnorePointer(
                  ignoring: _controller.inspectMode,
                  child: widget.child,
                ),
              ),
              if (_controller.inspectMode) _buildSelectionOverlay(),
              if (widget.config.enableFloatingLauncher)
                _buildFloatingLauncher(),
              if (_controller.latestCapture
                  case final FlutterGrabCapture capture)
                _buildCapturePanel(capture),
            ],
          );
        },
      ),
    );

    if (widget.config.enableKeyboardShortcut) {
      child = Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          SingleActivator(
            LogicalKeyboardKey.keyG,
            control: defaultTargetPlatform != TargetPlatform.macOS,
            meta: defaultTargetPlatform == TargetPlatform.macOS,
            shift: true,
          ): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (Intent intent) {
                _controller.toggleInspectMode();
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: child),
        ),
      );
    }

    return child;
  }

  Widget _buildFloatingLauncher() {
    final bool inspectMode = _controller.inspectMode;
    return Positioned(
      right: 20,
      bottom: 20,
      child: Material(
        elevation: 8,
        color: inspectMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: const Key('flutter_grab_launcher'),
          borderRadius: BorderRadius.circular(16),
          onTap: _controller.toggleInspectMode,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  inspectMode ? Icons.ads_click : Icons.search,
                  color: inspectMode ? Colors.white : const Color(0xFF0F172A),
                ),
                const SizedBox(width: 10),
                Text(
                  inspectMode ? 'Inspecting' : 'Flutter Grab',
                  style: TextStyle(
                    color: inspectMode ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Positioned.fill(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (PointerHoverEvent event) => _updateHover(event.position),
        child: GestureDetector(
          key: _overlayKey,
          behavior: HitTestBehavior.opaque,
          onTapDown: (TapDownDetails details) =>
              _selectAt(details.globalPosition),
          child: CustomPaint(
            painter: _FlutterGrabOverlayPainter(
              overlayKey: _overlayKey,
              hovered: _hoveredCandidates,
              selected: _selectedRenderObject,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _buildCapturePanel(FlutterGrabCapture capture) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool wide = screenSize.width >= 980;

    final Widget panel = Material(
      elevation: 14,
      color: const Color(0xFF0F172A),
      borderRadius: wide
          ? const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            )
          : const BorderRadius.vertical(top: Radius.circular(24)),
      child: DefaultTextStyle(
        style: const TextStyle(color: Color(0xFFF8FAFC)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      capture.selection.widgetType,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      _controller.clearCapture();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Route: ${capture.route.name ?? capture.route.runtimeTypeName}',
                style: const TextStyle(color: Color(0xFFCBD5E1)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _ActionChip(
                    icon: Icons.copy_all_rounded,
                    label: 'Copy for Codex',
                    onPressed: () {
                      unawaited(_runAction(_controller.copyForCodex));
                    },
                  ),
                  _ActionChip(
                    icon: Icons.save_alt_rounded,
                    label: 'Export JSON',
                    onPressed: () {
                      unawaited(_runAction(_controller.exportLatest));
                    },
                  ),
                  _ActionChip(
                    icon: _controller.inspectMode
                        ? Icons.visibility_off
                        : Icons.visibility,
                    label: _controller.inspectMode
                        ? 'Exit inspect'
                        : 'Inspect mode',
                    onPressed: () {
                      _controller.toggleInspectMode();
                    },
                  ),
                ],
              ),
              if (_controller.lastMessage
                  case final String message) ...<Widget>[
                const SizedBox(height: 12),
                Text(message, style: const TextStyle(color: Color(0xFF93C5FD))),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _Section(
                      title: 'Geometry',
                      body: capture.selection.globalRect.toDisplayString(),
                    ),
                    _Section(
                      title: 'Visible text',
                      body: capture.selection.text.isEmpty
                          ? 'No direct text found in the selected subtree.'
                          : capture.selection.text.join('\n'),
                    ),
                    _Section(
                      title: 'Theme signals',
                      body:
                          'Brightness: ${capture.theme.brightness}\n'
                          'Directionality: ${capture.theme.directionality}\n'
                          'Primary: ${capture.theme.primaryColor}\n'
                          'Surface: ${capture.theme.surfaceColor}\n'
                          'Secondary: ${capture.theme.secondaryColor}',
                    ),
                    _Section(
                      title: 'Ancestor chain',
                      body: capture.ancestors.isEmpty
                          ? 'No ancestors were recorded.'
                          : capture.ancestors
                                .map(
                                  (FlutterGrabNodeSummary node) =>
                                      '- ${node.widgetType}'
                                      '${node.tagName != null ? ' [tag:${node.tagName}]' : ''}',
                                )
                                .join('\n'),
                    ),
                    _Section(
                      title: 'Tags',
                      body: capture.tags.isEmpty
                          ? 'No explicit FlutterGrabTag metadata found.'
                          : capture.tags
                                .map(
                                  (FlutterGrabTagRecord tag) => '- ${tag.name}',
                                )
                                .join('\n'),
                    ),
                    _Section(
                      title: 'Semantics',
                      body:
                          <String>[
                                if (capture.semantics.labels.isNotEmpty)
                                  'Labels: ${capture.semantics.labels.join(', ')}',
                                if (capture.semantics.hints.isNotEmpty)
                                  'Hints: ${capture.semantics.hints.join(', ')}',
                                if (capture.semantics.values.isNotEmpty)
                                  'Values: ${capture.semantics.values.join(', ')}',
                                if (capture.semantics.flags.isNotEmpty)
                                  'Flags: ${capture.semantics.flags.join(', ')}',
                              ]
                              .join('\n')
                              .ifEmpty(
                                'No explicit semantics metadata found in the selected subtree.',
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (wide) {
      return Positioned(top: 0, right: 0, bottom: 0, width: 380, child: panel);
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: math.min(420, screenSize.height * 0.52),
      child: panel,
    );
  }

  void _updateHover(Offset globalPosition) {
    final RenderObject? root = _userRootRenderObject;
    if (root == null) {
      return;
    }

    final List<RenderObject> matches = _hitTest(
      globalPosition,
      root,
    ).where((RenderObject object) => _elementFor(object) != null).toList();
    if (!listEquals(matches, _hoveredCandidates)) {
      setState(() {
        _hoveredCandidates = matches;
      });
    }
  }

  void _selectAt(Offset globalPosition) {
    final RenderObject? root = _userRootRenderObject;
    if (root == null) {
      return;
    }

    final List<RenderObject> matches = _hitTest(
      globalPosition,
      root,
    ).where((RenderObject object) => _elementFor(object) != null).toList();
    if (matches.isEmpty) {
      _controller.setMessage('No widget was found under the pointer.');
      return;
    }

    final RenderObject selected = matches.first;
    final FlutterGrabCapture? capture = _buildCaptureFor(selected);
    if (capture == null) {
      _controller.setMessage(
        'Could not capture widget details for this selection.',
      );
      return;
    }

    setState(() {
      _hoveredCandidates = matches;
      _selectedRenderObject = selected;
    });
    _controller.updateCapture(capture);
  }

  FlutterGrabCapture? _buildCaptureFor(RenderObject renderObject) {
    final Element? element = _elementFor(renderObject);
    if (element == null || !renderObject.attached) {
      return null;
    }

    final FlutterGrabRect localRect = _rectFromRect(
      renderObject.semanticBounds,
    );
    final Rect globalBounds = MatrixUtils.transformRect(
      renderObject.getTransformTo(null),
      renderObject.semanticBounds,
    );
    final FlutterGrabRect globalRect = _rectFromRect(globalBounds);

    final List<Element> ancestry = <Element>[];
    element.visitAncestorElements((Element ancestor) {
      if (ancestry.length >= _maxAncestorCount) {
        return false;
      }
      ancestry.add(ancestor);
      return true;
    });
    final List<Element> rootToParentAncestors = ancestry.reversed.toList();

    final List<FlutterGrabTagRecord> tags = rootToParentAncestors
        .map((Element ancestor) => ancestor.widget)
        .whereType<FlutterGrabTag>()
        .map((FlutterGrabTag tag) => tag.toRecord())
        .toList();

    final FlutterGrabSemanticsSummary semantics = widget.config.includeSemantics
        ? _collectSemantics(element)
        : const FlutterGrabSemanticsSummary();

    final FlutterGrabCapture draft = FlutterGrabCapture(
      capturedAt: DateTime.now().toUtc(),
      app: _collectAppInfo(element),
      route: widget.config.includeRouteInfo
          ? _collectRouteInfo(element)
          : const FlutterGrabRouteInfo(name: null, runtimeTypeName: 'unknown'),
      selection: FlutterGrabSelection(
        widgetType: element.widget.runtimeType.toString(),
        widgetLabel: element.widget.toStringShort(),
        key: element.widget.key?.toString(),
        debugLabel: element.toStringShort(),
        localRect: localRect,
        globalRect: globalRect,
        text: _collectText(element),
      ),
      ancestors: rootToParentAncestors
          .map(
            (Element ancestor) => FlutterGrabNodeSummary(
              widgetType: ancestor.widget.runtimeType.toString(),
              widgetLabel: ancestor.widget.toStringShort(),
              key: ancestor.widget.key?.toString(),
              tagName: ancestor.widget is FlutterGrabTag
                  ? (ancestor.widget as FlutterGrabTag).name
                  : null,
            ),
          )
          .toList(),
      theme: _collectThemeSignals(element),
      semantics: semantics,
      tags: tags,
      sourceHints: FlutterGrabSourceHints(
        creationTracked: WidgetInspectorService.instance
            .isWidgetCreationTracked(),
        localCreationTracked: debugIsLocalCreationLocation(element.widget),
        creatorDescription: element.toStringShort(),
      ),
      artifacts: FlutterGrabArtifacts(
        jsonPath: widget.config.exportPath,
        textPath: flutterGrabTextPathForJsonPath(widget.config.exportPath),
        screenshotSupported:
            widget.config.screenshotPolicy ==
            FlutterGrabScreenshotPolicy.automatic,
        screenshotPath: null,
      ),
      codexPrompt: '',
    );

    return draft.copyWith(codexPrompt: _buildCodexPrompt(draft));
  }

  FlutterGrabAppInfo _collectAppInfo(Element element) {
    String appName = element.widget.runtimeType.toString();
    for (final Element ancestor in element.debugGetDiagnosticChain().reversed) {
      final Widget widget = ancestor.widget;
      if (widget is MaterialApp && (widget.title?.isNotEmpty ?? false)) {
        appName = widget.title!;
        break;
      }
      if (widget is widgets.WidgetsApp && (widget.title?.isNotEmpty ?? false)) {
        appName = widget.title!;
        break;
      }
    }

    return FlutterGrabAppInfo(
      name: appName,
      platform: defaultTargetPlatform.name,
      debugMode: kDebugMode,
    );
  }

  FlutterGrabRouteInfo _collectRouteInfo(Element element) {
    final ModalRoute<Object?>? route = ModalRoute.of(element);
    if (route == null) {
      return const FlutterGrabRouteInfo(name: null, runtimeTypeName: 'unknown');
    }

    return FlutterGrabRouteInfo(
      name: route.settings.name,
      runtimeTypeName: route.runtimeType.toString(),
      isCurrent: route.isCurrent,
      isActive: route.isActive,
    );
  }

  FlutterGrabThemeSignals _collectThemeSignals(Element element) {
    final ThemeData theme = Theme.of(element);
    final IconThemeData iconTheme = IconTheme.of(element);
    final TextTheme textTheme = theme.textTheme;
    return FlutterGrabThemeSignals(
      brightness: theme.brightness.name,
      directionality: Directionality.of(element).name,
      primaryColor: _colorToHex(theme.colorScheme.primary),
      surfaceColor: _colorToHex(theme.colorScheme.surface),
      secondaryColor: _colorToHex(theme.colorScheme.secondary),
      iconSize: iconTheme.size,
      bodyFontSize: textTheme.bodyMedium?.fontSize,
      titleFontSize: textTheme.titleLarge?.fontSize,
    );
  }

  FlutterGrabSemanticsSummary _collectSemantics(Element element) {
    final Set<String> labels = <String>{};
    final Set<String> hints = <String>{};
    final Set<String> values = <String>{};
    final Set<String> flags = <String>{};

    void visit(Element current, int depth) {
      if (depth > 24) {
        return;
      }

      final Widget widget = current.widget;
      if (widget is Semantics) {
        if (widget.properties.label case final String label
            when label.trim().isNotEmpty) {
          labels.add(label.trim());
        }
        if (widget.properties.hint case final String hint
            when hint.trim().isNotEmpty) {
          hints.add(hint.trim());
        }
        if (widget.properties.value case final String value
            when value.trim().isNotEmpty) {
          values.add(value.trim());
        }
        if (widget.properties.button == true) {
          flags.add('button');
        }
        if (widget.properties.textField == true) {
          flags.add('textField');
        }
        if (widget.properties.enabled == false) {
          flags.add('disabled');
        }
      }

      current.visitChildren((Element child) => visit(child, depth + 1));
    }

    visit(element, 0);
    return FlutterGrabSemanticsSummary(
      labels: labels.toList(),
      hints: hints.toList(),
      values: values.toList(),
      flags: flags.toList(),
    );
  }

  List<String> _collectText(Element element) {
    final Set<String> values = <String>{};

    void addValue(String? value) {
      final String normalized = value?.trim() ?? '';
      if (normalized.isNotEmpty) {
        values.add(normalized);
      }
    }

    void visit(Element current, int depth) {
      if (depth > 32 || values.length >= 12) {
        return;
      }

      final Widget widget = current.widget;
      if (widget is Text) {
        addValue(widget.data ?? widget.textSpan?.toPlainText());
      } else if (widget is RichText) {
        addValue(widget.text.toPlainText());
      } else if (widget is SelectableText) {
        addValue(widget.data ?? widget.textSpan?.toPlainText());
      } else if (widget is EditableText) {
        addValue(widget.controller.text);
      } else if (widget is Tooltip) {
        addValue(widget.message);
      } else if (widget is Icon) {
        addValue(widget.semanticLabel);
      } else if (widget is Semantics) {
        addValue(widget.properties.label);
        addValue(widget.properties.value);
        addValue(widget.properties.hint);
      }

      current.visitChildren((Element child) => visit(child, depth + 1));
    }

    visit(element, 0);
    return values.toList();
  }

  RenderObject? get _userRootRenderObject {
    final BuildContext? contentContext = _contentKey.currentContext;
    return contentContext?.findRenderObject();
  }

  Element? _elementFor(RenderObject renderObject) {
    final Object? debugCreator = renderObject.debugCreator;
    if (debugCreator is! DebugCreator) {
      return null;
    }
    final DebugCreator creator = debugCreator;
    final Element element = creator.element;
    if (element.debugIsDefunct) {
      return null;
    }
    return element;
  }

  List<RenderObject> _hitTest(Offset position, RenderObject root) {
    final List<RenderObject> regularHits = <RenderObject>[];
    final List<RenderObject> edgeHits = <RenderObject>[];

    _hitTestHelper(
      regularHits,
      edgeHits,
      position,
      root,
      root.getTransformTo(null),
    );
    double area(RenderObject object) {
      final Size size = object.semanticBounds.size;
      return size.width * size.height;
    }

    regularHits.sort(
      (RenderObject a, RenderObject b) => area(a).compareTo(area(b)),
    );
    return <RenderObject>{...edgeHits, ...regularHits}.toList();
  }

  bool _hitTestHelper(
    List<RenderObject> hits,
    List<RenderObject> edgeHits,
    Offset position,
    RenderObject object,
    Matrix4 transform,
  ) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }

    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);
    final List<DiagnosticsNode> children = object.debugDescribeChildren();

    for (int index = children.length - 1; index >= 0; index -= 1) {
      final DiagnosticsNode diagnostics = children[index];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) {
        continue;
      }

      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) {
        continue;
      }

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, edgeHits, position, child, childTransform)) {
        hit = true;
      }
    }

    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      if (!bounds.deflate(_edgeHitMargin).contains(localPosition)) {
        edgeHits.add(object);
      }
    }

    if (hit) {
      hits.add(object);
    }
    return hit;
  }

  FlutterGrabRect _rectFromRect(Rect rect) {
    return FlutterGrabRect(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  String _buildCodexPrompt(FlutterGrabCapture capture) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Flutter Grab Capture')
      ..writeln('Project: ${capture.app.name}')
      ..writeln('Route: ${capture.route.name ?? capture.route.runtimeTypeName}')
      ..writeln()
      ..writeln('Selected widget')
      ..writeln('- Type: ${capture.selection.widgetType}')
      ..writeln('- Label: ${capture.selection.widgetLabel}');

    if (capture.selection.key case final String key?) {
      buffer.writeln('- Key: $key');
    }
    buffer.writeln(
      '- Bounds: ${capture.selection.globalRect.toDisplayString()}',
    );

    if (capture.selection.text.isNotEmpty) {
      buffer.writeln('- Text:');
      for (final String value in capture.selection.text) {
        buffer.writeln('  - $value');
      }
    }

    if (capture.tags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Explicit tags');
      for (final FlutterGrabTagRecord tag in capture.tags) {
        buffer.writeln('- ${tag.name}');
        if (tag.description case final String description?) {
          buffer.writeln('  Description: $description');
        }
      }
    }

    if (capture.ancestors.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Ancestor chain');
      for (final FlutterGrabNodeSummary node in capture.ancestors) {
        buffer.writeln(
          '- ${node.widgetType}${node.tagName != null ? ' [tag:${node.tagName}]' : ''}',
        );
      }
    }

    buffer
      ..writeln()
      ..writeln('Theme signals')
      ..writeln('- Brightness: ${capture.theme.brightness}')
      ..writeln('- Directionality: ${capture.theme.directionality}')
      ..writeln('- Primary color: ${capture.theme.primaryColor}')
      ..writeln('- Surface color: ${capture.theme.surfaceColor}')
      ..writeln('- Secondary color: ${capture.theme.secondaryColor}')
      ..writeln()
      ..writeln(
        'Use this context to reason about or implement a UI change. '
        'Preserve route structure, spacing rhythm, and the current visual hierarchy unless the task explicitly changes them.',
      );

    return buffer.toString().trimRight();
  }

  String _colorToHex(Color color) {
    int channel(double value) => (value * 255.0).round().clamp(0, 255);
    final String red = channel(color.r).toRadixString(16).padLeft(2, '0');
    final String green = channel(color.g).toRadixString(16).padLeft(2, '0');
    final String blue = channel(color.b).toRadixString(16).padLeft(2, '0');
    final String alpha = channel(color.a).toRadixString(16).padLeft(2, '0');

    final String hex = alpha == 'ff'
        ? '$red$green$blue'
        : '$red$green$blue$alpha';
    return '#${hex.toUpperCase()}';
  }

  Future<void> _runAction(
    Future<FlutterGrabActionResult> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'flutter_grab',
          context: ErrorDescription(
            'while running a flutter_grab panel action',
          ),
        ),
      );
      _controller.setMessage('The action failed unexpectedly.');
    }
  }
}

class _FlutterGrabOverlayPainter extends CustomPainter {
  const _FlutterGrabOverlayPainter({
    required this.overlayKey,
    required this.hovered,
    required this.selected,
  });

  final GlobalKey overlayKey;
  final List<RenderObject> hovered;
  final RenderObject? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? overlayBox =
        overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      return;
    }

    final Offset overlayOrigin = overlayBox.localToGlobal(Offset.zero);
    final Paint hoverFill = Paint()
      ..color = const Color(0x334F46E5)
      ..style = PaintingStyle.fill;
    final Paint hoverStroke = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Paint selectedStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final RenderObject object in hovered.take(3)) {
      if (!object.attached) {
        continue;
      }
      final Rect globalRect = MatrixUtils.transformRect(
        object.getTransformTo(null),
        object.semanticBounds,
      );
      final Rect localRect = globalRect.shift(-overlayOrigin);
      canvas.drawRect(localRect, hoverFill);
      canvas.drawRect(localRect, hoverStroke);
    }

    if (selected case final RenderObject current when current.attached) {
      final Rect globalRect = MatrixUtils.transformRect(
        current.getTransformTo(null),
        current.semanticBounds,
      );
      final Rect localRect = globalRect.shift(-overlayOrigin);
      canvas.drawRect(localRect, selectedStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FlutterGrabOverlayPainter oldDelegate) {
    return !listEquals(oldDelegate.hovered, hovered) ||
        oldDelegate.selected != selected;
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
