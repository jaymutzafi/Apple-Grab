# flutter_grab architecture

## Runtime model

`flutter_grab` wraps the app in a debug-only host widget that layers three things around the app subtree:

- a floating launcher
- a selection overlay
- a context panel

The package uses Flutter render tree hit-testing and widget ancestry, not browser DOM inspection. The selected render object is mapped back to an `Element` through `debugCreator` when available.

## Core flow

1. The user enables inspect mode.
2. Pointer hover or tap is resolved against the user subtree render objects.
3. The top matching render object is converted into a structured capture.
4. The panel shows the capture and offers copy/export actions.
5. The controller can copy the prompt text or export stable JSON and text files.

## Capture schema

The v1 `FlutterGrabCapture` payload includes:

- `schemaVersion`
- `capturedAt`
- `app`
- `route`
- `selection`
- `ancestors`
- `theme`
- `semantics`
- `tags`
- `sourceHints`
- `artifacts`
- `codexPrompt`

The schema is JSON-serializable and intended to stay stable enough for local tooling.

## Attribution strategy

v1 does not promise exact `file:line` mapping.

Instead it uses:

- runtime widget type and labels
- keys where available
- route context
- explicit `FlutterGrabTag` annotations
- widget creation tracking hints when Flutter exposes them

This keeps setup light while leaving room for richer attribution later.

## Export and bridge model

The primary flow is clipboard-first.

On IO-capable debug runs, the package can also export:

- `.dart_tool/flutter_grab/latest_capture.json`
- `.dart_tool/flutter_grab/latest_capture.txt`

The optional `flutter_grab_bridge` package is a small Dart CLI that reads or watches those files. It is intentionally not a required background process.

## Release behavior

- Outside debug mode, `FlutterGrab.wrap` returns the child unchanged.
- The overlay and deep inspection logic do not activate in release.
- This keeps production builds unaffected.

## Roadmap

- Improve source hints when Flutter exposes more creator metadata safely
- Add a more reliable screenshot pipeline where practical
- Add richer semantics extraction
- Add optional MCP integration on top of the predictable export path
- Add more polished mobile-first inspect UX
