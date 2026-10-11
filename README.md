# aud_audio_ui_controls

Knobs, sliders, wheels, ribbon, joystick and XY pad of the Audanika Audio Engine, modeled on AudioKit Controls.

Part of the Audanika Audio Engine; planned in [aud_audio_pm](https://github.com/audaudio/aud_audio_pm).

## Goals

- One generic control after AudioKit Controls (decision ui-002): a value
  in 0 to 1, a geometry that turns pointer movement into it and a builder
  for its look; the knobs, sliders, wheels, ribbon, joystick and XY pad
  build on it
- Touch and mouse alike: all active pointers average into one point, the
  first move already changes the value, a scroll is a gesture of its own
- Parameter gestures as the automation of VST3 and CLAP records them:
  begin, plain values, end
- Free of the engine (decision ui-003): an app, a plugin's editor and a
  test bind the same widgets through a sink
- An inherited theme instead of AudioKit's copy-on-write modifiers
- Golden tests for every look

## State

[![Tests](https://github.com/audaudio/aud_audio_ui_controls/actions/workflows/quick_check.yaml/badge.svg)](https://github.com/audaudio/aud_audio_ui_controls/actions/workflows/quick_check.yaml)

The first slice of step S17a (0.1.0, ticket 24), built for the spike
S0-plugin-ui: `AudControl` with the vertical and the angular drag,
`AudArcKnob` and the parameter binding. The other geometries, the control
for two parameters and the sliders, wheels, ribbon, joystick and XY pad
follow with S17a.

## Installation

```yaml
dependencies:
  aud_audio_ui_controls:
    git:
      url: git@github.com:audaudio/aud_audio_ui_controls.git
      tag_pattern: '{{version}}'
    version: ^0.1.0
```

The package needs the Flutter SDK and nothing else: no engine, no native
code.

## Documentation

- [The plan of ticket 24](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/tickets/2026-10-09-24-spike-a-flutter-editor-for-the-plugin-shells.md)
  with the findings of the spike
- The decisions
  [ui-002](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/concepts/decisions/ui-002.md)
  (controls after AudioKit Controls) and
  [ui-003](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/concepts/decisions/ui-003.md)
  (widgets bound through sinks, not to the engine)
- [AudioKit Controls](https://github.com/AudioKit/Controls), the template
  (MIT)
- The guides in [`doc/guides`](doc/guides)

## Code Examples

A knob bound to the cutoff of a filter, turned around its center, in an
orange theme; the in-memory sink records what an engine would receive:

```dart
import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';

void main() {
  final sink = AudMemoryParamSink();
  final cutoff = AudParamBinding(
    sink: sink,
    spec: const AudParamSpec(
      address: AudParamAddress(nodeId: 'filter', paramId: 'cutoff'),
      min: 20,
      max: 20000,
      defaultValue: 1000,
      logarithmic: true,
      name: 'Cutoff',
      unit: 'Hz',
    ),
  );
  runApp(
    AudControlsTheme(
      data: const AudControlsThemeData(valueColor: Color(0xFFFFA000)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: AudParamKnob(
            binding: cutoff,
            geometry: const AudAngularDragGeometry(),
          ),
        ),
      ),
    ),
  );
}
```

A turn leaves `begin /filter/cutoff`, a `set /filter/cutoff` with the
plain value per move and `end /filter/cutoff` in `sink.calls`;
`sink.emit` with an `AudParamChange` moves the knob, as a host's
automation would.

A plugin's editor implements the sink over its shell's protocol:

```dart
import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/widgets.dart';

/// Sends the edits to a plugin shell; here to the console.
class ShellSink implements AudParamSink {
  @override
  void beginGesture(AudParamAddress address) => debugPrint('begin $address');

  @override
  void setValue(AudParamAddress address, double value) =>
      debugPrint('set $address $value');

  @override
  void endGesture(AudParamAddress address) => debugPrint('end $address');

  @override
  Stream<AudParamChange> get changes => const Stream.empty();
}

void main() {
  final gain = AudParamBinding(
    sink: ShellSink(),
    spec: const AudParamSpec(
      address: AudParamAddress(nodeId: 'out', paramId: 'gain'),
      min: 0,
      max: 1,
      defaultValue: 0.5,
      name: 'Gain',
    ),
  );
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: AudParamKnob(binding: gain)),
    ),
  );
}
```

The example app in [`example`](example) binds three knobs to an in-memory
sink, switches between the vertical and the angular drag, lists what the
sink receives and automates the cutoff from outside:

```bash
cd example
flutter run -d macos
```

## How It Works

- `AudControl` holds one value in 0 to 1 and gets its look from an
  `AudControlBuilder`. It reads raw pointer events — no gesture arena, no
  slop — and averages all active pointers into one point, so two fingers
  move a control as one; a scroll is a short gesture of its own.
- An `AudControlGeometry` turns the movement of that point into the value:
  `AudVerticalDragGeometry` raises it when dragged up, 200 logical pixels
  over the whole range by default; `AudAngularDragGeometry` raises it when
  turned clockwise around the center, 270° over the whole range. The
  control starts each move where the last one ended, so a turn may go
  past half a circle.
- `AudArcKnob` is an `AudControl` painted by `AudArcKnobPainter`: a 270°
  arc with the gap at the bottom, filled from an origin to the value — 0
  for a level, 0.5 for a bipolar value such as pan. `AudControlsTheme`
  hands its `AudControlsThemeData` — colors, stroke and text styles — to
  the controls below.
- `AudParamSpec` describes a parameter: its `AudParamAddress` (node and
  parameter id, the OSC path `/<node>/<param>`), range, default, linear,
  logarithmic or stepped mapping, name and unit. It maps between
  normalized positions and plain values and formats them.
- `AudParamBinding` turns the gesture of a control into the calls of an
  `AudParamSink` — `beginGesture`, `setValue` with plain values,
  `endGesture` — and moves the control with every `AudParamChange` on the
  sink's `changes`. `AudMemoryParamSink` keeps the values in memory and
  records every call. `AudParamKnob` is an `AudArcKnob` bound through an
  `AudParamBinding`, with the value as text and the label below.
- The widgets and the sinks do not depend on the engine (ui-003): an app
  binds them to `AudEngine` through `aud_audio_ui_bindings` (S17a), a
  plugin's editor implements `AudParamSink` over its shell's protocol.
- `audAudioUiControlsVersion` holds the version of the package.

## Contributing

Tickets run through the `gg` workflow: see the
[Develop Guide](doc/guides/develop-guide.md) and the
[Review Guide](doc/guides/for-ai/ai-review-guide.md).
