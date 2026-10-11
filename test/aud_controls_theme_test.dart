// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudControlsThemeData', () {
    test('copies with replaced fields', () {
      const data = AudControlsThemeData();
      final copy = data.copyWith(
        trackColor: const Color(0xFF000001),
        valueColor: const Color(0xFF000002),
        strokeWidth: 2,
        labelStyle: const TextStyle(fontSize: 1),
        valueStyle: const TextStyle(fontSize: 2),
      );
      expect(copy.trackColor, const Color(0xFF000001));
      expect(copy.valueColor, const Color(0xFF000002));
      expect(copy.strokeWidth, 2);
      expect(copy.labelStyle, const TextStyle(fontSize: 1));
      expect(copy.valueStyle, const TextStyle(fontSize: 2));
      expect(data.copyWith(), data);
      expect(data.copyWith().hashCode, data.hashCode);
      expect(data == copy, isFalse);
    });
  });

  group('AudControlsTheme', () {
    testWidgets('provides its data or the default', (tester) async {
      late AudControlsThemeData found;
      final probe = Builder(
        builder: (context) {
          found = AudControlsTheme.of(context);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(probe);
      expect(found, const AudControlsThemeData());
      const data = AudControlsThemeData(strokeWidth: 3);
      await tester.pumpWidget(
        const AudControlsTheme(data: data, child: SizedBox()),
      );
      await tester.pumpWidget(AudControlsTheme(data: data, child: probe));
      expect(found.strokeWidth, 3);
    });

    test('notifies when the data changes', () {
      const a = AudControlsTheme(
        data: AudControlsThemeData(),
        child: SizedBox(),
      );
      const b = AudControlsTheme(
        data: AudControlsThemeData(strokeWidth: 2),
        child: SizedBox(),
      );
      expect(b.updateShouldNotify(a), isTrue);
      expect(a.updateShouldNotify(a), isFalse);
    });
  });
}
