// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:aud_audio_ui_controls_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ControlsExample', () {
    late ExampleSink sink;

    setUp(() => sink = ExampleSink());
    tearDown(() async {
      sink.dispose();
      await sink.close();
    });

    testWidgets('shows a knob per parameter', (tester) async {
      await tester.pumpWidget(ControlsExample(sink: sink));
      expect(find.byType(AudParamKnob), findsNWidgets(specs.length));
      expect(find.text('Cutoff'), findsOneWidget);
    });

    testWidgets('sends a drag to the sink and lists it', (tester) async {
      await tester.pumpWidget(ControlsExample(sink: sink));
      await tester.drag(find.byType(AudArcKnob).at(1), const Offset(0, -30));
      await tester.pump();
      expect(sink.calls.first, 'begin /filter/cutoff');
      expect(sink.calls.last, 'end /filter/cutoff');
      expect(find.text('end /filter/cutoff'), findsOneWidget);
    });

    testWidgets('switches the geometry', (tester) async {
      await tester.pumpWidget(ControlsExample(sink: sink));
      await tester.tap(find.text('Angular drag'));
      await tester.pump();
      final knob = tester.widget<AudParamKnob>(find.byType(AudParamKnob).first);
      expect(knob.geometry, isA<AudAngularDragGeometry>());
    });

    testWidgets('moves the cutoff with automation', (tester) async {
      await tester.pumpWidget(ControlsExample(sink: sink));
      await tester.tap(find.text('Automate'));
      await tester.pump(const Duration(milliseconds: 600));
      final cutoff = sink.values[const AudParamAddress('filter', 'cutoff')];
      expect(cutoff, isNotNull);
      expect(cutoff, greaterThan(200));
      await tester.pump(const Duration(seconds: 2));
      expect(
        sink.values[const AudParamAddress('filter', 'cutoff')],
        closeTo(200, 1),
      );
    });
  });
}
