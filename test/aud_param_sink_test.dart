// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = AudParamAddress('out', 'master');

  group('AudParamChange', () {
    test('compares by address and value', () {
      const change = AudParamChange(address, 0.5);
      expect(change, const AudParamChange(address, 0.5));
      expect(change.hashCode, const AudParamChange(address, 0.5).hashCode);
      expect(change == const AudParamChange(address, 0.25), isFalse);
      expect(change.toString(), 'AudParamChange(/out/master, 0.5)');
    });
  });

  group('AudMemoryParamSink', () {
    late AudMemoryParamSink sink;

    setUp(() => sink = AudMemoryParamSink());
    tearDown(() => sink.close());

    test('records gestures and values in order', () {
      sink
        ..beginGesture(address)
        ..setValue(address, 0.5)
        ..endGesture(address);
      expect(sink.calls, [
        'begin /out/master',
        'set /out/master 0.5',
        'end /out/master',
      ]);
      expect(sink.values, {address: 0.5});
    });

    test('emits changes from outside', () async {
      final changes = <AudParamChange>[];
      sink.changes.listen(changes.add);
      sink.emit(const AudParamChange(address, 2));
      expect(changes, [const AudParamChange(address, 2)]);
      expect(sink.values[address], 2);
    });
  });
}
