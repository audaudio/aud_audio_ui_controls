// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';

import 'aud_arc_knob.dart';
import 'aud_control_geometry.dart';
import 'aud_controls_theme.dart';
import 'aud_param_binding.dart';

// #############################################################################
/// An [AudArcKnob] bound to a parameter through an [AudParamBinding], with
/// its label below: the knob's gesture is the parameter's gesture, values
/// from outside move it.
class AudParamKnob extends StatelessWidget {
  /// Creates the knob.
  ///
  /// - [binding] the parameter
  /// - [label] the text below; the parameter's name by default
  /// - [size] the knob's diameter
  /// - [geometry] how pointer movement changes the value
  const AudParamKnob({
    super.key,
    required this.binding,
    this.label,
    this.size = 80,
    this.geometry = const AudVerticalDragGeometry(),
  });

  /// The parameter.
  final AudParamBinding binding;

  /// The text below the knob.
  final String? label;

  /// The diameter of the knob.
  final double size;

  /// How pointer movement changes the value.
  final AudControlGeometry geometry;

  @override
  Widget build(BuildContext context) {
    final theme = AudControlsTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: ValueListenableBuilder<double>(
            valueListenable: binding,
            builder: (context, value, _) => AudArcKnob(
              value: value,
              text: binding.spec.format(binding.spec.toPlain(value)),
              geometry: geometry,
              onStarted: binding.begin,
              onChanged: binding.set,
              onEnded: binding.end,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label ?? binding.spec.name, style: theme.labelStyle),
      ],
    );
  }
}
