// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'aud_control_geometry.dart';

// #############################################################################
/// Builds the look of a control from its value in 0 to 1 and whether a
/// gesture runs.
typedef AudControlBuilder =
    Widget Function(BuildContext context, double value, bool active);

// #############################################################################
/// The generic control of AudioKit Controls (decision ui-002): one value in
/// 0 to 1, moved by a [geometry]. The gesture layer averages all active
/// pointers into one point, so two fingers move a control as one. It reads
/// raw pointer events - no gesture arena, no slop - so the first move
/// already changes the value.
class AudControl extends StatefulWidget {
  /// Creates a control.
  ///
  /// - [value] the value in 0 to 1
  /// - [geometry] how pointer movement changes it
  /// - [onChanged] the new value during a gesture
  /// - [onStarted] and [onEnded] frame a gesture; a scroll is one, too
  /// - [builder] the look
  const AudControl({
    super.key,
    required this.value,
    this.geometry = const AudVerticalDragGeometry(),
    this.onChanged,
    this.onStarted,
    this.onEnded,
    required this.builder,
  });

  /// The value in 0 to 1.
  final double value;

  /// How pointer movement changes the value.
  final AudControlGeometry geometry;

  /// The new value during a gesture.
  final ValueChanged<double>? onChanged;

  /// A gesture starts.
  final VoidCallback? onStarted;

  /// A gesture ends.
  final VoidCallback? onEnded;

  /// The look.
  final AudControlBuilder builder;

  @override
  State<AudControl> createState() => _AudControlState();
}

class _AudControlState extends State<AudControl> {
  final Map<int, Offset> _pointers = {};
  Offset _start = Offset.zero;
  double _startValue = 0;
  double _current = 0;

  bool get _active => _pointers.isNotEmpty;

  Offset get _average {
    var sum = Offset.zero;
    for (final point in _pointers.values) {
      sum += point;
    }
    return sum / _pointers.length.toDouble();
  }

  // Starts counting from the averaged point again, so that a finger that
  // joins or leaves does not jump the value.
  void _anchor() {
    _start = _average;
    _startValue = _current;
  }

  void _down(PointerDownEvent event) {
    final wasActive = _active;
    _pointers[event.pointer] = event.localPosition;
    if (!wasActive) {
      _current = widget.value;
      widget.onStarted?.call();
      setState(() {});
    }
    _anchor();
  }

  void _move(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;
    final next = widget.geometry.valueFor(
      start: _start,
      current: _average,
      startValue: _startValue,
      size: context.size ?? Size.zero,
    );
    if (next == _current) return;
    _current = next;
    widget.onChanged?.call(next);
  }

  void _up(PointerEvent event) {
    if (_pointers.remove(event.pointer) == null) return;
    if (_active) {
      _anchor();
      return;
    }
    widget.onEnded?.call();
    setState(() {});
  }

  void _signal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || _active) return;
    final next = widget.geometry.scrolled(
      value: widget.value,
      delta: event.scrollDelta,
    );
    if (next == widget.value) return;
    widget.onStarted?.call();
    widget.onChanged?.call(next);
    widget.onEnded?.call();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: _up,
    onPointerCancel: _up,
    onPointerSignal: _signal,
    child: widget.builder(context, widget.value, _active),
  );
}
