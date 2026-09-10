import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/astronomy_engine.dart';
import '../../logic/settings_provider.dart';
import '../widgets/planet_data_card.dart';

/// Angular Distances tool (from the original MVENC program).
///
/// For any chosen date, computes and displays elongation, distance from
/// Earth, angular diameter and phase for both Mercury and Venus.
class AngularDistancesScreen extends StatefulWidget {
  const AngularDistancesScreen({super.key});

  @override
  State<AngularDistancesScreen> createState() => _AngularDistancesScreenState();
}

class _AngularDistancesScreenState extends State<AngularDistancesScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
      helpText: 'Select a date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final calculator = settings.calculator;
    final mercury = calculator.calculate(_selectedDate, Planet.mercury);
    final venus = calculator.calculate(_selectedDate, Planet.venus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Angular Distances'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  Semantics(
                    button: true,
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PlanetDataCard(data: mercury),
                  const SizedBox(height: 16),
                  PlanetDataCard(data: venus),
                  const SizedBox(height: 24),
                  Text(
                    'Calculation mode: ${settings.modeLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Negative elongation angles indicate the planet is East '
                    'of the Sun (an Evening Star).',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}