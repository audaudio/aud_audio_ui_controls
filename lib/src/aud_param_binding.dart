// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'aud_param_sink.dart';
import 'aud_param_spec.dart';

// #############################################################################
/// Binds a control to a parameter (decision ui-002): the control's gesture
/// becomes a parameter gesture of the [sink], its normalized position a
/// plain value, and values that change outside the control move it.
///
/// [value] is the normalized position in 0 to 1, as controls use it.
class AudParamBinding extends ChangeNotifier
    implements ValueListenable<double> {
  /// Binds [spec] to [sink], starting at the plain [initial] value or the
  /// default.
  AudParamBinding({required this.sink, required this.spec, double? initial})
    : _value = spec.toNormalized(initial ?? spec.defaultValue) {
    _subscription = sink.changes.listen((change) {
      if (change.address != spec.address) return;
      _apply(spec.toNormalized(change.value));
    });
  }

  /// Where the edits go.
  final AudParamSink sink;

  /// The parameter.
  final AudParamSpec spec;

  late final StreamSubscription<AudParamChange> _subscription;
  double _value;
  bool _active = false;

  @override
  double get value => _value;

  /// The plain value.
  double get plainValue => spec.toPlain(_value);

  /// Whether a gesture is running.
  bool get active => _active;

  // ...........................................................................
  /// Starts a gesture.
  void begin() {
    if (_active) return;
    _active = true;
    sink.beginGesture(spec.address);
  }

  // ...........................................................................
  /// Moves to the normalized [position] and sends the plain value.
  void set(double position) {
    final next = position.clamp(0.0, 1.0);
    if (next == _value) return;
    _apply(next);
    sink.setValue(spec.address, spec.toPlain(next));
  }

  // ...........................................................................
  /// Ends the gesture.
  void end() {
    if (!_active) return;
    _active = false;
    sink.endGesture(spec.address);
  }

  void _apply(double next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
