# flutter_grab v1 implementation plan

## Goal

Ship a usable first version of `flutter_grab` that works in Flutter debug mode, captures structured UI context from the widget/render tree, and supports a clipboard-first Codex workflow with optional local file export.

## Repository shape

- `packages/flutter_grab`: core debug-only runtime package
- `packages/flutter_grab_bridge`: optional Dart CLI for local handoff
- `examples/flutter_grab_demo`: realistic demo app optimized for desktop/web pointer UX

## Vertical slice order

1. Workspace wiring and docs
2. Core capture models, controller, tagging, export formatting
3. Debug overlay with inspect/select flow
4. Demo app integration
5. Optional bridge CLI
6. Tests, samples, and troubleshooting docs

## Key v1 decisions

- No DOM-based inspection
- No promise of exact `file:line` source attribution
- Debug-only behavior, inert in release
- Clipboard is first-class
- JSON export is predictable on IO-capable platforms
- MCP is future work, not a v1 dependency

## Acceptance targets

- New user setup in under 10 minutes
- Hover/select flow works in desktop/web debug mode
- Tap/select fallback works on mobile debug builds
- `Copy for Codex` produces useful agent-facing text
- Export writes stable JSON for local automation on supported platforms
