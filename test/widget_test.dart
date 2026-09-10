import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mercury_venus/main.dart';
import 'package:mercury_venus/logic/astronomy_engine.dart';
import 'package:mercury_venus/logic/settings_provider.dart';

Widget _wrapWithProvider(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ],
    child: child,
  );
}

void main() {
  testWidgets('Renders the home menu', (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProvider(const MercuryVenusApp()));

    expect(find.text('Planetary Simulation'), findsOneWidget);
    expect(find.text('Angular Distances'), findsOneWidget);
    expect(find.text('Next Elongation'), findsOneWidget);
  });

  testWidgets('Modern calculator returns valid data for today',
      (WidgetTester tester) async {
    final modern = ModernCalculator();
    for (final planet in [Planet.mercury, Planet.venus]) {
      final m = modern.calculate(DateTime.now(), planet);
      expect(m.distanceEarth, greaterThan(0.0));
      expect(m.angularDiameter, greaterThan(0.0));
      expect(m.illumination, greaterThanOrEqualTo(0.0));
      expect(m.illumination, lessThanOrEqualTo(100.0));
      expect(m.phaseName, isNotEmpty);
      expect(m.distanceEarthMiles, greaterThan(0.0));
    }
  });

  testWidgets('Heritage calculator returns finite results',
      (WidgetTester tester) async {
    final heritage = HeritageCalculator();
    for (final planet in [Planet.mercury, Planet.venus]) {
      final h = heritage.calculate(DateTime.now(), planet);
      expect(h.distanceEarth, greaterThan(0.0));
      expect(h.angularDiameter, greaterThan(0.0));
      expect(h.phaseName, isNotEmpty);
    }
  });

  testWidgets('Next elongation search terminates for Mercury',
      (WidgetTester tester) async {
    final calculator = ModernCalculator();
    final result = calculator.findNextElongation(
      startDate: DateTime(2026, 1, 1),
      planet: Planet.mercury,
    );
    expect(result.isAfter(DateTime(2026, 1, 1)), isTrue);
  });

  testWidgets('SettingsProvider can switch calculation mode',
      (WidgetTester tester) async {
    final settings = SettingsProvider();
    expect(settings.mode, CalculationMode.modern);
    settings.setMode(CalculationMode.heritage);
    expect(settings.mode, CalculationMode.heritage);
  });
}