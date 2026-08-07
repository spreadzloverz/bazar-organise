// Harnais de test en ligne de commande.
//
// Permet d'exercer tout le moteur GPS NIMBUS sans lancer l'application
// graphique, ni émulateur, ni téléphone.
//
//   dart run tool/nimbus_cli.dart --list
//   dart run tool/nimbus_cli.dart "Châtelet" "La Défense"
//   dart run tool/nimbus_cli.dart "Châtelet" "La Défense" --all
//   dart run tool/nimbus_cli.dart --scenarios

import 'dart:io';

import 'package:gps_nimbus/core/config/mobility_config.dart';
import 'package:gps_nimbus/core/places.dart';
import 'package:gps_nimbus/core/route_formatting.dart';
import 'package:gps_nimbus/domain/model/route_option.dart';
import 'package:gps_nimbus/domain/ranking/ranking_criteria.dart';
import 'package:gps_nimbus/routing/journey_planner.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';
import 'package:gps_nimbus/routing/routing_service.dart';

/// Trajets de référence, un par combinaison de modes attendue au MVP.
const scenarios = <List<String>>[
  ['Châtelet', 'Bastille'],
  ['Châtelet', 'La Défense'],
  ['Montparnasse', 'Gare du Nord'],
  ['Denfert-Rochereau', "Porte d'Orléans"],
  ['Issy-les-Moulineaux', 'Nation'],
  ['Bourg-la-Reine', 'Étoile'],
  ['Porte de Versailles', 'Vincennes'],
];

Future<void> main(List<String> args) async {
  if (args.contains('--list')) {
    stdout.writeln('Lieux disponibles :');
    for (final place in Places.all) {
      stdout.writeln('  - ${place.label}');
    }
    return;
  }

  final planner = JourneyPlanner(routingService: MockRoutingService());
  final showAll = args.contains('--all');

  if (args.isEmpty || args.contains('--scenarios')) {
    for (final scenario in scenarios) {
      await _run(planner, scenario[0], scenario[1], showAll: showAll);
    }
    return;
  }

  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.length != 2) {
    stderr.writeln(
      'Usage : dart run tool/nimbus_cli.dart "<départ>" "<arrivée>" [--all]',
    );
    exitCode = 64;
    return;
  }
  await _run(planner, positional[0], positional[1], showAll: showAll);
}

Future<void> _run(
  JourneyPlanner planner,
  String from,
  String to, {
  required bool showAll,
}) async {
  final origin = Places.byLabel(from);
  final destination = Places.byLabel(to);
  if (origin == null || destination == null) {
    stderr.writeln('Lieu inconnu : ${origin == null ? from : to}');
    stderr.writeln('Utilisez --list pour voir les lieux disponibles.');
    exitCode = 64;
    return;
  }

  stdout.writeln('');
  stdout.writeln('═' * 78);
  stdout.writeln('$from → $to');
  stdout.writeln('═' * 78);

  final result = await planner.plan(
    RouteRequest(
      origin: origin,
      destination: destination,
      config: MobilityConfig.defaults,
    ),
  );

  if (result.isEmpty) {
    stdout.writeln('Aucun itinéraire trouvé.');
    return;
  }

  stdout.writeln('${result.ranked.all.length} itinéraires calculés.');
  for (final criteria in RankingCriteria.values) {
    final best = result.ranked.best(criteria);
    if (best == null) continue;
    stdout.writeln('');
    stdout.writeln('▸ ${criteria.title}  (${criteria.explanation})');
    _printRoute(best);
  }

  if (showAll) {
    stdout.writeln('');
    stdout.writeln('— Tous les itinéraires, du plus rapide au plus lent —');
    for (final route in result.ranked.ranked(RankingCriteria.fastest)) {
      stdout.writeln('  ${RouteFormatting.summary(route)}');
    }
  }

  stdout.writeln('');
  for (final notice in result.notices) {
    stdout.writeln('  ⚠ $notice');
  }
}

void _printRoute(RouteOption route) {
  stdout.writeln(
    '  Durée totale      : ${RouteFormatting.duration(route.totalDuration)}',
  );
  stdout.writeln(
    '  Distance totale   : ${RouteFormatting.distance(route.totalDistanceMeters)}',
  );
  stdout.writeln(
    '  Distance skate    : ${RouteFormatting.distance(route.skateDistanceMeters)}',
  );
  stdout.writeln(
    '  Distance marche   : ${RouteFormatting.distance(route.walkDistanceMeters)}',
  );
  stdout.writeln(
    '  Transports        : ${route.transitLegCount} '
    '(${RouteFormatting.transfers(route.transferCount)})',
  );
  stdout.writeln(
    '  Temps en transport: ${RouteFormatting.duration(route.transitDuration)}',
  );
  stdout.writeln(
    '  Attente           : ${RouteFormatting.duration(route.waitingDuration)}',
  );
  stdout.writeln('  Séquence          : ${route.sequenceLabel}');
  stdout.writeln('  Détail :');
  for (final segment in route.segments) {
    stdout.writeln('    · ${RouteFormatting.segment(segment)}');
  }
}
