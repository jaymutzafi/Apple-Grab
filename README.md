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
- `packages/apple_grab_sdk`: a native AppKit/UIKit Swift Package for macOS and iOS apps you build yourself

## Native Apple SDK

This repo now also includes a native Swift Package:

- [AppleGrab README](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/packages/apple_grab_sdk/README.md)
- [Codex install workflow](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/codex_install_workflow.md)

Use it for:

- AppKit macOS apps
- UIKit iOS apps
- Codex-built Apple apps where you want the same kind of debug-only inspect/copy/export flow

The package provides:

- a debug boot log
- an obvious active banner
- a built-in doctor panel
- inspect/select mode
- clipboard-first Codex export
- optional JSON export when you provide an export URL

Most important change:

- the **repo root is now a valid Swift Package for `AppleGrab`**

That means for macOS/iOS apps you can give Codex any of these:

- `https://github.com/jaymutzafi/Flutter-Grab.git`
- a zip of this repo
- the local folder path to this repo

and Codex can add `AppleGrab` directly as a Swift Package dependency without needing a separate repo just for the Apple SDK.

## Cross-project Codex install

If you want Codex to install this into another project from a GitHub URL, zip file, or folder path, use the workflow in:

- [docs/codex_install_workflow.md](/Users/jaymutzafi/Library/Mobile%20Documents/com~apple~CloudDocs/Projects/Flutter%20Grab/docs/codex_install_workflow.md)

The short version is:

- give Codex a source
- let Codex try direct package installation first
- if that is not appropriate, have Codex vendor it into the current project
- have Codex wire it into the app automatically

That avoids pub.dev assumptions, cross-project path visibility issues, and fragile external references.

## Quickstart

1. Add the package to your Flutter app.
2. Wrap your app root with `FlutterGrab.wrap(...)`.
3. Run the app in debug mode.
4. Confirm the yellow `Flutter Grab active` banner appears.
5. Open the built-in doctor panel if you want to verify the overlay is mounted.
6. Click the floating `Flutter Grab` launcher or press `Cmd/Ctrl+Shift+G`.
7. Hover and click a widget to capture it.
8. Use `Copy for Codex` or `Export JSON`.

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

- Look for the yellow `Flutter Grab active` banner after boot. That is the most obvious signal that the wrapper is active.
- Open the doctor panel from the banner, or route to a doctor screen in your app, to confirm the overlay is mounted.
- Toggle inspect mode with the floating launcher or `Cmd/Ctrl+Shift+G`.
- In inspect mode, hover to preview the target widget on desktop/web.
- Click to capture the widget and open the context panel.
- Use `Copy for Codex` to copy the agent-friendly text block.
- Use `Export JSON` to write the latest capture to `.dart_tool/flutter_grab/latest_capture.json` on supported IO platforms.

For interactive web debugging, prefer:

```bash
flutter run -d chrome
```

and avoid `-d web-server` when you want hover, clipboard, and the most natural browser-based debugging loop.

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
- Web debugging feels limited:
  - Prefer `flutter run -d chrome` over `flutter run -d web-server` for interactive debugging.
  - `-d web-server` is fine for basic verification, but it is not the best choice for this tool’s browser-style workflow.
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
