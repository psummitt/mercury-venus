import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'results_screen.dart';

/// Planetary Simulation input form (from the original MERVE program).
///
/// The user chooses a starting date, an interval in days, and how many data
/// points to generate. Results open in [ResultsScreen].
class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _intervalController =
      TextEditingController(text: '1');
  final TextEditingController _countController = TextEditingController(text: '1');
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Select the starting date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final count = int.tryParse(_countController.text) ?? 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          startDate: _startDate,
          intervalDays: interval,
          count: count,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planetary Simulation'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Enter Simulation Parameters',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose a starting date, an interval between '
                      'calculation points in days, and the number of data '
                      'points to generate. The app then plots the positions '
                      'of Mercury and Venus relative to the Sun at each '
                      'selected date.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      button: true,
                      child: ListTile(
                        title: const Text('Starting Date'),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd').format(_startDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _intervalController,
                      decoration: const InputDecoration(
                        labelText: 'Interval in Days',
                        border: OutlineInputBorder(),
                        helperText: 'Days between each calculation point',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a positive whole number of days.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _countController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Data Points',
                        border: OutlineInputBorder(),
                        helperText: 'How many data points to generate',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0 || parsed > 1000) {
                          return 'Enter a positive whole number (max 1000).';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(
                          'Generate Results',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
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