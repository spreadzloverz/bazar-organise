import '../../routing/transit_network.dart';

/// Origine d'un réseau de transport chargeable par le moteur.
///
/// Le moteur ne sait pas d'où viennent les données : il reçoit un
/// [TransitNetwork]. Remplacer le réseau fictif par le réseau réel
/// consiste donc à fournir une autre implémentation de cette interface.
abstract class TransitNetworkSource {
  String get name;

  /// Vrai lorsque la source dispose de tout ce qu'il lui faut.
  bool get isConfigured;

  /// Description de ce qu'il manque quand [isConfigured] est faux.
  String get missingRequirement;

  Future<TransitNetwork> load();
}

/// Chargement du réseau depuis un jeu de données GTFS.
///
/// Cible : le GTFS d'Île-de-France Mobilités (lignes, arrêts, horaires).
/// Le fichier n'est pas embarqué dans le dépôt : il est volumineux et se
/// met à jour régulièrement.
class GtfsNetworkSource implements TransitNetworkSource {
  const GtfsNetworkSource({this.datasetPath});

  /// Chemin local vers le jeu de données GTFS décompressé.
  final String? datasetPath;

  @override
  String get name => 'gtfs-idfm';

  @override
  bool get isConfigured => (datasetPath ?? '').trim().isNotEmpty;

  @override
  String get missingRequirement =>
      'Le jeu de données GTFS d\'Île-de-France Mobilités doit être '
      'téléchargé et son chemin renseigné. Fichiers attendus : stops.txt, '
      'routes.txt, trips.txt, stop_times.txt, calendar.txt.';

  @override
  Future<TransitNetwork> load() {
    throw UnsupportedError(
      'Import GTFS non implémenté. $missingRequirement '
      'Tant que ce n\'est pas fait, le réseau fictif reste utilisé et '
      'l\'application le signale à l\'utilisateur.',
    );
  }
}
