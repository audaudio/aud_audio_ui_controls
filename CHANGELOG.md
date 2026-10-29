# Changelog

## Unreleased

### Changed

- Use com.example IDs in the example

## 0.2.1 - 2026-10-28

### Changed

- Resolve the example together with the package

- Add the example to a pub workspace, resolution: workspace in the example

- Drop the lock file of the example, the package lock covers it


## 0.2.0 - 2026-10-28

### Changed

- Require Dart 3.13 and Flutter 3.47, upgrade deps

- Require Dart 3.13 and Flutter 3.47

- Upgrade helix to ^1.14.0

- Upgrade dna_audanika to ^0.1.0

- Set the identity the DNA layers ask for in dna/_vars.json

- Reformat 2 files with the Dart 3.13 formatter

- Add the blog post of this change, in English and German

- Bring the README to the README template, in English and German

- Upgrade the dependencies published since the first pass

- Lift the lock file to the newest resolvable versions


## 0.1.1 - 2026-10-24

### Changed

- Make all repos run on Windows

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
