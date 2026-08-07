import 'package:flutter/material.dart';

import '../../core/route_formatting.dart';
import '../../domain/model/route_option.dart';
import '../../domain/model/route_segment.dart';
import '../widgets/route_card.dart';
import '../widgets/segment_visuals.dart';
import 'results_screen.dart';

/// Détail d'un itinéraire : chiffres clés puis séquence complète des
/// tronçons, du départ à l'arrivée.
class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({
    super.key,
    required this.route,
    this.notices = const <String>[],
  });

  final RouteOption route;
  final List<String> notices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail du trajet')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    RouteFormatting.duration(route.totalDuration),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'porte à porte, attente et correspondances comprises',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RouteSequence(route: route),
                  const SizedBox(height: 16),
                  RouteMetrics(route: route),
                  const Divider(height: 28),
                  _DetailRow(
                    label: 'Temps en transport',
                    value: RouteFormatting.duration(route.transitDuration),
                  ),
                  _DetailRow(
                    label: 'Temps en skate',
                    value: RouteFormatting.duration(route.skateDuration),
                  ),
                  _DetailRow(
                    label: 'Temps à pied',
                    value: RouteFormatting.duration(route.walkDuration),
                  ),
                  _DetailRow(
                    label: 'Attente estimée',
                    value: RouteFormatting.duration(route.waitingDuration),
                  ),
                  if (route.lineNames.isNotEmpty)
                    _DetailRow(
                      label: 'Lignes empruntées',
                      value: route.lineNames.join(', '),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'ÉTAPE PAR ÉTAPE',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < route.segments.length; i++)
            _SegmentTile(
              segment: route.segments[i],
              isLast: i == route.segments.length - 1,
            ),

          const SizedBox(height: 16),
          NoticesPanel(notices: notices),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Une étape du trajet, avec la ligne verticale de progression.
class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.segment, required this.isLast});

  final RouteSegment segment;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = SegmentVisuals.color(segment.type);
    final title = segment.line?.displayName ?? segment.type.longLabel;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Icon(
                  SegmentVisuals.icon(segment.type),
                  size: 18,
                  color: color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        RouteFormatting.duration(segment.duration),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    segment.type.isWaiting
                        ? 'À ${segment.origin.label}'
                        : '${segment.origin.label} → ${segment.destination.label}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (segment.distanceMeters > 0)
                    Text(
                      RouteFormatting.distance(segment.distanceMeters),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (segment.details['proxyNotice'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        segment.details['proxyNotice']! as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
