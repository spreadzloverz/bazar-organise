import 'package:flutter/material.dart';

import '../../core/config/mobility_config.dart';
import '../../domain/model/geo_point.dart';
import '../../routing/journey_planner.dart';
import '../../routing/routing_service.dart';
import '../widgets/place_field.dart';
import 'results_screen.dart';

/// Écran d'accueil : départ, destination, bouton Calculer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.planner});

  final JourneyPlanner planner;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GeoPoint? _origin;
  GeoPoint? _destination;
  bool _searching = false;
  String? _error;

  bool get _canSearch => _origin != null && _destination != null && !_searching;

  Future<void> _search() async {
    if (!_canSearch) return;
    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final result = await widget.planner.plan(
        RouteRequest(
          origin: _origin!,
          destination: _destination!,
          config: MobilityConfig.defaults,
        ),
      );
      if (!mounted) return;
      if (result.isEmpty) {
        setState(
          () => _error =
              'Aucun itinéraire trouvé entre ces deux points. '
              'Essayez deux lieux plus proches.',
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            origin: _origin!,
            destination: _destination!,
            result: result,
          ),
        ),
      );
    } on RoutingUnavailable catch (e) {
      if (mounted) setState(() => _error = e.reason);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _swap() {
    setState(() {
      final previous = _origin;
      _origin = _destination;
      _destination = previous;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GPS NIMBUS',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Skate électrique et transports en Île-de-France',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              PlaceField(
                label: 'Départ',
                icon: Icons.trip_origin,
                selected: _origin,
                onChanged: (place) => setState(() => _origin = place),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filledTonal(
                  tooltip: 'Inverser départ et destination',
                  onPressed: _swap,
                  icon: const Icon(Icons.swap_vert),
                ),
              ),
              const SizedBox(height: 8),
              PlaceField(
                label: 'Destination',
                icon: Icons.flag_outlined,
                selected: _destination,
                onChanged: (place) => setState(() => _destination = place),
              ),

              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _canSearch ? _search : null,
                icon: _searching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_searching ? 'CALCUL EN COURS…' : 'CALCULER'),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _error!),
              ],

              const SizedBox(height: 32),
              const _MobilityFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rappel honnête des hypothèses de calcul.
class _MobilityFooter extends StatelessWidget {
  const _MobilityFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const config = MobilityConfig.defaults;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hypothèses de calcul',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Skateboard électrique : '
            '${config.skateSpeedKmh.toStringAsFixed(0)} km/h en moyenne\n'
            '• Marche : ${config.walkingSpeedKmh.toStringAsFixed(0)} km/h\n'
            '• Réseau de transport simplifié et fictif : les horaires réels '
            'ne sont pas encore branchés.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
