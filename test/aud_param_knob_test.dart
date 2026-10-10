// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = AudParamAddress('filter', 'cutoff');
  const spec = AudParamSpec(
    address: address,
    min: 20,
    max: 20000,
    defaultValue: 1000,
    logarithmic: true,
    name: 'Cutoff',
    unit: 'Hz',
  );

  group('AudParamKnob', () {
    late AudMemoryParamSink sink;
    late AudParamBinding binding;

    setUp(() {
      sink = AudMemoryParamSink();
      binding = AudParamBinding(sink: sink, spec: spec);
    });

    tearDown(() async {
      binding.dispose();
      await sink.close();
    });

    Widget knob({String? label}) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: AudParamKnob(binding: binding, label: label),
      ),
    );

    testWidgets('shows the name and the value', (tester) async {
      await tester.pumpWidget(knob());
      expect(find.text('Cutoff'), findsOneWidget);
      expect(find.text('1000 Hz'), findsOneWidget);
      await tester.pumpWidget(knob(label: 'Filter'));
      expect(find.text('Filter'), findsOneWidget);
    });

    testWidgets('sends a gesture to the sink', (tester) async {
      await tester.pumpWidget(knob());
      await tester.drag(find.byType(AudArcKnob), const Offset(0, -20));
      expect(sink.calls.first, 'begin /filter/cutoff');
      expect(sink.calls.last, 'end /filter/cutoff');
      expect(sink.calls.where((c) => c.startsWith('set')), isNotEmpty);
    });

    testWidgets('moves with values from outside', (tester) async {
      await tester.pumpWidget(knob());
      sink.emit(const AudParamChange(address, 20000));
      await tester.pump();
      expect(find.text('20000 Hz'), findsOneWidget);
    });
  });
}
