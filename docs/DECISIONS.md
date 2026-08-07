# DECISIONS — GPS NIMBUS

Uniquement les décisions structurantes. Les choix locaux (noms, découpage
de widgets, organisation d'un fichier) ne sont pas documentés ici.

---

DECISION: Placer l'application dans `gps_nimbus/` à la racine du dépôt
CONTEXT: Le dépôt contient déjà le site web Bazar Organise (HTML, images,
  scripts). GPS NIMBUS est un projet différent.
OPTIONS: (a) nouveau dépôt ; (b) sous-dossier du dépôt existant ;
  (c) mélanger à la racine.
CHOICE: (b) sous-dossier `gps_nimbus/`.
WHY: Aucun fichier du site n'est touché, aucune permission ni création de
  dépôt n'est nécessaire, et tout reste dans une seule branche de travail.
REVERSIBLE: Oui — déplacer le dossier suffit.

---

DECISION: Gestion d'état avec `StatefulWidget` et `setState`
CONTEXT: L'application a un écran de saisie et deux écrans de lecture.
OPTIONS: Provider, Riverpod, BLoC, ou rien du tout.
CHOICE: Rien — `setState`.
WHY: Aucun état partagé entre écrans, aucune synchronisation complexe.
  Une bibliothèque de gestion d'état ajouterait une dépendance et du
  vocabulaire sans résoudre de problème existant. Le moteur, lui, est déjà
  isolé de l'interface, donc l'ajout d'une telle bibliothèque plus tard ne
  touchera pas la logique métier.
REVERSIBLE: Oui — l'interface est mince et le domaine n'en dépend pas.

---

DECISION: Zéro dépendance externe au-delà du SDK Flutter
CONTEXT: Un moteur d'itinéraires pourrait s'appuyer sur des paquets de
  géométrie, de file de priorité, de HTTP, de cartographie.
OPTIONS: Ajouter les paquets utiles maintenant, ou n'ajouter que le
  nécessaire.
CHOICE: Aucune dépendance pour l'instant.
WHY: La distance de haversine fait dix lignes. Le réseau du MVP est assez
  petit pour qu'une file de priorité naïve soit largement suffisante.
  Aucun appel réseau n'existe encore. Moins de dépendances = moins de
  risques de compatibilité Android/iOS et de licence.
REVERSIBLE: Oui. La cartographie (`flutter_map` ou équivalent) sera une
  vraie décision au moment de la Phase 7.

---

DECISION: Le graphe de transport a pour nœuds des couples (station, ligne)
CONTEXT: Il faut produire des itinéraires qui distinguent l'attente, le
  trajet à bord et les correspondances.
OPTIONS: (a) graphe de stations avec pénalité forfaitaire de
  correspondance ; (b) graphe (station × ligne).
CHOICE: (b).
WHY: Avec (a), on ne sait pas quelle ligne est empruntée ni quand un
  changement de véhicule a lieu — donc on ne peut ni compter honnêtement
  les correspondances, ni afficher la séquence réelle du trajet, qui sont
  deux exigences produit. (b) les fait tomber naturellement.
REVERSIBLE: Oui, mais sans intérêt : (b) est un sur-ensemble de (a).

---

DECISION: La pénalité d'embarquement oriente le choix mais n'est pas
  annoncée à l'utilisateur
CONTEXT: Sans pénalité, le moteur propose des itinéraires théoriquement
  rapides mais avec des correspondances absurdes.
OPTIONS: (a) ajouter la pénalité à la durée affichée ; (b) l'utiliser
  seulement pendant la recherche.
CHOICE: (b).
WHY: La durée annoncée doit être la somme exacte des tronçons réels.
  Gonfler la durée affichée pour exprimer une préférence reviendrait à
  mentir sur le temps de trajet.
REVERSIBLE: Oui — un paramètre unique dans `findTransitSegments`.

---

DECISION: Le profil skate emprunte temporairement les règles cyclables
CONTEXT: Il n'existe pas de données de voirie spécifiques aux engins de
  déplacement personnel motorisés en Île-de-France.
OPTIONS: (a) traiter le skate comme un vélo ; (b) inventer des règles ;
  (c) bloquer le développement en attendant de vraies données.
CHOICE: (a), mais isolé et signalé.
WHY: (c) empêcherait de construire le MVP ; (b) serait malhonnête. Le
  proxy est confiné à `SkateAccessPolicy`, exposé par `isProxy`, affiché
  à l'utilisateur via `proxyNotice`, et désactivable par un paramètre.
  Le skate ne devient donc pas un alias permanent du vélo : c'est un
  emprunt daté et visible.
REVERSIBLE: Oui — une seule classe à remplacer.

---

DECISION: Un réseau francilien fictif et simplifié pour le MVP
CONTEXT: Le GTFS d'Île-de-France Mobilités est volumineux, se met à jour
  régulièrement, et n'a pas encore été importé.
OPTIONS: (a) attendre le GTFS ; (b) réseau réduit écrit à la main ;
  (c) inventer des réponses d'API.
CHOICE: (b).
WHY: (c) est interdit par les règles du projet. (a) bloquerait tout. Un
  réseau de 43 stations et 9 lignes suffit à exercer toutes les
  combinaisons de modes et tous les cas de classement. Le calcul reste
  réel ; seules les données sont approximatives, et l'application le dit.
REVERSIBLE: Oui — `TransitNetworkSource` permet de fournir un autre réseau
  sans toucher au moteur.

---

DECISION: Distances estimées à vol d'oiseau × 1,25 en attendant OSM
CONTEXT: Aucun tracé de rue n'est disponible.
OPTIONS: (a) distance à vol d'oiseau brute ; (b) facteur de détour ;
  (c) attendre OSM.
CHOICE: (b), avec un facteur unique et documenté.
WHY: La distance brute sous-estime systématiquement les trajets urbains.
  Un facteur unique est grossier mais honnête, et l'écart est signalé à
  l'utilisateur. Il est remplacé dès qu'un vrai calcul de chemin existe.
REVERSIBLE: Oui — une constante et une méthode.

---

DECISION: Départage final des classements par identifiant d'itinéraire
CONTEXT: `List.sort` n'est pas stable en Dart : à égalité stricte, l'ordre
  des résultats pouvait changer d'un appel à l'autre.
OPTIONS: (a) accepter l'instabilité ; (b) trier avec un dernier critère
  déterministe.
CHOICE: (b).
WHY: Une recommandation qui change sans raison entre deux recherches
  identiques est un défaut visible par l'utilisateur, et rend les tests
  fragiles.
REVERSIBLE: Oui.
