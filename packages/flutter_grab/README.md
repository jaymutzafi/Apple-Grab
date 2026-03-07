# flutter_grab

Core debug-only runtime package for `flutter_grab`.

## Install

```yaml
dependencies:
  flutter_grab: any
```

## Use

```dart
import 'package:flutter_grab/flutter_grab.dart';

void main() {
  runApp(
    FlutterGrab.wrap(
      child: const MyApp(),
    ),
  );
}
```

Optional tagging:

```dart
FlutterGrabTag(
  name: 'hero-card',
  description: 'Primary dashboard card',
  child: HeroCard(),
)
```

The package is inert outside debug mode.
