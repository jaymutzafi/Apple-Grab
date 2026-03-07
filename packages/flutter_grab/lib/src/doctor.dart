import 'package:flutter/material.dart';

import 'controller.dart';
import 'scope.dart';

class FlutterGrabDoctorCard extends StatelessWidget {
  const FlutterGrabDoctorCard({super.key, this.controller});

  final FlutterGrabController? controller;

  @override
  Widget build(BuildContext context) {
    final FlutterGrabController? resolvedController =
        controller ?? FlutterGrabScope.maybeOf(context);
    final bool overlayMounted = resolvedController != null;
    final bool enabled = resolvedController?.enabled ?? false;
    final bool inspectMode = resolvedController?.inspectMode ?? false;
    final bool hasCapture = resolvedController?.latestCapture != null;

    return Card(
      color: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFFF8FAFC)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Flutter Grab doctor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              _DoctorRow(
                label: 'Overlay mounted',
                value: overlayMounted ? 'yes' : 'no',
              ),
              _DoctorRow(
                label: 'Controller enabled',
                value: enabled ? 'yes' : 'no',
              ),
              _DoctorRow(
                label: 'Inspect mode',
                value: inspectMode ? 'on' : 'off',
              ),
              _DoctorRow(
                label: 'Latest capture',
                value: hasCapture ? 'available' : 'none yet',
              ),
              const SizedBox(height: 12),
              const Text(
                'If this card says the overlay is mounted, FlutterGrab.wrap(...) is active for this app.',
                style: TextStyle(color: Color(0xFFCBD5E1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  const _DoctorRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF93C5FD)),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
