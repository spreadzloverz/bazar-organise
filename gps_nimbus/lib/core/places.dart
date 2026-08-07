import '../domain/model/geo_point.dart';

/// Lieux franciliens pré-enregistrés, utilisés par l'écran d'accueil et par
/// le harnais de test en ligne de commande.
///
/// Ce n'est pas un géocodeur : c'est une liste courte et lisible qui permet
/// d'utiliser l'application avant le branchement d'une vraie recherche
/// d'adresses.
class Places {
  const Places._();

  static const List<GeoPoint> all = [
    GeoPoint(latitude: 48.8583, longitude: 2.3470, label: 'Châtelet'),
    GeoPoint(latitude: 48.8738, longitude: 2.2950, label: 'Étoile'),
    GeoPoint(latitude: 48.8918, longitude: 2.2380, label: 'La Défense'),
    GeoPoint(latitude: 48.8809, longitude: 2.3553, label: 'Gare du Nord'),
    GeoPoint(latitude: 48.8443, longitude: 2.3743, label: 'Gare de Lyon'),
    GeoPoint(latitude: 48.8434, longitude: 2.3220, label: 'Montparnasse'),
    GeoPoint(latitude: 48.8339, longitude: 2.3325, label: 'Denfert-Rochereau'),
    GeoPoint(latitude: 48.8531, longitude: 2.3691, label: 'Bastille'),
    GeoPoint(latitude: 48.8484, longitude: 2.3958, label: 'Nation'),
    GeoPoint(latitude: 48.8232, longitude: 2.3258, label: "Porte d'Orléans"),
    GeoPoint(
      latitude: 48.8322,
      longitude: 2.2874,
      label: 'Porte de Versailles',
    ),
    GeoPoint(latitude: 48.8311, longitude: 2.3556, label: "Place d'Italie"),
    GeoPoint(latitude: 48.8686, longitude: 2.3630, label: 'République'),
    GeoPoint(latitude: 48.8656, longitude: 2.3212, label: 'Concorde'),
    GeoPoint(latitude: 48.8867, longitude: 2.3431, label: 'Pigalle'),
    GeoPoint(latitude: 48.8462, longitude: 2.4269, label: 'Vincennes'),
    GeoPoint(latitude: 48.8145, longitude: 2.3540, label: 'Le Kremlin-Bicêtre'),
    GeoPoint(latitude: 48.9034, longitude: 2.3060, label: 'Clichy'),
    GeoPoint(
      latitude: 48.8306,
      longitude: 2.2688,
      label: 'Issy-les-Moulineaux',
    ),
    GeoPoint(latitude: 48.7797, longitude: 2.3153, label: 'Bourg-la-Reine'),
  ];

  /// Recherche insensible à la casse et aux accents simples.
  static List<GeoPoint> search(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return all;
    return all
        .where((place) => _normalize(place.label).contains(needle))
        .toList(growable: false);
  }

  /// Correspondance exacte sur le nom, sinon `null`.
  static GeoPoint? byLabel(String label) {
    final needle = _normalize(label);
    for (final place in all) {
      if (_normalize(place.label) == needle) return place;
    }
    return null;
  }

  static String _normalize(String value) {
    const accents = 'àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
    const plain = 'aaaeeeeiioouuucAAAEEEEIIOOUUUC';
    final buffer = StringBuffer();
    for (final rune in value.trim().toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = accents.indexOf(char);
      buffer.write(index >= 0 ? plain[index].toLowerCase() : char);
    }
    return buffer.toString();
  }
}
