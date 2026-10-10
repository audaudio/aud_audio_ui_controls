// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'aud_param_spec.dart';

// #############################################################################
/// A plain value of a parameter that changed outside the control: through
/// the engine, the host's automation or another view.
final class AudParamChange {
  /// Creates a change.
  const AudParamChange(this.address, this.value);

  /// The parameter.
  final AudParamAddress address;

  /// The plain value.
  final double value;

  @override
  bool operator ==(Object other) =>
      other is AudParamChange &&
      other.address == address &&
      other.value == value;

  @override
  int get hashCode => Object.hash(address, value);

  @override
  String toString() => 'AudParamChange($address, $value)';
}

// #############################################################################
/// Where a bound control sends its edits: the engine of an app, a plugin
/// shell across a process boundary, a remote engine. A gesture starts with
/// [beginGesture] and ends with [endGesture], as the automation of VST3 and
/// CLAP records it; [setValue] carries the plain values in between.
///
/// The sink knows nothing of Flutter, so a plugin's editor, an app and a
/// test implement it alike.
abstract interface class AudParamSink {
  /// Starts a gesture on [address].
  void beginGesture(AudParamAddress address);

  /// Sets the plain [value] of [address].
  void setValue(AudParamAddress address, double value);

  /// Ends the gesture on [address].
  void endGesture(AudParamAddress address);

  /// Values that changed outside the controls.
  Stream<AudParamChange> get changes;
}

// #############################################################################
/// A sink that keeps the values in memory: for examples, tests and editors
/// without an engine. [calls] records every call in order.
class AudMemoryParamSink implements AudParamSink {
  /// Creates the sink.
  AudMemoryParamSink();

  final _changes = StreamController<AudParamChange>.broadcast(sync: true);

  /// The current plain values.
  final Map<AudParamAddress, double> values = {};

  /// Every call as text: `begin /osc/frequency`, `set /osc/frequency 440.0`,
  /// `end /osc/frequency`.
  final List<String> calls = [];

  @override
  void beginGesture(AudParamAddress address) => calls.add('begin $address');

  @override
  void setValue(AudParamAddress address, double value) {
    values[address] = value;
    calls.add('set $address $value');
  }

  @override
  void endGesture(AudParamAddress address) => calls.add('end $address');

  @override
  Stream<AudParamChange> get changes => _changes.stream;

  // ...........................................................................
  /// Changes a value from outside, as an engine or a host would.
  void emit(AudParamChange change) {
    values[change.address] = change.value;
    _changes.add(change);
  }

  // ...........................................................................
  /// Closes the change stream.
  Future<void> close() => _changes.close();
}
