import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/astronomy_engine.dart';
import '../logic/settings_provider.dart';

/// Combined About screen from the MERVE and MVENC programs, and the single
/// place to configure calculation mode, theme and accessibility settings.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Scrollbar(
          child: SingleChildScrollView(
            primary: true,
            padding: const EdgeInsets.all(24.0),
            child: Consumer<SettingsProvider>(
              builder: (context, settings, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Icon(Icons.star, size: 64, color: Colors.amber),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'AN ASTRONOMY PROGRAM',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(child: Text('Mercury & Venus')),
                    const SizedBox(height: 8),
                    const Center(child: Text('(MERVE  ·  MVENC)')),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Original Author',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Eric Burgess F.R.A.S.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Heritage',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This combined application merges the MERVE '
                      '(JAN. 82 Version) and MVENC programs, originally '
                      'written in BASIC for Apple II / Commodore systems and '
                      'published by S & T Software Service. All rights to '
                      'the original programs reserved by their author and '
                      'publisher. The Flutter redesign preserves the logic '
                      'of the original source while adding modern '
                      'calculation modes and accessibility features.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Settings',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _SettingSection(
                      title: 'Calculation Engine',
                      subtitle:
                          'Choose the algorithm used for all calculations. '
                          'Modern (J2000) is recommended.',
                      child: RadioGroup<CalculationMode>(
                        groupValue: settings.mode,
                        onChanged: (CalculationMode? value) {
                          if (value != null) settings.setMode(value);
                        },
                        child: Column(
                          children: [
                            RadioListTile<CalculationMode>(
                              title: const Text('Modern (J2000)'),
                              subtitle: const Text(
                                'Keplerian elements and Newton–Raphson '
                                'solution for accurate current dates.',
                              ),
                              value: CalculationMode.modern,
                            ),
                            RadioListTile<CalculationMode>(
                              title: const Text('Heritage (1982)'),
                              subtitle: const Text(
                                'Strict replication of the original BASIC '
                                'formulas and 1960 epoch.',
                              ),
                              value: CalculationMode.heritage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingSection(
                      title: 'Theme',
                      subtitle:
                          'Choose a light, dark or system-following theme.',
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) =>
                            settings.setThemeMode(selection.first),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingSection(
                      title: 'High Contrast',
                      subtitle:
                          'Increase foreground/background contrast for '
                          'improved legibility.',
                      child: SwitchListTile(
                        title: const Text('High contrast colors'),
                        subtitle: const Text(
                          'Uses maximum contrast color schemes (WCAG AA+).',
                        ),
                        value: settings.highContrast,
                        onChanged: settings.setHighContrast,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Accessibility',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This application supports screen readers, high '
                      'contrast themes, keyboard navigation, system text '
                      'scaling and responsive layouts on Android, Linux, '
                      'Web and Windows.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Ported to Flutter: September 2026',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ],
    );
  }
}

