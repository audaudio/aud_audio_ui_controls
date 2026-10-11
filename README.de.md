# aud_audio_ui_controls

Drehregler, Schieberegler, Räder, Ribbon, Joystick und XY-Pad der Audanika Audio Engine, nach dem Vorbild von AudioKit Controls.

Teil der Audanika Audio Engine; geplant in [aud_audio_pm](https://github.com/audaudio/aud_audio_pm).

## Ziele

- Ein generisches Control nach AudioKit Controls (Entscheidung ui-002):
  ein Wert von 0 bis 1, eine Geometrie, die Zeigerbewegungen in ihn
  übersetzt, und ein Builder für sein Aussehen; Drehregler,
  Schieberegler, Räder, Ribbon, Joystick und XY-Pad bauen darauf auf
- Touch und Maus gleichermaßen: Alle aktiven Zeiger werden zu einem Punkt
  gemittelt, schon die erste Bewegung ändert den Wert, ein Scrollen ist
  eine eigene Geste
- Parameter-Gesten, wie die Automation von VST3 und CLAP sie aufzeichnet:
  Beginn, Klarwerte, Ende
- Frei von der Engine (Entscheidung ui-003): Eine App, der Editor eines
  Plugins und ein Test binden dieselben Widgets über eine Senke
- Ein vererbtes Theme statt der Copy-on-Write-Modifier von AudioKit
- Golden-Tests für jedes Aussehen

## Stand

[![Tests](https://github.com/audaudio/aud_audio_ui_controls/actions/workflows/quick_check.yaml/badge.svg)](https://github.com/audaudio/aud_audio_ui_controls/actions/workflows/quick_check.yaml)

Die erste Scheibe von Schritt S17a (0.1.0, Ticket 24), gebaut für den
Spike S0-plugin-ui: `AudControl` mit dem vertikalen und dem
Winkel-Ziehen, `AudArcKnob` und die Parameter-Bindung. Die übrigen
Geometrien, das Control für zwei Parameter sowie Schieberegler, Räder,
Ribbon, Joystick und XY-Pad folgen mit S17a.

## Installation

```yaml
dependencies:
  aud_audio_ui_controls:
    git:
      url: git@github.com:audaudio/aud_audio_ui_controls.git
      tag_pattern: '{{version}}'
    version: ^0.1.0
```

Das Paket braucht nur das Flutter-SDK: keine Engine, keinen nativen Code.

## Dokumentation

- [Der Plan von Ticket 24](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/tickets/2026-10-09-24-spike-a-flutter-editor-for-the-plugin-shells.md)
  mit den Befunden des Spikes
- Die Entscheidungen
  [ui-002](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/concepts/decisions/ui-002.md)
  (Controls nach AudioKit Controls) und
  [ui-003](https://github.com/audaudio/aud_audio_pm/blob/main/doc/2026-Q4/concepts/decisions/ui-003.md)
  (Widgets über Senken gebunden, nicht an die Engine)
- [AudioKit Controls](https://github.com/AudioKit/Controls), die Vorlage
  (MIT)
- Die Guides in [`doc/guides`](doc/guides)

## Code-Beispiele

Ein Drehregler, an die Cutoff-Frequenz eines Filters gebunden, um seine
Mitte gedreht, in einem orangen Theme; die Senke im Speicher zeichnet
auf, was eine Engine empfangen würde:

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

Eine Drehung hinterlässt `begin /filter/cutoff`, je Bewegung ein
`set /filter/cutoff` mit dem Klarwert und `end /filter/cutoff` in
`sink.calls`; `sink.emit` mit einer `AudParamChange` bewegt den
Drehregler, wie es die Automation eines Hosts täte.

Der Editor eines Plugins implementiert die Senke über das Protokoll
seiner Shell:

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

Die Beispiel-App in [`example`](example) bindet drei Drehregler an eine
Senke im Speicher, wechselt zwischen vertikalem und Winkel-Ziehen, listet,
was die Senke empfängt, und automatisiert die Cutoff-Frequenz von außen:

```bash
cd example
flutter run -d macos
```

## Funktionsweise

- `AudControl` hält einen Wert von 0 bis 1 und bekommt sein Aussehen von
  einem `AudControlBuilder`. Es liest rohe Zeiger-Ereignisse — keine
  Gesten-Arena, kein Schwellwert — und mittelt alle aktiven Zeiger zu
  einem Punkt, sodass zwei Finger ein Control wie einer bewegen; ein
  Scrollen ist eine eigene kurze Geste.
- Eine `AudControlGeometry` übersetzt die Bewegung dieses Punkts in den
  Wert: `AudVerticalDragGeometry` hebt ihn beim Ziehen nach oben,
  standardmäßig 200 logische Pixel über den ganzen Bereich;
  `AudAngularDragGeometry` hebt ihn beim Drehen im Uhrzeigersinn um die
  Mitte, 270° über den ganzen Bereich. Das Control beginnt jede Bewegung
  dort, wo die letzte endete, sodass eine Drehung über einen halben Kreis
  hinausgehen kann.
- `AudArcKnob` ist ein `AudControl`, gemalt von `AudArcKnobPainter`: ein
  Bogen über 270° mit der Lücke unten, gefüllt von einem Ursprung bis zum
  Wert — 0 für einen Pegel, 0,5 für einen bipolaren Wert wie das
  Panorama. `AudControlsTheme` reicht seine `AudControlsThemeData` —
  Farben, Strichstärke und Textstile — an die Controls darunter weiter.
- `AudParamSpec` beschreibt einen Parameter: seine `AudParamAddress`
  (Knoten- und Parameter-Id, der OSC-Pfad `/<node>/<param>`), Bereich,
  Vorgabe, lineare, logarithmische oder gestufte Abbildung, Name und
  Einheit. Sie bildet zwischen normierten Positionen und Klarwerten ab
  und formatiert sie.
- `AudParamBinding` macht aus der Geste eines Controls die Aufrufe einer
  `AudParamSink` — `beginGesture`, `setValue` mit Klarwerten,
  `endGesture` — und bewegt das Control mit jeder `AudParamChange` auf
  den `changes` der Senke. `AudMemoryParamSink` hält die Werte im
  Speicher und zeichnet jeden Aufruf auf. `AudParamKnob` ist ein
  `AudArcKnob`, über ein `AudParamBinding` gebunden, mit dem Wert als
  Text und der Beschriftung darunter.
- Widgets und Senken hängen nicht von der Engine ab (ui-003): Eine App
  bindet sie über `aud_audio_ui_bindings` (S17a) an `AudEngine`, der
  Editor eines Plugins implementiert `AudParamSink` über das Protokoll
  seiner Shell.
- `audAudioUiControlsVersion` hält die Version des Pakets.

## Mitwirken

Tickets laufen durch den `gg`-Workflow: siehe den
[Develop Guide](doc/guides/develop-guide.md) und den
[Review Guide](doc/guides/for-ai/ai-review-guide.md).
