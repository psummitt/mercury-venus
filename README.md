# Mercury & Venus Astronomy

A combined, accessible Flutter application for calculating the positions, phases, distances, and elongations of **Mercury** and **Venus**. Merges the **MERVE** (Mercury and Venus) and **MVENC** (Inner Planets Elongations) programs by **Eric Burgess F.R.A.S.**, originally published by S & T Software Service for Apple II / Commodore BASIC systems.

---

## Features

| Tool | Description |
|---|---|
| **Planetary Simulation** | Generate a time series of positions, distances, phases and a visual configuration diagram for Mercury and Venus across any range of dates |
| **Angular Distances** | View elongation, distance from Earth, angular diameter and phase for both planets on a single date |
| **Next Elongation** | Find the next date at which Mercury or Venus reaches maximum angular separation from the Sun |
| **Dual Calculation Modes** | Modern (J2000) for best accuracy; Heritage (1982) for faithful BASIC-era results |

---

## Platforms

| Platform | Status |
|---|---|
| Android | Supported |
| Linux | Supported |
| Web | Supported |
| Windows | Supported |

---

## Getting Started

### Prerequisites
- Flutter 3.13.2 or later (`flutter --version` to check)
- Dart SDK 3.13.2+

### Install & Run
```bash
cd mercury&venus
flutter pub get
flutter run                   # default platform
flutter run -d chrome         # web
flutter run -d linux          # Linux
flutter run -d windows        # Windows
flutter run -d android        # Android
```

### Build a Release
```bash
flutter build apk             # Android APK
flutter build web             # Web (static files)
flutter build linux           # Linux
flutter build windows         # Windows
```

### Run Tests
```bash
flutter test
```

---

## Project Structure

```
mercury&venus/
├── lib/
│   ├── main.dart                         # App entry, theming, Provider setup
│   ├── logic/
│   │   ├── astronomy_engine.dart         # HeritageCalculator, ModernCalculator, findNextElongation
│   │   └── settings_provider.dart        # Calculation mode, theme, high contrast settings
│   ├── models/
│   │   └── models.dart                   # PlanetData class
│   └── ui/
│       ├── app_shell.dart                # Adaptive NavigationRail / NavigationBar
│       ├── home_screen.dart              # Tool selection menu
│       ├── instructions_screen.dart      # Combined user guide
│       ├── about_screen.dart             # Credits + calculation mode / theme / accessibility settings
│       ├── tools/
│       │   ├── simulation_screen.dart    # Simulation parameter form
│       │   ├── results_screen.dart       # Time-series results with visual configuration diagram
│       │   ├── angular_distances_screen.dart  # Single-date planet data view
│       │   └── next_elongation_screen.dart    # Elongation date finder
│       └── widgets/
│           ├── data_row.dart             # Accessible labeled key-value row
│           ├── planet_data_card.dart     # Planet data display card
│           └── visual_config_painter.dart # CustomPaint Sun/Mercury/Venus diagram
├── test/
│   └── widget_test.dart                  # Smoke, domain, and settings tests
├── android/                              # Android platform runner (Kotlin)
├── web/                                  # Web platform runner
├── linux/                                # Linux platform runner (C++ / CMake)
├── windows/                              # Windows platform runner (C++ / CMake)
├── MERVE.BAS                             # Original MERVE BASIC source (preserved)
├── MVENC.BAS                             # Original MVENC BASIC source (preserved)
└── pubspec.yaml
```

---

## Accessibility

This application was built to meet WCAG 2.1 AA principles and Flutter accessibility best practices:

| Requirement | Implementation |
|---|---|
| **Screen readers** | Every form, button, and result card exposes semantic labels via Flutter `Semantics` widgets; the visual configuration diagram includes a full plain-text description read automatically by screen readers |
| **Dynamic result announcements** | Date changes and elongation search results are announced live via `Semantics(liveRegion: true)` |
| **Keyboard / switch navigation** | All interactive widgets receive focus via Flutter's built-in focus traversal; NavigationRail is fully keyboard-navigable on desktop |
| **Text scaling** | No hardcoded text scale factors; all layouts are wrapped in `SingleChildScrollView` to prevent overflow at large font sizes |
| **High-contrast theme** | A toggle in the About tab switches `ColorScheme.fromSeed` to `contrastLevel: 1.0` for maximum foreground/background contrast |
| **Light / dark / system themes** | Three-way theme selector; respects the operating system's preferred color scheme by default |
| **Touch target sizes** | All buttons and interactive elements meet the 48×48 dp minimum via Material 3 defaults |
| **Decorative icons** | Purely visual planet icons are hidden from assistive technologies with `ExcludeSemantics` |
| **Monospace data values** | Numeric results use `fontFamily: 'monospace'` for improved readability and character alignment |
| **Meaningful form helpers** | Every input field includes `helperText` and `validator` messages to guide screen reader and sighted users alike |

---

## Credits

- **Original programs**: MERVE (JAN. 82 Version) and MVENC by **Eric Burgess F.R.A.S.**
- **Publisher**: S & T Software Service (1982)
- **Original BASIC sources**: `MERVE.BAS` and `MVENC.BAS` (preserved in this repository)
- **Flutter redesign**: September 2026

---

## License

This project preserves and extends the original astronomy programs for educational and accessibility purposes. All original program logic is credited to its author and publisher. See the About screen within the application for full heritage information.