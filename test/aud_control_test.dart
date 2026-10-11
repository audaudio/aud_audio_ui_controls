// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math' as math;

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudControl', () {
    late List<String> events;
    late double value;
    late bool lastActive;

    Future<void> pump(
      WidgetTester tester, {
      AudControlGeometry geometry = const AudVerticalDragGeometry(),
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.square(
              dimension: 80,
              child: StatefulBuilder(
                builder: (context, setState) => AudControl(
                  value: value,
                  geometry: geometry,
                  onStarted: () => events.add('start'),
                  onChanged: (v) => setState(() {
                    value = v;
                    events.add('change ${v.toStringAsFixed(3)}');
                  }),
                  onEnded: () => events.add('end'),
                  builder: (context, value, active) {
                    lastActive = active;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    setUp(() {
      events = [];
      value = 0.5;
      lastActive = false;
    });

    testWidgets('drags up from the first move on', (tester) async {
      await pump(tester);
      final center = tester.getCenter(find.byType(AudControl));
      final gesture = await tester.startGesture(center);
      await tester.pump();
      expect(lastActive, isTrue);
      await gesture.moveBy(const Offset(0, -0.2));
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(Offset.zero);
      await gesture.up();
      await tester.pump();
      expect(events, ['start', 'change 0.501', 'change 0.601', 'end']);
      expect(lastActive, isFalse);
    });

    testWidgets('averages two pointers and re-anchors', (tester) async {
      await pump(tester);
      final center = tester.getCenter(find.byType(AudControl));
      final first = await tester.startGesture(center, pointer: 1);
      final second = await tester.startGesture(
        center + const Offset(10, 0),
        pointer: 2,
      );
      await first.moveBy(const Offset(0, -40));
      // Both pointers moved by -40 on average after this: -20 each.
      expect(value, closeTo(0.6, 1e-9));
      await second.up();
      await first.moveBy(const Offset(0, -20));
      expect(value, closeTo(0.7, 1e-9));
      await first.cancel();
      expect(events.first, 'start');
      expect(events.last, 'end');
      expect(events.where((e) => e == 'start').length, 1);
    });

    for (final clockwise in [true, false]) {
      final (from, to) = clockwise ? (0.0, 1.0) : (1.0, 0.0);
      testWidgets(
        'turns ${clockwise ? 'clockwise' : 'back'} by 270° from $from to $to',
        (tester) async {
          value = from;
          await pump(tester, geometry: const AudAngularDragGeometry());
          final center = tester.getCenter(find.byType(AudControl));
          Offset at(int degrees) =>
              center + Offset.fromDirection(degrees * math.pi / 180, 30);
          // Along the arc of a knob, which runs clockwise from 135° to 405°.
          final start = clockwise ? 135 : 405;
          final step = clockwise ? 15 : -15;
          final gesture = await tester.startGesture(at(start));
          for (var i = 1; i <= 18; i++) {
            await gesture.moveTo(at(start + i * step));
          }
          await gesture.up();
          expect(value, closeTo(to, 1e-9));
        },
      );
    }

    testWidgets('ends a gesture once when removed during it', (tester) async {
      await pump(tester);
      final center = tester.getCenter(find.byType(AudControl));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(0, -20));
      await tester.pumpWidget(const SizedBox());
      await gesture.moveBy(const Offset(0, -20));
      await gesture.up();
      expect(tester.takeException(), isNull);
      expect(events, ['start', 'change 0.600', 'end']);
    });

    testWidgets('ignores pointers it does not track', (tester) async {
      await pump(tester);
      final outside = await tester.startGesture(const Offset(1, 1));
      await outside.moveBy(const Offset(0, -40));
      await outside.up();
      expect(events, isEmpty);
    });

    testWidgets('scrolls as one short gesture', (tester) async {
      await pump(tester);
      final center = tester.getCenter(find.byType(AudControl));
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(center));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -20)));
      expect(events, ['start', 'change 0.600', 'end']);
      events.clear();
      value = 1;
      await pump(tester);
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -20)));
      expect(events, isEmpty);
    });

    testWidgets('ignores scrolling during a drag', (tester) async {
      await pump(tester);
      final center = tester.getCenter(find.byType(AudControl));
      final gesture = await tester.startGesture(
        center,
        kind: PointerDeviceKind.mouse,
      );
      final wheel = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(wheel.hover(center));
      await tester.sendEventToBinding(wheel.scroll(const Offset(0, -20)));
      await gesture.up();
      expect(events, ['start', 'end']);
    });
  });
}
