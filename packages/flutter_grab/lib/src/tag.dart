import 'package:flutter/widgets.dart';

import 'models.dart';

class FlutterGrabTag extends StatelessWidget {
  const FlutterGrabTag({
    super.key,
    required this.child,
    required this.name,
    this.description,
    this.tags = const <String>[],
    this.notes,
    this.data = const <String, Object?>{},
  });

  final Widget child;
  final String name;
  final String? description;
  final List<String> tags;
  final String? notes;
  final Map<String, Object?> data;

  FlutterGrabTagRecord toRecord() => FlutterGrabTagRecord(
    name: name,
    description: description,
    tags: tags,
    notes: notes,
    data: data,
  );

  @override
  Widget build(BuildContext context) => child;
}
