// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const address = AudParamAddress('filter', 'cutoff');

  group('AudParamAddress', () {
    test('names the parameter as an OSC path', () {
      expect(address.path, '/filter/cutoff');
      expect(address.toString(), '/filter/cutoff');
    });

    test('compares by node and parameter', () {
      expect(address, const AudParamAddress('filter', 'cutoff'));
      expect(
        address.hashCode,
        const AudParamAddress('filter', 'cutoff').hashCode,
      );
      expect(address == const AudParamAddress('filter', 'mode'), isFalse);
      expect(address == const AudParamAddress('osc', 'cutoff'), isFalse);
    });
  });

  group('AudParamSpec', () {
    const linear = AudParamSpec(
      address: address,
      min: 0,
      max: 4,
      defaultValue: 1,
    );
    const logarithmic = AudParamSpec(
      address: address,
      min: 20,
      max: 20000,
      defaultValue: 1000,
      logarithmic: true,
      unit: 'Hz',
      name: 'Cutoff',
    );
    const stepped = AudParamSpec(
      address: address,
      min: 0,
      max: 3,
      defaultValue: 0,
      steps: 4,
    );

    test('maps linearly', () {
      expect(linear.toPlain(0.25), 1);
      expect(linear.toNormalized(1), 0.25);
      expect(linear.toPlain(-1), 0);
      expect(linear.toPlain(2), 4);
      expect(linear.toNormalized(9), 1);
    });

    test('maps logarithmically', () {
      expect(logarithmic.toPlain(0), closeTo(20, 1e-9));
      expect(logarithmic.toPlain(1), closeTo(20000, 1e-6));
      expect(logarithmic.toPlain(0.5), closeTo(632.4555, 1e-3));
      expect(logarithmic.toNormalized(632.4555320336759), closeTo(0.5, 1e-9));
    });

    test('maps linearly when a logarithmic range starts at zero', () {
      const zero = AudParamSpec(
        address: address,
        min: 0,
        max: 10,
        defaultValue: 0,
        logarithmic: true,
      );
      expect(zero.toPlain(0.5), 5);
      expect(zero.toNormalized(5), 0.5);
    });

    test('snaps a stepped parameter to its steps', () {
      expect(stepped.toPlain(0.4), 1);
      expect(stepped.toPlain(0.9), 3);
      expect(stepped.toNormalized(2), closeTo(2 / 3, 1e-12));
    });

    test('maps an empty range to zero', () {
      const empty = AudParamSpec(
        address: address,
        min: 1,
        max: 1,
        defaultValue: 1,
      );
      expect(empty.toNormalized(1), 0);
    });

    test('formats values with their unit', () {
      expect(logarithmic.format(1234.5), '1235 Hz');
      expect(logarithmic.format(12.34), '12.3 Hz');
      expect(logarithmic.format(1.234), '1.23 Hz');
      expect(linear.format(0.5), '0.50');
      expect(stepped.format(2), '2');
      expect(logarithmic.name, 'Cutoff');
    });
  });
}
