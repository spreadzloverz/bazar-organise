import '../domain/model/geo_point.dart';
import '../domain/model/segment_type.dart';
import '../domain/model/transit_line.dart';
import 'transit_network.dart';

/// Extrait FICTIF et simplifié du réseau francilien, destiné au MVP.
///
/// Les stations et leurs positions sont approximatives et le tracé des
/// lignes est volontairement réduit. Ces données ne remplacent pas les
/// données GTFS d'Île-de-France Mobilités : elles servent uniquement à
/// faire fonctionner et tester le moteur avant le branchement des sources
/// réelles. Toute réponse issue de ce réseau est signalée comme fictive.
class MockIdfNetwork {
  const MockIdfNetwork._();

  static const List<Station> _stations = [
    Station(
      id: 'la_defense',
      name: 'La Défense',
      position: GeoPoint(latitude: 48.8918, longitude: 2.238),
    ),
    Station(
      id: 'etoile',
      name: 'Charles de Gaulle–Étoile',
      position: GeoPoint(latitude: 48.8738, longitude: 2.295),
    ),
    Station(
      id: 'clemenceau',
      name: 'Champs-Élysées–Clemenceau',
      position: GeoPoint(latitude: 48.8676, longitude: 2.314),
    ),
    Station(
      id: 'concorde',
      name: 'Concorde',
      position: GeoPoint(latitude: 48.8656, longitude: 2.3212),
    ),
    Station(
      id: 'palais_royal',
      name: 'Palais Royal–Musée du Louvre',
      position: GeoPoint(latitude: 48.8622, longitude: 2.3364),
    ),
    Station(
      id: 'chatelet',
      name: 'Châtelet',
      position: GeoPoint(latitude: 48.8583, longitude: 2.347),
    ),
    Station(
      id: 'les_halles',
      name: 'Châtelet–Les Halles',
      position: GeoPoint(latitude: 48.8619, longitude: 2.3467),
    ),
    Station(
      id: 'hotel_de_ville',
      name: 'Hôtel de Ville',
      position: GeoPoint(latitude: 48.8574, longitude: 2.3522),
    ),
    Station(
      id: 'bastille',
      name: 'Bastille',
      position: GeoPoint(latitude: 48.8531, longitude: 2.3691),
    ),
    Station(
      id: 'nation',
      name: 'Nation',
      position: GeoPoint(latitude: 48.8484, longitude: 2.3958),
    ),
    Station(
      id: 'vincennes_metro',
      name: 'Château de Vincennes',
      position: GeoPoint(latitude: 48.8444, longitude: 2.4406),
    ),
    Station(
      id: 'clignancourt',
      name: 'Porte de Clignancourt',
      position: GeoPoint(latitude: 48.8975, longitude: 2.3444),
    ),
    Station(
      id: 'barbes',
      name: 'Barbès–Rochechouart',
      position: GeoPoint(latitude: 48.8834, longitude: 2.3494),
    ),
    Station(
      id: 'gare_du_nord',
      name: 'Gare du Nord',
      position: GeoPoint(latitude: 48.8809, longitude: 2.3553),
    ),
    Station(
      id: 'gare_de_lest',
      name: "Gare de l'Est",
      position: GeoPoint(latitude: 48.8768, longitude: 2.359),
    ),
    Station(
      id: 'saint_michel',
      name: 'Saint-Michel–Notre-Dame',
      position: GeoPoint(latitude: 48.8534, longitude: 2.344),
    ),
    Station(
      id: 'denfert',
      name: 'Denfert-Rochereau',
      position: GeoPoint(latitude: 48.8339, longitude: 2.3325),
    ),
    Station(
      id: 'montparnasse',
      name: 'Montparnasse–Bienvenüe',
      position: GeoPoint(latitude: 48.8434, longitude: 2.322),
    ),
    Station(
      id: 'porte_orleans',
      name: "Porte d'Orléans",
      position: GeoPoint(latitude: 48.8232, longitude: 2.3258),
    ),
    Station(
      id: 'mairie_montrouge',
      name: 'Mairie de Montrouge',
      position: GeoPoint(latitude: 48.8182, longitude: 2.32),
    ),
    Station(
      id: 'trocadero',
      name: 'Trocadéro',
      position: GeoPoint(latitude: 48.8631, longitude: 2.2872),
    ),
    Station(
      id: 'bir_hakeim',
      name: 'Bir-Hakeim',
      position: GeoPoint(latitude: 48.8538, longitude: 2.2892),
    ),
    Station(
      id: 'place_italie',
      name: "Place d'Italie",
      position: GeoPoint(latitude: 48.8311, longitude: 2.3556),
    ),
    Station(
      id: 'bercy',
      name: 'Bercy',
      position: GeoPoint(latitude: 48.84, longitude: 2.3793),
    ),
    Station(
      id: 'saint_germain',
      name: 'Saint-Germain-en-Laye',
      position: GeoPoint(latitude: 48.8977, longitude: 2.0946),
    ),
    Station(
      id: 'auber',
      name: 'Auber',
      position: GeoPoint(latitude: 48.8725, longitude: 2.33),
    ),
    Station(
      id: 'gare_de_lyon',
      name: 'Gare de Lyon',
      position: GeoPoint(latitude: 48.8443, longitude: 2.3743),
    ),
    Station(
      id: 'vincennes_rer',
      name: 'Vincennes',
      position: GeoPoint(latitude: 48.8474, longitude: 2.434),
    ),
    Station(
      id: 'val_de_fontenay',
      name: 'Val de Fontenay',
      position: GeoPoint(latitude: 48.8531, longitude: 2.4855),
    ),
    Station(
      id: 'marne_la_vallee',
      name: 'Marne-la-Vallée–Chessy',
      position: GeoPoint(latitude: 48.8712, longitude: 2.783),
    ),
    Station(
      id: 'cdg2',
      name: 'Aéroport Charles de Gaulle 2',
      position: GeoPoint(latitude: 49.0043, longitude: 2.571),
    ),
    Station(
      id: 'la_plaine',
      name: 'La Plaine–Stade de France',
      position: GeoPoint(latitude: 48.911, longitude: 2.36),
    ),
    Station(
      id: 'cite_universitaire',
      name: 'Cité Universitaire',
      position: GeoPoint(latitude: 48.8194, longitude: 2.3383),
    ),
    Station(
      id: 'bourg_la_reine',
      name: 'Bourg-la-Reine',
      position: GeoPoint(latitude: 48.7797, longitude: 2.3153),
    ),
    Station(
      id: 'massy_palaiseau',
      name: 'Massy-Palaiseau',
      position: GeoPoint(latitude: 48.7256, longitude: 2.2597),
    ),
    Station(
      id: 'garigliano',
      name: 'Pont du Garigliano',
      position: GeoPoint(latitude: 48.8386, longitude: 2.2726),
    ),
    Station(
      id: 'porte_versailles',
      name: 'Porte de Versailles',
      position: GeoPoint(latitude: 48.8322, longitude: 2.2874),
    ),
    Station(
      id: 'porte_italie',
      name: "Porte d'Italie",
      position: GeoPoint(latitude: 48.8188, longitude: 2.3596),
    ),
    Station(
      id: 'porte_charenton',
      name: 'Porte de Charenton',
      position: GeoPoint(latitude: 48.829, longitude: 2.3945),
    ),
    Station(
      id: 'puteaux',
      name: 'Puteaux',
      position: GeoPoint(latitude: 48.8836, longitude: 2.239),
    ),
    Station(
      id: 'issy',
      name: 'Issy–Val de Seine',
      position: GeoPoint(latitude: 48.8306, longitude: 2.2688),
    ),
    Station(
      id: 'austerlitz',
      name: "Gare d'Austerlitz",
      position: GeoPoint(latitude: 48.8422, longitude: 2.3652),
    ),
    Station(
      id: 'luxembourg',
      name: 'Luxembourg',
      position: GeoPoint(latitude: 48.8465, longitude: 2.34),
    ),
  ];

  static const List<LineRoute> _routes = [
    LineRoute(
      line: TransitLine(name: '1', mode: SegmentType.metro, operator: 'RATP'),
      stopIds: [
        'la_defense',
        'etoile',
        'clemenceau',
        'concorde',
        'palais_royal',
        'chatelet',
        'hotel_de_ville',
        'bastille',
        'nation',
        'vincennes_metro',
      ],
    ),
    LineRoute(
      line: TransitLine(name: '4', mode: SegmentType.metro, operator: 'RATP'),
      stopIds: [
        'clignancourt',
        'barbes',
        'gare_du_nord',
        'gare_de_lest',
        'chatelet',
        'saint_michel',
        'denfert',
        'montparnasse',
        'porte_orleans',
        'mairie_montrouge',
      ],
    ),
    LineRoute(
      line: TransitLine(name: '6', mode: SegmentType.metro, operator: 'RATP'),
      stopIds: [
        'etoile',
        'trocadero',
        'bir_hakeim',
        'montparnasse',
        'denfert',
        'place_italie',
        'bercy',
        'nation',
      ],
    ),
    LineRoute(
      line: TransitLine(name: 'A', mode: SegmentType.rer, operator: 'RATP'),
      stopIds: [
        'saint_germain',
        'la_defense',
        'etoile',
        'auber',
        'les_halles',
        'gare_de_lyon',
        'nation',
        'vincennes_rer',
        'val_de_fontenay',
        'marne_la_vallee',
      ],
    ),
    LineRoute(
      line: TransitLine(name: 'B', mode: SegmentType.rer, operator: 'RATP'),
      stopIds: [
        'cdg2',
        'la_plaine',
        'gare_du_nord',
        'les_halles',
        'saint_michel',
        'denfert',
        'cite_universitaire',
        'bourg_la_reine',
        'massy_palaiseau',
      ],
    ),
    LineRoute(
      line: TransitLine(name: 'T3a', mode: SegmentType.tram, operator: 'RATP'),
      stopIds: [
        'garigliano',
        'porte_versailles',
        'porte_orleans',
        'porte_italie',
        'porte_charenton',
      ],
    ),
    LineRoute(
      line: TransitLine(name: 'T2', mode: SegmentType.tram, operator: 'RATP'),
      stopIds: ['la_defense', 'puteaux', 'issy', 'porte_versailles'],
    ),
    LineRoute(
      line: TransitLine(name: '91', mode: SegmentType.bus, operator: 'RATP'),
      stopIds: ['montparnasse', 'austerlitz', 'gare_de_lyon', 'bastille'],
    ),
    LineRoute(
      line: TransitLine(name: '38', mode: SegmentType.bus, operator: 'RATP'),
      stopIds: [
        'gare_du_nord',
        'chatelet',
        'luxembourg',
        'denfert',
        'porte_orleans',
      ],
    ),
  ];

  /// Construit le réseau fictif.
  static TransitNetwork build() => TransitNetwork(
    stations: _stations,
    routes: _routes,
    isMockData: true,
    sourceLabel: 'Réseau francilien simplifié (données fictives)',
  );
}
