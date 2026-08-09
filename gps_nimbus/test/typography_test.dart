import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/app.dart';
import 'package:gps_nimbus/routing/journey_planner.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';

/// GPS NIMBUS embarque sa police. Un `TextStyle` écrit à la main n'hérite
/// pas de `ThemeData.fontFamily` : son texte retombe alors sur la police
/// par défaut du moteur, qui n'est pas garantie — sur le web, elle est
/// téléchargée chez un tiers, et le texte disparaît si ce tiers est
/// injoignable.
///
/// Ces tests vérifient qu'aucun texte affiché ne se retrouve sans police.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      GpsNimbusApp(
        planner: JourneyPlanner(routingService: MockRoutingService()),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Police réellement appliquée à un widget `Text`, une fois fusionnés
  /// le style local et le style hérité.
  String? resolvedFontFamily(WidgetTester tester, Element element) {
    final text = element.widget as Text;
    final inherited = DefaultTextStyle.of(element).style;
    final effective = text.style == null
        ? inherited
        : (text.style!.inherit ? inherited.merge(text.style) : text.style!);
    return effective.fontFamily;
  }

  void expectEveryTextHasFont(WidgetTester tester) {
    final sansPolice = <String>[];
    for (final element in find.byType(Text).evaluate()) {
      final family = resolvedFontFamily(tester, element);
      if (family == null) {
        sansPolice.add('« ${(element.widget as Text).data ?? ''} »');
      }
    }
    expect(
      sansPolice,
      isEmpty,
      reason:
          'ces textes n\'ont aucune police déclarée et deviendraient '
          'invisibles si la police par défaut du moteur est absente : '
          '${sansPolice.join(', ')}',
    );
  }

  testWidgets('le thème déclare la police embarquée', (tester) async {
    await pumpApp(tester);
    final context = tester.element(find.text('GPS NIMBUS'));
    expect(
      Theme.of(context).textTheme.bodyMedium?.fontFamily,
      NimbusTheme.fontFamily,
    );
  });

  testWidgets('tous les textes de l\'accueil ont une police', (tester) async {
    await pumpApp(tester);
    expectEveryTextHasFont(tester);
  });

  testWidgets('le libellé du bouton Calculer a une police', (tester) async {
    await pumpApp(tester);
    final bouton = find.text('CALCULER');
    expect(bouton, findsOneWidget);
    expect(
      resolvedFontFamily(tester, bouton.evaluate().single),
      NimbusTheme.fontFamily,
    );
  });

  testWidgets('tous les textes des résultats ont une police', (tester) async {
    await pumpApp(tester);

    final champs = find.byType(TextField);
    await tester.enterText(champs.at(0), 'Châtelet');
    await tester.pumpAndSettle();
    await tester.enterText(champs.at(1), 'La Défense');
    await tester.pumpAndSettle();

    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    expectEveryTextHasFont(tester);
  });

  testWidgets('tous les textes du détail d\'un trajet ont une police', (
    tester,
  ) async {
    await pumpApp(tester);

    final champs = find.byType(TextField);
    await tester.enterText(champs.at(0), 'Montparnasse');
    await tester.pumpAndSettle();
    await tester.enterText(champs.at(1), 'Gare du Nord');
    await tester.pumpAndSettle();
    await tester.tap(find.text('CALCULER'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voir le détail').first);
    await tester.pumpAndSettle();

    expectEveryTextHasFont(tester);
  });
}
