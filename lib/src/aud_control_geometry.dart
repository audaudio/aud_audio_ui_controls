// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math' as math;
import 'dart:ui';

// #############################################################################
/// How a [AudControl](aud_control.dart) turns the movement of the averaged
/// pointer into a value in 0 to 1, after AudioKit Controls' ControlGeometry.
/// This slice of S17a carries the relative vertical drag and the angular
/// drag; S17a adds the points, the horizontal and two-dimensional drags and
/// the absolute angle.
sealed class AudControlGeometry {
  /// Creates a geometry.
  const AudControlGeometry();

  // ...........................................................................
  /// The value for a pointer that moved from [start] to [current] inside a
  /// control of [size], when the value was [startValue] at [start].
  double valueFor({
    required Offset start,
    required Offset current,
    required double startValue,
    required Size size,
  });

  // ...........................................................................
  /// The value after a scroll of [delta] logical pixels from [value].
  double scrolled({required double value, required Offset delta});
}

// #############################################################################
/// Dragging up raises the value: [pointsPerRange] logical pixels cover the
/// whole range, whatever the size of the control.
final class AudVerticalDragGeometry extends AudControlGeometry {
  /// Creates the geometry.
  const AudVerticalDragGeometry({this.pointsPerRange = 200});

  /// The logical pixels of a drag over the whole range.
  final double pointsPerRange;

  @override
  double valueFor({
    required Offset start,
    required Offset current,
    required double startValue,
    required Size size,
  }) => (startValue - (current.dy - start.dy) / pointsPerRange).clamp(0.0, 1.0);

  @override
  double scrolled({required double value, required Offset delta}) =>
      (value - delta.dy / pointsPerRange).clamp(0.0, 1.0);
}

// #############################################################################
/// Turning around the center raises the value clockwise: the angle the
/// pointer sweeps around the control's center, over [angularRange] radians
/// for the whole range.
final class AudAngularDragGeometry extends AudControlGeometry {
  /// Creates the geometry.
  const AudAngularDragGeometry({this.angularRange = 1.5 * math.pi});

  /// The radians of a turn over the whole range.
  final double angularRange;

  @override
  double valueFor({
    required Offset start,
    required Offset current,
    required double startValue,
    required Size size,
  }) {
    final center = size.center(Offset.zero);
    final from = (start - center).direction;
    final to = (current - center).direction;
    var delta = to - from;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    return (startValue + delta / angularRange).clamp(0.0, 1.0);
  }

  @override
  double scrolled({required double value, required Offset delta}) =>
      (value - delta.dy / 200).clamp(0.0, 1.0);
}
