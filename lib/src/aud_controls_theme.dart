// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:flutter/widgets.dart';

// #############################################################################
/// The colors and text styles of the controls (decision ui-002: an inherited
/// theme instead of AudioKit's copy-on-write modifiers).
@immutable
class AudControlsThemeData {
  /// Creates a theme; the defaults are a dark scheme.
  const AudControlsThemeData({
    this.trackColor = const Color(0xFF40454D),
    this.valueColor = const Color(0xFF5CABFA),
    this.strokeWidth = 6,
    this.labelStyle = const TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)),
    this.valueStyle = const TextStyle(
      fontSize: 11,
      color: Color(0xFF999999),
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  });

  /// The color of the unfilled track.
  final Color trackColor;

  /// The color of the value.
  final Color valueColor;

  /// The stroke of arcs.
  final double strokeWidth;

  /// The style of labels.
  final TextStyle labelStyle;

  /// The style of values.
  final TextStyle valueStyle;

  // ...........................................................................
  /// A copy with the given fields replaced.
  AudControlsThemeData copyWith({
    Color? trackColor,
    Color? valueColor,
    double? strokeWidth,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) => AudControlsThemeData(
    trackColor: trackColor ?? this.trackColor,
    valueColor: valueColor ?? this.valueColor,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    labelStyle: labelStyle ?? this.labelStyle,
    valueStyle: valueStyle ?? this.valueStyle,
  );

  @override
  bool operator ==(Object other) =>
      other is AudControlsThemeData &&
      other.trackColor == trackColor &&
      other.valueColor == valueColor &&
      other.strokeWidth == strokeWidth &&
      other.labelStyle == labelStyle &&
      other.valueStyle == valueStyle;

  @override
  int get hashCode =>
      Object.hash(trackColor, valueColor, strokeWidth, labelStyle, valueStyle);
}

// #############################################################################
/// Provides [AudControlsThemeData] to the controls below.
class AudControlsTheme extends InheritedWidget {
  /// Creates the theme.
  const AudControlsTheme({super.key, required this.data, required super.child});

  /// The theme.
  final AudControlsThemeData data;

  // ...........................................................................
  /// The nearest theme, or the default.
  static AudControlsThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AudControlsTheme>()?.data ??
      const AudControlsThemeData();

  @override
  bool updateShouldNotify(AudControlsTheme oldWidget) => data != oldWidget.data;
}
