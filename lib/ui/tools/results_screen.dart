import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/astronomy_engine.dart';
import '../../logic/settings_provider.dart';
import '../../models/models.dart';
import '../widgets/visual_config_painter.dart';
import '../widgets/planet_data_card.dart';

/// Time-series results for the Planetary Simulation. Shows, for each
/// generated date, a visual configuration diagram plus detailed data cards
/// for Mercury and Venus. The selected date is changed with the previous /
/// next arrows.
class ResultsScreen extends StatefulWidget {
  final DateTime startDate;
  final int intervalDays;
  final int count;

  const ResultsScreen({
    super.key,
    required this.startDate,
    required this.intervalDays,
    required this.count,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late List<DateTime> _dates;
  int _currentDateIndex = 0;

  @override
  void initState() {
    super.initState();
    _dates = List.generate(
      widget.count,
      (i) => DateTime(
        widget.startDate.year,
        widget.startDate.month,
        widget.startDate.day + i * widget.intervalDays,
      ),
    );
  }

  // Describes the elongation diagram in plain language for screen readers.
  String _describeConfig(PlanetData mercury, PlanetData venus) {
    String describe(PlanetData data) {
      final side = data.angularDistFromSun < 0 ? 'East' : 'West';
      return '${data.planet.name} is ${data.angularDistFromSun.abs().toStringAsFixed(1)}'
          ' degrees to the $side of the Sun, appearing as an '
          '${data.positionRelativeToSun.toLowerCase()}';
    }

    return 'Diagram of the Sun and planets for '
        '${DateFormat('yyyy-MM-dd').format(_dates[_currentDateIndex])}. '
        '${describe(mercury)}. ${describe(venus)}.';
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final calculator = settings.calculator;
    final currentDate = _dates[_currentDateIndex];

    final mercuryData = calculator.calculate(currentDate, Planet.mercury);
    final venusData = calculator.calculate(currentDate, Planet.venus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation Results'),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                primary: true,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        _buildVisualConfig(mercuryData, venusData),
                        const SizedBox(height: 24),
                        PlanetDataCard(data: mercuryData),
                        const SizedBox(height: 16),
                        PlanetDataCard(data: venusData),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colorScheme.surfaceContainerHighest,
      child: Semantics(
        liveRegion: true,
        label: 'Currently displaying '
            '${DateFormat('yyyy-MM-dd').format(_dates[_currentDateIndex])}',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Previous date',
              onPressed: _currentDateIndex > 0
                  ? () => setState(() => _currentDateIndex--)
                  : null,
            ),
            Text(
              'Date ${_currentDateIndex + 1} of ${_dates.length}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(_dates[_currentDateIndex]),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: 'Next date',
              onPressed: _currentDateIndex < _dates.length - 1
                  ? () => setState(() => _currentDateIndex++)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualConfig(PlanetData mercury, PlanetData venus) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Visual Configuration Relative to Sun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              container: true,
              label: _describeConfig(mercury, venus),
              image: true,
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: VisualConfigPainter(
                    mercuryElongation: mercury.angularDistFromSun,
                    venusElongation: venus.angularDistFromSun,
                    sunColor: Colors.yellow,
                    mercuryColor: Colors.orange,
                    venusColor: Colors.amber,
                    axisColor: scheme.outlineVariant,
                    labelColor: scheme.onSurface,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('West elongation (Morning sky)'),
                  Text('East elongation (Evening sky)'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'M = Mercury   V = Venus   S = Sun',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}