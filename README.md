# aud_audio_ui_controls

Knobs, sliders, wheels, ribbon, joystick and XY pad of the Audanika Audio Engine, modeled on AudioKit Controls.

Part of the Audanika Audio Engine; planned in [aud_audio_pm](https://github.com/audaudio/aud_audio_pm).

## What the package holds (0.1.0, ticket 24)

The first slice of step S17a, built for the spike S0-plugin-ui
(decisions ui-002 and ui-003):

- `AudControl`: one value from 0 to 1, driven by an `AudControlGeometry` —
  the vertical relative drag or the angular drag. A gesture layer averages
  all active pointers into one point.
- `AudArcKnob`: an arc from 45° to 315°, with an origin for bipolar values;
  `AudControlsTheme` holds its colors.
- `AudParamSpec` and `AudParamAddress`: a parameter's range, default,
  logarithmic or stepped mapping, name and unit, and its OSC address.
- `AudParamSink`: where a bound control sends its edits — begin a gesture,
  set a plain value, end the gesture — and the values that change outside
  the control. `AudMemoryParamSink` keeps them in memory.
- `AudParamBinding` binds a control to a parameter through a sink;
  `AudParamKnob` is an `AudArcKnob` with its label and value.

The widgets and the sink do not depend on the engine (ui-003). An app binds
them to `AudEngine` through `aud_audio_ui_bindings` (S17a), a plugin's
editor binds them to its shell's protocol.

```dart
final sink = AudMemoryParamSink();
final cutoff = AudParamBinding(
  sink: sink,
  spec: const AudParamSpec(
    address: AudParamAddress('filter', 'cutoff'),
    min: 20,
    max: 20000,
    defaultValue: 1000,
    logarithmic: true,
    name: 'Cutoff',
    unit: 'Hz',
  ),
);

// In the widget tree:
AudParamKnob(binding: cutoff);
```

The example in `example/` drives three knobs through an in-memory sink and
lists what the sink receives.
