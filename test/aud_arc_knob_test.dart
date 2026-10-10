// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudArcKnob', () {
    Widget knob(double value, {String? text, double origin = 0}) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              child: SizedBox.square(
                dimension: 80,
                child: AudArcKnob(value: value, text: text, origin: origin),
              ),
            ),
          ),
        );

    testWidgets('shows its text', (tester) async {
      await tester.pumpWidget(knob(0.5, text: '440 Hz'));
      expect(find.text('440 Hz'), findsOneWidget);
    });

    testWidgets('matches the golden', (tester) async {
      await tester.pumpWidget(knob(0.4));
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/aud_arc_knob.png'),
      );
      await tester.pumpWidget(knob(0.25, origin: 0.5));
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('goldens/aud_arc_knob_bipolar.png'),
      );
    });

    testWidgets('passes gestures on', (tester) async {
      final events = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.square(
              dimension: 80,
              child: AudArcKnob(
                value: 0.5,
                onStarted: () => events.add('start'),
                onChanged: (v) => events.add('change'),
                onEnded: () => events.add('end'),
              ),
            ),
          ),
        ),
      );
      await tester.drag(find.byType(AudArcKnob), const Offset(0, -10));
      expect(events.first, 'start');
      expect(events.last, 'end');
    });
  });

  group('AudArcKnobPainter', () {
    test('repaints when a field changes', () {
      const base = AudArcKnobPainter(
        value: 0.5,
        origin: 0,
        trackColor: Color(0xFF000000),
        valueColor: Color(0xFFFFFFFF),
        strokeWidth: 6,
      );
      expect(base.shouldRepaint(base), isFalse);
      for (final other in const [
        AudArcKnobPainter(
          value: 0.6,
          origin: 0,
          trackColor: Color(0xFF000000),
          valueColor: Color(0xFFFFFFFF),
          strokeWidth: 6,
        ),
        AudArcKnobPainter(
          value: 0.5,
          origin: 1,
          trackColor: Color(0xFF000000),
          valueColor: Color(0xFFFFFFFF),
          strokeWidth: 6,
        ),
        AudArcKnobPainter(
          value: 0.5,
          origin: 0,
          trackColor: Color(0xFF000001),
          valueColor: Color(0xFFFFFFFF),
          strokeWidth: 6,
        ),
        AudArcKnobPainter(
          value: 0.5,
          origin: 0,
          trackColor: Color(0xFF000000),
          valueColor: Color(0xFFFFFFFE),
          strokeWidth: 6,
        ),
        AudArcKnobPainter(
          value: 0.5,
          origin: 0,
          trackColor: Color(0xFF000000),
          valueColor: Color(0xFFFFFFFF),
          strokeWidth: 5,
        ),
      ]) {
        expect(other.shouldRepaint(base), isTrue);
      }
    });
  });
}
