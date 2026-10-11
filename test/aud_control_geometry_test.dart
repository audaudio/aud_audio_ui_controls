// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math' as math;

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const size = Size(80, 80);

  group('AudVerticalDragGeometry', () {
    const geometry = AudVerticalDragGeometry();

    test('raises the value when dragged up', () {
      expect(
        geometry.valueFor(
          start: const Offset(40, 40),
          current: const Offset(10, 20),
          startValue: 0.5,
          size: size,
        ),
        0.6,
      );
    });

    test('clamps to the range', () {
      expect(
        geometry.valueFor(
          start: Offset.zero,
          current: const Offset(0, 500),
          startValue: 0.5,
          size: size,
        ),
        0,
      );
    });

    test('scrolls', () {
      expect(geometry.scrolled(value: 0.5, delta: const Offset(0, -20)), 0.6);
      expect(
        const AudVerticalDragGeometry(
          pointsPerRange: 100,
        ).scrolled(value: 0.95, delta: const Offset(0, -20)),
        1,
      );
    });
  });

  group('AudAngularDragGeometry', () {
    const geometry = AudAngularDragGeometry();

    test('raises the value clockwise', () {
      final value = geometry.valueFor(
        start: const Offset(40, 0),
        current: const Offset(80, 40),
        startValue: 0.5,
        size: size,
      );
      expect(value, closeTo(0.5 + (math.pi / 2) / (1.5 * math.pi), 1e-12));
    });

    test('takes the short way across the seam', () {
      // From just below the left to just above it: a small clockwise turn.
      final up = geometry.valueFor(
        start: const Offset(0, 41),
        current: const Offset(0, 39),
        startValue: 0.5,
        size: size,
      );
      expect(up, greaterThan(0.5));
      expect(up, lessThan(0.52));
      final down = geometry.valueFor(
        start: const Offset(0, 39),
        current: const Offset(0, 41),
        startValue: 0.5,
        size: size,
      );
      expect(down, lessThan(0.5));
      expect(down, greaterThan(0.48));
    });

    test('scrolls', () {
      expect(geometry.scrolled(value: 0.5, delta: const Offset(0, 20)), 0.4);
    });

    test('takes its range', () {
      // ignore: prefer_const_constructors
      final half = AudAngularDragGeometry(angularRange: math.pi);
      expect(half.angularRange, math.pi);
    });
  });
}
