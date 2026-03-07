# flutter_grab

`flutter_grab` is a debug-only Flutter context capture tool built for Codex workflows. It inspects the running widget/render tree, lets you select a widget visually, and turns that selection into:

- a clean JSON payload
- a plain-text `Copy for Codex` block
- an optional predictable local export for tooling

It is built around Flutter runtime inspection, not browser DOM scraping, so the same architecture can support Flutter desktop, mobile, and web debug builds.

## What ships in v1

- `packages/flutter_grab`: the core package you add to a Flutter app
- `packages/flutter_grab_bridge`: an optional Dart CLI for reading or watching exported captures
- `examples/flutter_grab_demo`: a realistic demo app showing installation and daily use

## Quickstart

1. Add the package to your Flutter app.
2. Wrap your app root with `FlutterGrab.wrap(...)`.
3. Run the app in debug mode.
4. Click the floating `Flutter Grab` launcher or press `Cmd/Ctrl+Shift+G`.
5. Hover and click a widget to capture it.
6. Use `Copy for Codex` or `Export JSON`.

Minimal integration:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_grab/flutter_grab.dart';

void main() {
  runApp(
    FlutterGrab.wrap(
      child: const MyApp(),
    ),
  );
}
```

Optional tagging for better context:

```dart
FlutterGrabTag(
  name: 'hero-card',
  description: 'Primary value proposition card on the dashboard.',
  tags: const ['marketing', 'homepage'],
  child: HeroCard(),
)
```

## Installation

For this repo workspace:

```yaml
dependencies:
  flutter_grab: any
```

For a standalone app outside this workspace, the recommended setup after uploading this repo to GitHub is:

```yaml
dependencies:
  flutter_grab:
    git:
      url: https://github.com/YOUR_NAME/flutter_grab.git
      path: packages/flutter_grab
      ref: main
```

That avoids pub.dev and also avoids cross-project local path issues in Codex.

## Daily usage

- Toggle inspect mode with the floating launcher or `Cmd/Ctrl+Shift+G`.
- In inspect mode, hover to preview the target widget on desktop/web.
- Click to capture the widget and open the context panel.
- Use `Copy for Codex` to copy the agent-friendly text block.
- Use `Export JSON` to write the latest capture to `.dart_tool/flutter_grab/latest_capture.json` on supported IO platforms.

Captured v1 fields include:

- selected widget type and label
- ancestor chain
- geometry and bounds
- text content when it can be extracted from the selected subtree
- theme signals
- route information when available
- semantics metadata when present in the subtree
- explicit `FlutterGrabTag` metadata
- source hints about widget creation tracking when available

## Codex integration options

### Clipboard-first

This is the default and recommended flow.

- Select a widget.
- Click `Copy for Codex`.
- Paste directly into Codex.

This works even on Flutter Web where writing to a predictable local project file is not always practical.

### Predictable local export

On supported IO platforms, `Export JSON` writes:

- `.dart_tool/flutter_grab/latest_capture.json`
- `.dart_tool/flutter_grab/latest_capture.txt`

This is the simplest bridge for local tools or scripts.

### Optional bridge CLI

The bridge package is optional and does not need to run for the core package to work.

Examples:

```bash
dart pub get
dart run flutter_grab_bridge doctor
dart run flutter_grab_bridge latest
dart run flutter_grab_bridge latest --json
dart run flutter_grab_bridge watch
```

What those commands do:

- `doctor`: checks whether you are in a Flutter project and tells you where the capture files should appear
- `latest`: prints the newest Codex text block or JSON payload
- `watch`: keeps watching the export file and prints updates when a new capture is exported

## Troubleshooting

- The launcher is missing:
  - Make sure you are running a debug build.
  - `flutter_grab` is intentionally inert outside debug mode.
- Hover does not work:
  - Hover preview is mainly for desktop/web pointer input.
  - On touch devices, tap to select instead.
- Export JSON does not create a file:
  - The predictable local export is designed for IO-capable debug runs started from a local project directory.
  - On Flutter Web, use `Copy for Codex`.
- Source attribution is limited:
  - v1 does not promise exact `file:line`.
  - Add `FlutterGrabTag` around important regions to improve agent context.
- The bridge says no capture exists:
  - Select a widget first, then export a capture.

## Release safety

`flutter_grab` is designed for debug workflows only.

- `FlutterGrab.wrap` returns the child unchanged outside debug mode.
- The heavy inspection and overlay behavior does not run in release builds.
- The app remains usable without the bridge package.

## Repository guide

- [docs/implementation_plan.md](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/implementation_plan.md)
- [docs/architecture.md](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/architecture.md)
- [sample_capture.json](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/samples/sample_capture.json)
- [sample_copy_for_codex.txt](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/samples/sample_copy_for_codex.txt)
