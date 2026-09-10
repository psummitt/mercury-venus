import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/astronomy_engine.dart';
import '../../logic/settings_provider.dart';

/// Next Elongation tool (from the original MVENC program).
///
/// Iteratively searches forward from a chosen date to find the next maximum
/// angular separation of Mercury or Venus from the Sun.
class NextElongationScreen extends StatefulWidget {
  const NextElongationScreen({super.key});

  @override
  State<NextElongationScreen> createState() => _NextElongationScreenState();
}

class _NextElongationScreenState extends State<NextElongationScreen> {
  DateTime _startDate = DateTime.now();
  Planet _selectedPlanet = Planet.mercury;
  DateTime? _resultDate;
  bool _searching = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1800),
      lastDate: DateTime(2200),
      helpText: 'Search for elongation after this date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  void _runSearch() {
    setState(() {
      _searching = true;
      _resultDate = null;
    });

    // Run after a short delay so the loading indicator can render.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      final calculator = settings.calculator;
      final result = calculator.findNextElongation(
        startDate: _startDate,
        planet: _selectedPlanet,
      );
      setState(() {
        _resultDate = result;
        _searching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Elongation'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'When is Mercury or Venus next at its greatest '
                      'angular separation from the Sun?',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Planet>(
                    initialValue: _selectedPlanet,
                    decoration: const InputDecoration(
                      labelText: 'Planet',
                      border: OutlineInputBorder(),
                      helperText: 'Choose the planet to search for',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Planet.mercury,
                        child: Text('Mercury'),
                      ),
                      DropdownMenuItem(
                        value: Planet.venus,
                        child: Text('Venus'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPlanet = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Search after date'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_startDate),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: _searching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text(
                        'Calculate',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: _searching ? null : _runSearch,
                    ),
                  ),
                  if (_resultDate != null) ...[
                    const SizedBox(height: 48),
                    Semantics(
                      liveRegion: true,
                      container: true,
                      label:
                          'Next elongation for ${_selectedPlanet.name} found.',
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                'Next Elongation for ${_selectedPlanet.name}',
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(_resultDate!),
                                style: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Calculation mode: ${settings.modeLabel}',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Note: This is an approximate date produced '
                                'by an iterative search algorithm ported '
                                'from the original BASIC program.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}