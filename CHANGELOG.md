# Changelog

## 0.1.0 - 2026-10-11

### Added

- Add Control, ArcKnob and ParamBinding (S17a slice)

- Add AudParamSpec, AudParamSink with an in-memory sink and AudParamBinding

- Add AudControl with the drag geometries and the pointer-averaging gesture layer

- Add AudArcKnob, AudParamKnob and AudControlsTheme with golden tests

- Add an example app over an in-memory sink

- Drop the dependency on the umbrella


### Changed

- Fix angular drag, removal mid-drag and stepped format

- Let one gesture turn the angular drag over the whole range

- End the gesture of a control removed during the drag without errors

- Keep the unit of stepped values and show fractional steps

- Name the parameters of AudParamAddress and AudParamChange

- Rebuild the README along the template with runnable examples and every export

- Add landmarks and named constants; rebuild only the call log of the example

## 0.0.2 - 2026-10-08

### Added

- Initial boilerplate

### Changed

- Record the gg commit state
- Set up GitHub repo settings and branch rules
