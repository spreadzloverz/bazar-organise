import 'package:flutter/material.dart';

import 'routing/journey_planner.dart';
import 'routing/mock_routing_service.dart';
import 'ui/screens/home_screen.dart';

/// Racine de l'application.
///
/// Le moteur est construit ici, une seule fois, et injecté dans l'écran
/// d'accueil : c'est le seul endroit à modifier pour passer du moteur
/// fictif à un moteur réel.
class GpsNimbusApp extends StatelessWidget {
  const GpsNimbusApp({super.key, JourneyPlanner? planner})
    : _injectedPlanner = planner;

  final JourneyPlanner? _injectedPlanner;

  @override
  Widget build(BuildContext context) {
    final planner =
        _injectedPlanner ??
        JourneyPlanner(routingService: MockRoutingService());

    return MaterialApp(
      title: 'GPS NIMBUS',
      debugShowCheckedModeBanner: false,
      theme: NimbusTheme.light,
      darkTheme: NimbusTheme.dark,
      themeMode: ThemeMode.system,
      home: HomeScreen(planner: planner),
    );
  }
}

/// Thème visuel de GPS NIMBUS.
class NimbusTheme {
  const NimbusTheme._();

  static const Color accent = Color(0xFF00C2A8);
  static const Color skateColor = Color(0xFFFF7A29);
  static const Color walkColor = Color(0xFF4C9AFF);
  static const Color transitColor = Color(0xFF9B7BFF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
