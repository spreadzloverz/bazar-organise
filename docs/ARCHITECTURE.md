# Architecture — GPS NIMBUS

## Principe

Une seule direction de dépendance, de haut en bas :

```
UI                lib/ui        écrans et widgets Flutter
   ↓
DOMAINE MÉTIER    lib/domain    tronçons, itinéraires, profils, classements
   ↓
ROUTING           lib/routing   réseau, recherche de chemin, planificateur
   ↓
DONNÉES           lib/data      OTP, GTFS, OSM (interfaces, non branchées)
```

Le domaine ne connaît ni Flutter ni le réseau. Il est testable seul, et il
l'est : la majorité des tests ne lancent aucune interface.

## Le modèle

### `RouteSegment`
Un tronçon élémentaire : un mode unique, une origine, une destination, une
distance, une durée, éventuellement une ligne, et des informations libres.

Types (`SegmentType`) :
`walkingRoute`, `transferWalk`, `skate`, `metro`, `rer`, `tram`, `bus`,
`waiting`.

La marche est volontairement scindée en deux :
- `walkingRoute` : marche de déplacement réel (domicile → station) ;
- `transferWalk` : marche interne à une correspondance (quai → quai).

Elles ont aujourd'hui la même vitesse, mais des réglages distincts existent
déjà dans `MobilityConfig` pour pouvoir les différencier plus tard.

### `RouteOption`
Une suite ordonnée de tronçons. **Toutes** les grandeurs affichées sont
calculées à partir des tronçons — durée totale, distance totale, distance
skate, distance marche, temps de transport, temps d'attente, nombre de
transports, nombre de correspondances, séquence.

Aucune valeur n'est stockée en double : impossible qu'un résumé contredise
le détail du trajet.

Une correspondance = un changement de véhicule. Trois transports enchaînés
font deux correspondances.

## Les profils de mobilité

```
DONNÉES DE VOIRIE
      ↓
POLITIQUE D'ACCÈS      lib/domain/profile/access_policy.dart
      ↓
PROFIL DE MOBILITÉ     lib/domain/profile/mobility_profile.dart
      ↓
ROUTING
```

La **politique d'accès** répond à « ce mode a-t-il le droit de passer ici ? ».
Le **profil** répond à « à quelle vitesse, et quel tronçon cela produit-il ? ».

Cette séparation existe pour une raison précise : **le skateboard électrique
ne doit pas devenir un alias permanent du vélo**. Au MVP, `SkateAccessPolicy`
s'inspire de l'infrastructure cyclable faute de données spécifiques aux
engins de déplacement personnel motorisés. Ce choix est :

- explicite (`isProxy == true`) ;
- isolé dans une seule classe ;
- affiché à l'utilisateur (`proxyNotice`) ;
- désactivable (`SkateAccessPolicy(useBicycleProxy: false)`).

## Le classement

`lib/domain/ranking/` contient les deux critères produit et rien d'autre.

**PLUS RAPIDE** : durée totale → correspondances → distance skate →
distance marche → identifiant.

**MOINS DE SKATE** : distance skate → durée totale → correspondances →
distance marche → identifiant.

Le dernier départage par identifiant rend le classement déterministe : à
données égales, le résultat ne change jamais d'un appel à l'autre.

Les distances sont comparées à 1 mètre près : une différence plus fine n'a
aucun sens sur un trajet réel.

## Le routing

### `TransitNetwork`
Stations, lignes, liaisons à pied entre stations proches. Sait aussi
déclarer s'il est fictif (`isMockData`).

### Recherche de chemin
Dijkstra sur un graphe dont les nœuds sont des couples
**(station, ligne à bord)**. Cela permet de produire naturellement :

- l'attente à l'embarquement (moitié de l'intervalle de passage) ;
- la correspondance à pied entre deux stations proches ;
- des tronçons fusionnés quand plusieurs arrêts se suivent sur une ligne.

Une pénalité s'applique à chaque embarquement, pour éviter les itinéraires
théoriquement rapides mais pénibles. Cette pénalité oriente le choix ;
elle **n'est pas ajoutée** à la durée annoncée.

### `MockRoutingService`
Construit les itinéraires candidats : marche seule, skate seul, puis toutes
les combinaisons accès/sortie (marche ou skate) × stations d'embarquement et
de descente les plus proches. Le classement fait ensuite le tri.

Le **calcul** est réel. Seules les **données** de réseau sont fictives, et
l'application le dit.

### `JourneyPlanner`
Le seul point d'entrée que l'interface connaît : il appelle une source
d'itinéraires puis applique les classements. Changer de source ne change
rien aux écrans.

## Les données

`lib/data/` ne contient que des interfaces et l'état réel de chaque source.
Règle absolue : **aucune API réelle n'est simulée**. Une source non
configurée lève `RoutingUnavailable` ou `UnsupportedError` avec la liste
de ce qui manque — elle ne renvoie jamais de données inventées.

Voir `lib/data/README.md`.

## L'interface

Flutter, Material 3, thème clair et sombre.

- `HomeScreen` — départ, destination, Calculer, hypothèses de calcul
- `ResultsScreen` — les deux recommandations, puis les autres itinéraires
- `RouteDetailScreen` — chiffres clés et séquence étape par étape

État géré avec `StatefulWidget` et `setState`. Aucune bibliothèque de
gestion d'état : l'application n'a qu'un écran de saisie et deux écrans de
lecture. Voir `docs/DECISIONS.md`.

## Les tests

- `test/mobility_profile_test.dart` — invariants de vitesse, durées, accès
- `test/route_option_test.dart` — agrégats d'un itinéraire
- `test/ranking_test.dart` — les deux classements et tous leurs départages
- `test/routing_engine_test.dart` — cohérence du moteur, combinaisons de modes
- `test/app_widget_test.dart` — parcours utilisateur complet

`tool/nimbus_cli.dart` permet d'exercer le moteur sans interface graphique.
