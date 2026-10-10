# aud_audio_ui_controls

Knobs, sliders, wheels, ribbon, joystick and XY pad of the Audanika Audio Engine, modeled on AudioKit Controls.

Teil der Audanika Audio Engine; geplant in [aud_audio_pm](https://github.com/audaudio/aud_audio_pm).

## Was das Paket enthält (0.1.0, Ticket 24)

Die erste Scheibe von Schritt S17a, gebaut für den Spike S0-plugin-ui
(Entscheidungen ui-002 und ui-003):

- `AudControl`: ein Wert von 0 bis 1, gesteuert von einer
  `AudControlGeometry` — dem vertikalen relativen Ziehen oder dem
  Winkel-Ziehen. Eine Gesten-Schicht mittelt alle aktiven Zeiger zu einem
  Punkt.
- `AudArcKnob`: ein Bogen von 45° bis 315°, mit einem Ursprung für
  bipolare Werte; `AudControlsTheme` hält seine Farben.
- `AudParamSpec` und `AudParamAddress`: Bereich, Vorgabe, logarithmische
  oder gestufte Abbildung, Name und Einheit eines Parameters und seine
  OSC-Adresse.
- `AudParamSink`: wohin ein gebundenes Control seine Änderungen schickt —
  Geste beginnen, Klarwert setzen, Geste beenden — und die Werte, die sich
  außerhalb des Controls ändern. `AudMemoryParamSink` hält sie im
  Speicher.
- `AudParamBinding` bindet ein Control über eine Senke an einen Parameter;
  `AudParamKnob` ist ein `AudArcKnob` mit Beschriftung und Wert.

Widgets und Senke hängen nicht von der Engine ab (ui-003). Eine App bindet
sie über `aud_audio_ui_bindings` (S17a) an `AudEngine`, der Editor eines
Plugins an das Protokoll seiner Shell.

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

// Im Widget-Baum:
AudParamKnob(binding: cutoff);
```

Das Beispiel in `example/` steuert drei Knöpfe über eine Senke im Speicher
und listet, was die Senke empfängt.
