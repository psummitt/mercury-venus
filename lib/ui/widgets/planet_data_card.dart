import 'package:flutter/material.dart';
import '../../logic/astronomy_engine.dart';
import '../../models/models.dart';
import 'data_row.dart';

/// Card that presents the computed data for a single planet. Reused by the
/// Simulation and Angular Distances screens.
class PlanetDataCard extends StatelessWidget {
  final PlanetData data;

  const PlanetDataCard({super.key, required this.data});

  double _formatLength(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  @override
  Widget build(BuildContext context) {
    final isMercury = data.planet == Planet.mercury;
    final planetColor = isMercury ? Colors.orange : Colors.amber;

    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Semantics(
          label: data.planet.name,
          child: ExcludeSemantics(
            child: Icon(
              isMercury ? Icons.circle : Icons.circle_outlined,
              color: planetColor,
              size: 28,
            ),
          ),
        ),
        title: Text(
          data.planet.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Phase: ${data.phaseName} '
          '(${data.illumination.toStringAsFixed(1)}% illuminated)',
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                PlanetDataRow(
                  label: 'Distance from Earth',
                  value: '${data.distanceEarth.toStringAsFixed(4)} A.U.',
                ),
                PlanetDataRow(
                  label: 'Distance from Earth (Millions of Miles)',
                  value: '${_formatLength(data.distanceEarthMiles)} MI',
                ),
                PlanetDataRow(
                  label: 'Distance from Sun',
                  value: '${data.distanceSun.toStringAsFixed(4)} A.U.',
                ),
                PlanetDataRow(
                  label: 'Angular Distance from Sun',
                  value:
                      '${data.angularDistFromSun.toStringAsFixed(2)}°\n'
                      '${data.positionRelativeToSun}',
                ),
                PlanetDataRow(
                  label: 'Apparent Angular Diameter',
                  value: '${data.angularDiameter.toStringAsFixed(2)} arcsec',
                ),
                PlanetDataRow(
                  label: 'Phase Illumination',
                  value: '${data.illumination.toStringAsFixed(1)}%',
                ),
                if (isMercury && data.viewingFavorability.isNotEmpty)
                  PlanetDataRow(
                    label: 'Mercury Viewing Favorability',
                    value: data.viewingFavorability,
                    highlight: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
