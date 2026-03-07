# flutter_grab_bridge

Optional local CLI bridge for `flutter_grab` exports.

Examples:

```bash
dart run flutter_grab_bridge doctor
dart run flutter_grab_bridge latest
dart run flutter_grab_bridge latest --json
dart run flutter_grab_bridge watch
```

The bridge reads captures from `.dart_tool/flutter_grab/latest_capture.*`.
