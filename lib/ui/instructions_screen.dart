import 'package:flutter/material.dart';
import 'tools/simulation_screen.dart';
import 'tools/angular_distances_screen.dart';
import 'tools/next_elongation_screen.dart';

/// Instructions screen combining the guidance from the original MERVE and
/// MVENC BASIC programs.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  void _openTool(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Semantics(
                label: 'Program instructions',
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'About the Program',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This combined application plots the positions of '
                      'Mercury and Venus relative to the Sun at intervals '
                      'chosen by you in units of days, for as many intervals '
                      'as you request. It also computes elongations, '
                      'distances from Earth in astronomical units and '
                      'millions of miles, apparent angular diameters, and '
                      'planetary phases. The program offers two tools:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _InstructionItem(
                      number: '1',
                      text: 'Angular Distances: calculates approximate '
                          'angular distances of Mercury and Venus from the '
                          'Sun, approximate distances from Earth, and '
                          'provides approximate angular diameter and phase '
                          'for any date.',
                      toolLabel: 'Open Angular Distances',
                      onTap: () => _openTool(context, const AngularDistancesScreen()),
                    ),
                    const SizedBox(height: 12),
                    _InstructionItem(
                      number: '2',
                      text: 'Next Elongation: provides the date of the next '
                          'elongation (maximum angular separation from the '
                          'Sun) of Mercury or Venus after any chosen date.',
                      toolLabel: 'Open Next Elongation',
                      onTap: () => _openTool(context, const NextElongationScreen()),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(
                        'How to Start',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Open the Planetary Simulation from the Home tab, '
                      'enter a starting date, an interval in days, and the '
                      'number of data points, then press Generate Results. '
                      'Navigate between dates with the arrows, and read each '
                      'planet\'s data in its card.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(
                        'Notes on Calculation Modes',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Modern (J2000): the default mode, uses updated '
                      'Keplerian orbital elements for best accuracy across '
                      'the supported date range.\n\n'
                      'Heritage (1982): faithfully reproduces the original '
                      'BASIC formulas and 1960 epoch used by Eric '
                      'Burgess F.R.A.S. for historical authenticity.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(
                        'Accessibility',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Every chart and form control exposes semantic '
                      'labels for screen readers. Results announce '
                      'themselves automatically, layouts re-flow for '
                      'narrow screens and large text, and a high-contrast '
                      'theme can be enabled from the About tab.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _openTool(context, const SimulationScreen()),
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text('Start Calculating'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String number;
  final String text;
  final String toolLabel;
  final VoidCallback onTap;

  const _InstructionItem({
    required this.number,
    required this.text,
    required this.toolLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Alternative $number',
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 14,
              child: Text(
                number,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(toolLabel),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}