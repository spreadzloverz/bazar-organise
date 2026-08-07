import 'package:flutter/material.dart';

import '../../core/route_formatting.dart';
import '../../domain/model/geo_point.dart';
import '../../domain/model/route_option.dart';
import '../../domain/ranking/ranking_criteria.dart';
import '../../routing/journey_planner.dart';
import '../widgets/route_card.dart';
import 'route_detail_screen.dart';

/// Écran de résultats : les deux recommandations obligatoires, puis la
/// liste complète des itinéraires calculés.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.result,
  });

  final GeoPoint origin;
  final GeoPoint destination;
  final JourneyResult result;

  void _openDetail(BuildContext context, RouteOption route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RouteDetailScreen(route: route, notices: result.notices),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = result.ranked;
    final fastest = ranked.fastest;
    final leastSkate = ranked.leastSkate;
    final singleRecommendation = ranked.recommendationsAreIdentical;

    final others = ranked
        .ranked(RankingCriteria.fastest)
        .where((r) => !_isSame(r, fastest) && !_isSame(r, leastSkate))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${origin.label} → ${destination.label}'),
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (fastest != null)
            RouteCard(
              criteria: RankingCriteria.fastest,
              route: fastest,
              alsoBestFor: singleRecommendation
                  ? RankingCriteria.leastSkate
                  : null,
              onTap: () => _openDetail(context, fastest),
            ),
          if (leastSkate != null && !singleRecommendation) ...[
            const SizedBox(height: 12),
            RouteCard(
              criteria: RankingCriteria.leastSkate,
              route: leastSkate,
              onTap: () => _openDetail(context, leastSkate),
            ),
          ],

          if (others.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'AUTRES ITINÉRAIRES (${others.length})',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            for (final route in others)
              _CompactRouteTile(
                route: route,
                onTap: () => _openDetail(context, route),
              ),
          ],

          const SizedBox(height: 24),
          NoticesPanel(notices: result.notices),
        ],
      ),
    );
  }

  /// Compare deux itinéraires par identifiant, en tolérant `null`.
  static bool _isSame(RouteOption? a, RouteOption? b) =>
      a != null && b != null && a.id == b.id;
}

class _CompactRouteTile extends StatelessWidget {
  const _CompactRouteTile({required this.route, required this.onTap});

  final RouteOption route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: RouteSequence(route: route)),
                  const SizedBox(width: 8),
                  Text(
                    RouteFormatting.duration(route.totalDuration),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Skate ${RouteFormatting.distance(route.skateDistanceMeters)}'
                ' · marche ${RouteFormatting.distance(route.walkDistanceMeters)}'
                ' · ${RouteFormatting.transfers(route.transferCount)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avertissements affichés tels quels : aucune fonctionnalité n'est
/// présentée comme plus réelle qu'elle ne l'est.
class NoticesPanel extends StatelessWidget {
  const NoticesPanel({super.key, required this.notices});

  final List<String> notices;

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'À SAVOIR',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final notice in notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $notice',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
