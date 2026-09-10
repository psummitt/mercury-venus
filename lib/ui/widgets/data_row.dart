import 'package:flutter/material.dart';

/// A single labeled value pair inside a results card. The whole row is
/// wrapped in [Semantics] so screen readers announce "label: value" together.
class PlanetDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const PlanetDataRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: highlight ? colorScheme.tertiary : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}