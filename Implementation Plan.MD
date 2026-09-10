# Implementation Plan — Mercury & Venus Astronomy (Combined Application)

## Overview

This document records how the **MERVE** and **MVENC** Flutter applications were combined into a single cross-platform, accessible astronomy tool, and the design decisions made during the merge.

---

## Source Applications

| App | Original Platform | Key Functionality | Flutter Source |
|---|---|---|---|
| **MERVE** | Apple II / Commodore BASIC (1982) | Planetary position simulation with visual configuration diagram | `C:\Users\summi\GitHub\MERVE` |
| **MVENC** | Apple II / Commodore BASIC | Angular distances calculator and next-elongation date finder | `C:\Users\summi\GitHub\MVENC` |

---

## Architecture Decisions

### 1. Unified Astronomy Engine

Both apps compute Mercury/Venus positions using the same core formulas. Rather than maintaining two parallel engines, the combined app preserves both calculation modes in a single class hierarchy:

- **`AstronomyCalculator`** — abstract interface with one method: `calculate(DateTime, Planet) → PlanetData`. Also contains a concrete default implementation of `findNextElongation`.
- **`HeritageCalculator`** — a faithful port of the original 1982 BASIC epoch formulas (from MERVE.BAS / MVENC.BAS), using a 1960 epoch and simplified trigonometric approximations.
- **`ModernCalculator`** — J2000.0-based Keplerian orbital elements with a Newton–Raphson solve of Kepler's equation (from the original MERVE Flutter app). Provides best accuracy for current dates.

Both engines extend `AstronomyCalculator`, so the UI can switch between them transparently via the settings provider.

### 2. Shared Data Model

A single `PlanetData` class carries all computed outputs: date, distances (AU, million miles), elongation angle, angular diameter, illumination percentage, phase name, and Mercury viewing favorability. This model is used by both the simulation time-series results and the single-date angular distances view.

### 3. Navigation Model

An adaptive `AppShell` widget provides a `NavigationRail` (width > 600 px) or `NavigationBar` (narrow viewports) with three top-level sections:

| Tab | Content |
|---|---|
| Home | Menu of the three tools |
| Instructions | Combined user guide from both original programs |
| About | Credits, calculation mode toggle, theme selector, high-contrast switch |

Tool screens are pushed via `Navigator.push` from the Home menu, giving a stack-based drill-down flow on all platforms.

### 4. Merged Tool Screens

| Screen | Origin | Function |
|---|---|---|
| `SimulationScreen` | MERVE | Parameter form (date, interval, count) |
| `ResultsScreen` | MERVE | Time-series data + custom-painted visual configuration diagram |
| `AngularDistancesScreen` | MVENC | Single-date planet data view (both planets side by side) |
| `NextElongationScreen` | MVENC | Iterative elongation date search |

---

## Accessibility Implementation Plan

### WCAG 2.1 AA Compliance Checklist

| Principle | Requirement | Implementation |
|---|---|---|
| **Perceivable** | Text alternatives for non-text content | `Semantics(label: …)` on all interactive elements; `ExcludeSemantics` on decorative icons; full plain-text description of the visual configuration diagram |
| **Perceivable** | Information conveyed by color is not sole channel | Planet identities conveyed by labels (`M`, `V`, `S`) and text, not just orange vs amber circles |
| **Perceivable** | Content reflows at 400% zoom | All screens are wrapped in `SingleChildScrollView`; no fixed-height containers without overflow handling |
| **Operable** | All functionality via keyboard | Flutter focus traversal enabled by default; `NavigationRail` responds to arrow keys and Tab |
| **Operable** | Touch targets ≥ 48×48 dp | Material 3 default button/list-tile sizing |
| **Understandable** | Input validation with clear error messages | `TextFormField` validators return specific, human-readable error strings |
| **Understandable** | Consistent navigation | Same three-tab structure across all viewports |
| **Robust** | Compatible with assistive technologies | All dynamic content (date changes, search results) announced via `Semantics(liveRegion: true)`; custom paint diagram uses `Semantics(container: true, image: true)` wrapper |

### Theme & Contrast

| Setting | Default | Accessible Option |
|---|---|---|
| Light / Dark / System | System | User selectable in About tab |
| High Contrast | Off | `ColorScheme.fromSeed(contrastLevel: 1.0)` — maximum WCAG contrast ratio |

### Semantic Tree Summary

```
Semantics (AppShell)
├── NavigationRail / NavigationBar  [role: tablist]
├── HomeScreen
│   └── Menu cards [role: button]
├── SimulationScreen
│   ├── Date picker [button]
│   └── Form fields [textbox, helper text]
├── ResultsScreen
│   ├── Date navigation [liveRegion: current date]
│   └── Visual configuration diagram [container, image]
│       └── Label: "Mercury is X° east/west, Venus is Y° east/west…"
├── AngularDistancesScreen
│   └── PlanetDataCards × 2
│       └── PlanetDataRow × 7 [label: "Distance from Earth: 0.xxx A.U."]
├── NextElongationScreen
│   └── Search result [liveRegion]
├── InstructionsScreen [container, label]
└── AboutScreen
    └── RadioGroup [role: radiogroup] for calculation mode
```

---

## Project Structure

```
mercury&venus/
├── lib/
│   ├── main.dart                         → app entry, theme, Provider setup
│   ├── logic/
│   │   ├── astronomy_engine.dart         → HeritageCalculator + ModernCalculator + findNextElongation
│   │   └── settings_provider.dart        → SettingsProvider (mode, theme, high contrast)
│   ├── models/
│   │   └── models.dart                   → PlanetData
│   └── ui/
│       ├── app_shell.dart                → adaptive navigation shell
│       ├── home_screen.dart              → tool menu
│       ├── instructions_screen.dart      → combined user guide
│       ├── about_screen.dart             → credits + settings UI
│       ├── tools/
│       │   ├── simulation_screen.dart
│       │   ├── results_screen.dart
│       │   ├── angular_distances_screen.dart
│       │   └── next_elongation_screen.dart
│       └── widgets/
│           ├── data_row.dart
│           ├── planet_data_card.dart
│           └── visual_config_painter.dart
├── test/widget_test.dart
├── MERVE.BAS                             ← original source preserved
├── MVENC.BAS                             ← original source preserved
└── pubspec.yaml
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.5+1 | `ChangeNotifierProvider` for `SettingsProvider` |
| `intl` | ^0.20.3 | Date formatting (`DateFormat`) |
| `cupertino_icons` | ^1.0.8 | Material icon font |
| `flutter_lints` | ^6.0.0 | Static analysis rules |

The astronomy engines are implemented entirely from scratch with no third-party astronomy packages.

---

## Testing

| Test | Purpose |
|---|---|
| Renders the home menu | Smoke test verifying all three tool cards render |
| Modern calculator returns valid data | Asserts distances, illumination, phase for both planets are positive/valid |
| Heritage calculator returns finite results | Asserts heritage engine produces finite distances and valid phases |
| Next elongation search terminates | Asserts the iterative search for Mercury returns a date after the start date |
| SettingsProvider can switch mode | Asserts `setMode` updates the `mode` getter |

---

## Platform Runners

| Platform | Runner Technology | Key Files |
|---|---|---|
| Android | Kotlin, Gradle Kotlin DSL | `android/app/build.gradle.kts` |
| Web | Standard Flutter web | `web/index.html`, `web/manifest.json` |
| Linux | C++ / CMake | `linux/CMakeLists.txt` |
| Windows | C++ / CMake | `windows/CMakeLists.txt` |

---

## Future Enhancements

| Enhancement | Effort | Notes |
|---|---|---|
| Mars trajectory support | Medium | Extend `Planet` enum and add `_getMarsElements` |
| Internationalization (i18n) | High | Replace all hardcoded strings; `intl` already present as a dependency |
| Dark-mode color tuning for the diagram | Low | Make diagram colors configurable from theme rather than hardcoded |
| Persistent user preferences | Low | Add `shared_preferences` to save mode/theme/high-contrast across launches |
| Unit tests for `HeritageCalculator` | Low | Verify known date → known elongation values against the original BASIC output |