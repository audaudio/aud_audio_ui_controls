// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = AudParamAddress('out', 'master');
  const spec = AudParamSpec(address: address, min: 0, max: 4, defaultValue: 1);

  group('AudParamBinding', () {
    late AudMemoryParamSink sink;
    late AudParamBinding binding;
    late int notifications;

    setUp(() {
      sink = AudMemoryParamSink();
      binding = AudParamBinding(sink: sink, spec: spec);
      notifications = 0;
      binding.addListener(() => notifications++);
    });

    tearDown(() async {
      binding.dispose();
      await sink.close();
    });

    test('starts at the default or the initial value', () {
      expect(binding.value, 0.25);
      expect(binding.plainValue, 1);
      final other = AudParamBinding(sink: sink, spec: spec, initial: 2);
      expect(other.value, 0.5);
      other.dispose();
    });

    test('turns a gesture into sink calls with plain values', () {
      binding
        ..begin()
        ..begin()
        ..set(0.5)
        ..set(0.5)
        ..set(2)
        ..end()
        ..end();
      expect(sink.calls, [
        'begin /out/master',
        'set /out/master 2.0',
        'set /out/master 4.0',
        'end /out/master',
      ]);
      expect(binding.value, 1);
      expect(binding.active, isFalse);
      expect(notifications, 2);
    });

    test('reports whether a gesture runs', () {
      binding.begin();
      expect(binding.active, isTrue);
      binding.end();
      expect(binding.active, isFalse);
    });

    test('follows values that change outside', () {
      sink.emit(const AudParamChange(address, 3));
      expect(binding.value, 0.75);
      expect(notifications, 1);
      sink.emit(const AudParamChange(address, 3));
      expect(notifications, 1);
      sink.emit(const AudParamChange(AudParamAddress('osc', 'x'), 0));
      expect(binding.value, 0.75);
      expect(sink.calls, isEmpty);
    });
  });
}
