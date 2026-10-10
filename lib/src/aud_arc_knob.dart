// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'aud_control.dart';
import 'aud_control_geometry.dart';
import 'aud_controls_theme.dart';

// #############################################################################
/// The arc knob of AudioKit Controls (decision ui-002): an arc from 135° to
/// 405° with the gap at the bottom, filled from [origin] to the value - 0
/// for a level, 0.5 for a bipolar value such as pan - with the value as
/// text in the middle.
class AudArcKnob extends StatelessWidget {
  /// Creates a knob.
  ///
  /// - [value] the value in 0 to 1
  /// - [text] the value as text in the middle, if any
  /// - [origin] where the filled arc starts, in 0 to 1
  /// - the callbacks and [geometry] as [AudControl] has them
  const AudArcKnob({
    super.key,
    required this.value,
    this.text,
    this.origin = 0,
    this.geometry = const AudVerticalDragGeometry(),
    this.onChanged,
    this.onStarted,
    this.onEnded,
  });

  /// The value in 0 to 1.
  final double value;

  /// The value as text in the middle.
  final String? text;

  /// Where the filled arc starts.
  final double origin;

  /// How pointer movement changes the value.
  final AudControlGeometry geometry;

  /// The new value during a gesture.
  final ValueChanged<double>? onChanged;

  /// A gesture starts.
  final VoidCallback? onStarted;

  /// A gesture ends.
  final VoidCallback? onEnded;

  @override
  Widget build(BuildContext context) {
    final theme = AudControlsTheme.of(context);
    return AudControl(
      value: value,
      geometry: geometry,
      onChanged: onChanged,
      onStarted: onStarted,
      onEnded: onEnded,
      builder: (context, value, active) => CustomPaint(
        painter: AudArcKnobPainter(
          value: value,
          origin: origin,
          trackColor: theme.trackColor,
          valueColor: theme.valueColor,
          strokeWidth: theme.strokeWidth,
        ),
        child: Center(
          child: text == null ? null : Text(text!, style: theme.valueStyle),
        ),
      ),
    );
  }
}

// #############################################################################
/// Paints the arcs of an [AudArcKnob].
class AudArcKnobPainter extends CustomPainter {
  /// Creates the painter.
  const AudArcKnobPainter({
    required this.value,
    required this.origin,
    required this.trackColor,
    required this.valueColor,
    required this.strokeWidth,
  });

  /// The value in 0 to 1.
  final double value;

  /// Where the filled arc starts.
  final double origin;

  /// The color of the track.
  final Color trackColor;

  /// The color of the value.
  final Color valueColor;

  /// The stroke.
  final double strokeWidth;

  /// Where the arc starts: 135°, bottom left.
  static const double startAngle = 0.75 * math.pi;

  /// How far the arc sweeps: 270°.
  static const double sweepAngle = 1.5 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      paint..color = trackColor,
    );
    final from = math.min(origin, value);
    final to = math.max(origin, value);
    canvas.drawArc(
      rect,
      startAngle + sweepAngle * from,
      math.max(sweepAngle * (to - from), 0.001),
      false,
      paint..color = valueColor,
    );
  }

  @override
  bool shouldRepaint(AudArcKnobPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.origin != origin ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.valueColor != valueColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
