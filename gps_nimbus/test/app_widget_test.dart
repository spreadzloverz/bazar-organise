import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/app.dart';
import 'package:gps_nimbus/core/places.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/domain/ranking/ranking_criteria.dart';
import 'package:gps_nimbus/routing/journey_planner.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';
import 'package:gps_nimbus/routing/routing_service.dart';
import 'package:gps_nimbus/ui/screens/results_screen.dart';
import 'package:gps_nimbus/ui/screens/route_detail_screen.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      GpsNimbusApp(
        planner: JourneyPlanner(routingService: MockRoutingService()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Saisit un lieu dans le champ à l'index donné (0 = départ, 1 = arrivée).
  Future<void> enterPlace(WidgetTester tester, int index, String label) async {
    final field = find.byType(TextField).at(index);
    await tester.tap(field);
    await tester.enterText(field, label);
    await tester.pumpAndSettle();
  }

  testWidgets('l\'accueil affiche les champs et les hypothèses de calcul', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('GPS NIMBUS'), findsOneWidget);
    expect(find.text('Départ'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('CALCULER'), findsOneWidget);
    expect(find.textContaining('27 km/h'), findsOneWidget);
    expect(find.textContaining('5 km/h'), findsOneWidget);
    expect(find.textContaining('fictif'), findsOneWidget);
  });

  testWidgets('la recherche ne part pas tant que les deux lieux manquent', (
    tester,
  ) async {
    await pumpApp(tester);

    // Aucun lieu saisi : le bouton ne déclenche rien.
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsNothing);

    // Un seul lieu saisi : toujours rien.
    await enterPlace(tester, 0, 'Châtelet');
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsNothing);

    // Les deux lieux saisis : la recherche part.
    await enterPlace(tester, 1, 'La Défense');
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);
  });

  testWidgets('une recherche affiche les deux classements obligatoires', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterPlace(tester, 0, 'Châtelet');
    await enterPlace(tester, 1, 'La Défense');

    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.text(RankingCriteria.fastest.title), findsOneWidget);
    expect(find.text(RankingCriteria.leastSkate.title), findsOneWidget);
    expect(find.text('Châtelet → La Défense'), findsOneWidget);
  });

  testWidgets('l\'écran de résultats signale les données fictives', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterPlace(tester, 0, 'Montparnasse');
    await enterPlace(tester, 1, 'Gare du Nord');
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    // Le bandeau d'avertissements est en bas de la liste des résultats.
    await tester.scrollUntilVisible(find.text('À SAVOIR'), 300);
    await tester.pumpAndSettle();

    expect(find.text('À SAVOIR'), findsOneWidget);
    expect(find.textContaining('fictif'), findsWidgets);
  });

  testWidgets('le détail d\'un trajet montre la séquence étape par étape', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterPlace(tester, 0, 'Châtelet');
    await enterPlace(tester, 1, 'La Défense');
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voir le détail').first);
    await tester.pumpAndSettle();

    expect(find.byType(RouteDetailScreen), findsOneWidget);
    expect(find.text('ÉTAPE PAR ÉTAPE'), findsOneWidget);
    expect(find.text('Temps en transport'), findsOneWidget);
    expect(find.text('Attente estimée'), findsOneWidget);
  });

  testWidgets('l\'inversion échange le départ et la destination', (
    tester,
  ) async {
    await pumpApp(tester);
    await enterPlace(tester, 0, 'Bastille');
    await enterPlace(tester, 1, 'Nation');

    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    expect(find.text('Nation → Bastille'), findsOneWidget);
  });

  testWidgets('les libellés de mode sont affichés en clair', (tester) async {
    // Vérifie que le vocabulaire produit apparaît bien à l'écran.
    await pumpApp(tester);
    await enterPlace(tester, 0, 'Bourg-la-Reine');
    await enterPlace(tester, 1, 'Étoile');
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    final modeLabels = [
      SegmentType.skate.shortLabel,
      SegmentType.rer.shortLabel,
    ];
    final found = modeLabels.any(
      (label) => find.textContaining(label).evaluate().isNotEmpty,
    );
    expect(found, isTrue);
  });

  test('tous les lieux de l\'accueil sont utilisables par le moteur', () async {
    final planner = JourneyPlanner(routingService: MockRoutingService());
    for (final place in Places.all) {
      final result = await planner.plan(
        RouteRequest(origin: Places.all.first, destination: place),
      );
      expect(result.isEmpty, isFalse, reason: 'échec pour ${place.label}');
    }
  });
}
