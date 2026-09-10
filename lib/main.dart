import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/settings_provider.dart';
import 'ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MercuryVenusApp(),
    ),
  );
}

class MercuryVenusApp extends StatelessWidget {
  const MercuryVenusApp({super.key});

  ThemeData _buildTheme(Brightness brightness, bool highContrast) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: brightness,
        contrastLevel: highContrast ? 1.0 : 0.0,
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 2),
      navigationRailTheme: const NavigationRailThemeData(
        labelType: NavigationRailLabelType.all,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Mercury & Venus Astronomy',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: _buildTheme(Brightness.light, settings.highContrast),
          darkTheme: _buildTheme(Brightness.dark, settings.highContrast),
          home: const AppShell(),
        );
      },
    );
  }
}