// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:math' as math;

// #############################################################################
/// The address of a graph parameter: the node id and the parameter id of the
/// graph document, as the OSC address `/<node>/<param>` names it.
final class AudParamAddress {
  /// Creates an address.
  const AudParamAddress(this.nodeId, this.paramId);

  /// The node id in the graph document.
  final String nodeId;

  /// The parameter id in the node's descriptor.
  final String paramId;

  /// The address as an OSC path.
  String get path => '/$nodeId/$paramId';

  @override
  bool operator ==(Object other) =>
      other is AudParamAddress &&
      other.nodeId == nodeId &&
      other.paramId == paramId;

  @override
  int get hashCode => Object.hash(nodeId, paramId);

  @override
  String toString() => path;
}

// #############################################################################
/// What a control needs to know about a parameter: its range and how a
/// normalized position maps to a plain value - linear, logarithmic or in
/// steps, as the engine's descriptors declare it.
final class AudParamSpec {
  /// Creates a spec.
  ///
  /// - [address] the parameter
  /// - [min] and [max] the plain range
  /// - [defaultValue] the plain default
  /// - [logarithmic] maps positions on a logarithmic scale; needs a positive
  ///   [min]
  /// - [steps] the number of values of a stepped parameter, or 0
  /// - [name] and [unit] for labels
  const AudParamSpec({
    required this.address,
    required this.min,
    required this.max,
    required this.defaultValue,
    this.logarithmic = false,
    this.steps = 0,
    this.name = '',
    this.unit = '',
  });

  /// The parameter.
  final AudParamAddress address;

  /// The smallest plain value.
  final double min;

  /// The largest plain value.
  final double max;

  /// The plain default.
  final double defaultValue;

  /// Whether positions map logarithmically.
  final bool logarithmic;

  /// The number of values of a stepped parameter, or 0.
  final int steps;

  /// The display name.
  final String name;

  /// The unit, e.g. `Hz`.
  final String unit;

  bool get _isLogarithmic => logarithmic && min > 0;

  // ...........................................................................
  /// The plain value of a normalized position in 0 to 1.
  double toPlain(double normalized) {
    final n = normalized.clamp(0.0, 1.0);
    final double plain;
    if (steps >= 2) {
      final step = (n * (steps - 1)).roundToDouble();
      plain = min + step * (max - min) / (steps - 1);
    } else if (_isLogarithmic) {
      plain = min * math.pow(max / min, n);
    } else {
      plain = min + n * (max - min);
    }
    return plain.clamp(min, max);
  }

  // ...........................................................................
  /// The normalized position of a plain value.
  double toNormalized(double plain) {
    if (max <= min) return 0;
    final p = plain.clamp(min, max);
    if (_isLogarithmic) return math.log(p / min) / math.log(max / min);
    return (p - min) / (max - min);
  }

  // ...........................................................................
  /// The plain value as text with its unit.
  String format(double plain) {
    if (steps >= 2) return plain.round().toString();
    final digits = plain.abs() >= 100 ? 0 : (plain.abs() >= 10 ? 1 : 2);
    final text = plain.toStringAsFixed(digits);
    return unit.isEmpty ? text : '$text $unit';
  }
}
