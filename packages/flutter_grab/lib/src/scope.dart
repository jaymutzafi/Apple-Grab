import 'package:flutter/widgets.dart';

import 'controller.dart';

class FlutterGrabScope extends InheritedNotifier<FlutterGrabController> {
  const FlutterGrabScope({
    super.key,
    required FlutterGrabController controller,
    required super.child,
  }) : super(notifier: controller);

  static FlutterGrabController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FlutterGrabScope>()
        ?.notifier;
  }

  static FlutterGrabController of(BuildContext context) {
    final FlutterGrabController? controller = maybeOf(context);
    assert(
      controller != null,
      'FlutterGrabScope was not found in the widget tree.',
    );
    return controller!;
  }
}
