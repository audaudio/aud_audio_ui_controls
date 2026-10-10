// @license
// Copyright (c) Audanika. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:aud_audio_ui_controls/aud_audio_ui_controls.dart';
import 'package:flutter/material.dart';

/// The parameters of the example: those of the graph document that the
/// spike's plugins render (oscillator, filter, mixer).
const specs = [
  AudParamSpec(
    address: AudParamAddress('osc', 'frequency'),
    min: 20,
    max: 20000,
    defaultValue: 220,
    logarithmic: true,
    name: 'Frequency',
    unit: 'Hz',
  ),
  AudParamSpec(
    address: AudParamAddress('filter', 'cutoff'),
    min: 20,
    max: 20000,
    defaultValue: 1000,
    logarithmic: true,
    name: 'Cutoff',
    unit: 'Hz',
  ),
  AudParamSpec(
    address: AudParamAddress('out', 'gain'),
    min: 0,
    max: 1,
    defaultValue: 0.5,
    name: 'Gain',
  ),
];

void main() => runApp(const ControlsExample());

// #############################################################################
/// An in-memory sink that tells its listeners about every call, so that the
/// example lists them.
class ExampleSink extends AudMemoryParamSink with ChangeNotifier {
  @override
  void beginGesture(AudParamAddress address) {
    super.beginGesture(address);
    notifyListeners();
  }

  @override
  void setValue(AudParamAddress address, double value) {
    super.setValue(address, value);
    notifyListeners();
  }

  @override
  void endGesture(AudParamAddress address) {
    super.endGesture(address);
    notifyListeners();
  }
}

// #############################################################################
/// Knobs bound to an in-memory sink: the sink records what an engine or a
/// plugin shell would receive, and "Automate" changes the cutoff from
/// outside, as a host's automation would.
class ControlsExample extends StatefulWidget {
  /// Creates the example.
  const ControlsExample({super.key, this.sink});

  /// The sink; a new one by default.
  final ExampleSink? sink;

  @override
  State<ControlsExample> createState() => _ControlsExampleState();
}

class _ControlsExampleState extends State<ControlsExample> {
  late final ExampleSink _sink = widget.sink ?? ExampleSink();
  late final List<AudParamBinding> _bindings = [
    for (final spec in specs) AudParamBinding(sink: _sink, spec: spec),
  ];
  AudControlGeometry _geometry = const AudVerticalDragGeometry();
  Timer? _automation;

  @override
  void initState() {
    super.initState();
    _sink.addListener(_showCalls);
  }

  @override
  void dispose() {
    _automation?.cancel();
    _sink.removeListener(_showCalls);
    for (final binding in _bindings) {
      binding.dispose();
    }
    if (widget.sink == null) {
      _sink.dispose();
      unawaited(_sink.close());
    }
    super.dispose();
  }

  void _showCalls() => setState(() {});

  // ...........................................................................
  /// Sweeps the cutoff from 200 Hz to 5 kHz and back in 60 steps, through
  /// the sink's change stream.
  void _automate() {
    _automation?.cancel();
    final cutoff = specs[1];
    var step = 0;
    _automation = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      final phase = step <= 30 ? step / 30 : (60 - step) / 30;
      final low = cutoff.toNormalized(200);
      final high = cutoff.toNormalized(5000);
      _sink.emit(
        AudParamChange(
          cutoff.address,
          cutoff.toPlain(low + (high - low) * phase),
        ),
      );
      if (++step > 60) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calls = _sink.calls;
    return MaterialApp(
      title: 'aud_audio_ui_controls',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('aud_audio_ui_controls')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: [
                  for (final binding in _bindings)
                    AudParamKnob(binding: binding, geometry: _geometry),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Vertical drag')),
                      ButtonSegment(value: true, label: Text('Angular drag')),
                    ],
                    selected: {_geometry is AudAngularDragGeometry},
                    onSelectionChanged: (selection) => setState(
                      () => _geometry = selection.first
                          ? const AudAngularDragGeometry()
                          : const AudVerticalDragGeometry(),
                    ),
                  ),
                  FilledButton(
                    onPressed: _automate,
                    child: const Text('Automate'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'What the sink received',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  key: const Key('calls'),
                  children: [
                    for (final call in calls.reversed.take(12))
                      Text(call, style: const TextStyle(fontFamily: 'Menlo')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
