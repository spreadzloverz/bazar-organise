import 'package:flutter/material.dart';

import '../../core/route_formatting.dart';
import '../../domain/model/route_option.dart';
import '../../domain/ranking/ranking_criteria.dart';
import 'segment_visuals.dart';

/// Carte de recommandation : « PLUS RAPIDE » ou « MOINS DE SKATE ».
class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.criteria,
    required this.route,
    required this.onTap,
    this.alsoBestFor,
  });

  final RankingCriteria criteria;
  final RouteOption route;
  final VoidCallback onTap;

  /// Renseigné quand ce même itinéraire gagne aussi l'autre classement.
  final RankingCriteria? alsoBestFor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      criteria.title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    RouteFormatting.duration(route.totalDuration),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                criteria.explanation,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (alsoBestFor != null) ...[
                const SizedBox(height: 6),
                Text(
                  'C\'est aussi le meilleur choix « ${alsoBestFor!.title} ».',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              RouteSequence(route: route),
              const SizedBox(height: 14),
              RouteMetrics(route: route),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir le détail',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Séquence visuelle du trajet : SKATE → RER → MARCHE.
class RouteSequence extends StatelessWidget {
  const RouteSequence({super.key, required this.route, this.showLines = true});

  final RouteOption route;
  final bool showLines;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final segment in route.segments) {
      if (segment.type.isWaiting) continue;
      final lineName = showLines ? segment.line?.name : null;
      if (chips.isNotEmpty) {
        chips.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.arrow_forward, size: 14),
          ),
        );
      }
      chips.add(ModeChip(type: segment.type, lineName: lineName));
    }

    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }
}

/// Chiffres clés d'un itinéraire.
class RouteMetrics extends StatelessWidget {
  const RouteMetrics({super.key, required this.route});

  final RouteOption route;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      children: [
        _Metric(
          icon: Icons.skateboarding,
          label: 'Skate',
          value: RouteFormatting.distance(route.skateDistanceMeters),
        ),
        _Metric(
          icon: Icons.directions_walk,
          label: 'Marche',
          value: RouteFormatting.distance(route.walkDistanceMeters),
        ),
        _Metric(
          icon: Icons.route,
          label: 'Total',
          value: RouteFormatting.distance(route.totalDistanceMeters),
        ),
        _Metric(
          icon: Icons.swap_horiz,
          label: 'Transports',
          value: route.transitLegCount == 0
              ? 'aucun'
              : '${route.transitLegCount} · '
                    '${RouteFormatting.transfers(route.transferCount)}',
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
