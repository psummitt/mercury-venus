import 'package:flutter/material.dart';
import 'tools/simulation_screen.dart';
import 'tools/angular_distances_screen.dart';
import 'tools/next_elongation_screen.dart';

/// Home menu. Offers the three celestial tools inherited from the MERVE and
/// MVENC astronomy programs.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercury & Venus Astronomy'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Welcome',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a tool to calculate planetary positions, distances, '
                'phases, and elongations of Mercury and Venus.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              _MenuCard(
                title: 'Planetary Simulation',
                subtitle:
                    'Time series of positions, distances and phases across '
                    'a chosen range of dates',
                icon: Icons.timeline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SimulationScreen(),
                  ),
                ),
              ),
              _MenuCard(
                title: 'Angular Distances',
                subtitle:
                    'Positions, distances and phase for Mercury and Venus '
                    'on a single date',
                icon: Icons.calculate,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AngularDistancesScreen(),
                  ),
                ),
              ),
              _MenuCard(
                title: 'Next Elongation',
                subtitle:
                    'Find when Mercury or Venus is next at its maximum '
                    'angular separation from the Sun',
                icon: Icons.event,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NextElongationScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Icon(icon, size: 32, color: colorScheme.primary),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          minLeadingWidth: 40,
          onTap: onTap,
        ),
      ),
    );
  }
}