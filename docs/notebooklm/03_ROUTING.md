# Comment un trajet est calculé

## Le réseau

Un réseau de transport = des stations, des lignes, et des liaisons à pied
entre stations proches. Le réseau du MVP est écrit à la main : 43 stations,
9 lignes (métro 1, 4, 6 — RER A, B — tram T2, T3a — bus 38, 91).

Chaque mode a une vitesse commerciale et un intervalle de passage moyens :
métro 25 km/h toutes les 4 min, RER 45 km/h toutes les 7 min, tram 18 km/h
toutes les 6 min, bus 12 km/h toutes les 10 min. Ce sont des hypothèses de
service, pas des règles produit : les horaires GTFS les remplaceront.

## La recherche de chemin

Le moteur travaille sur un graphe dont chaque nœud est un couple
**(station, ligne à bord)**, et non une simple station.

Ce détail a des conséquences directes :
- monter dans un véhicule coûte l'attente moyenne, ce qui produit un vrai
  tronçon d'attente ;
- changer de ligne fait forcément passer par « à pied sur le quai », ce qui
  produit une correspondance identifiable ;
- on sait toujours quelle ligne est empruntée, donc la séquence affichée
  est exacte.

Les arrêts successifs d'une même ligne sont fusionnés en un seul tronçon
lisible.

Une pénalité s'applique à chaque embarquement pour écarter les itinéraires
rapides sur le papier mais pénibles en vrai. Elle oriente le choix mais
n'est jamais ajoutée à la durée annoncée : le temps affiché reste la somme
exacte des tronçons.

## Les itinéraires proposés

Pour chaque recherche, le moteur construit :
- la marche seule (si ce n'est pas absurde) ;
- le skate seul ;
- pour chaque station d'embarquement et de descente proche, les quatre
  combinaisons accès/sortie : marche ou skate de chaque côté.

Les doublons sont supprimés, puis les deux classements font le tri.

## Les classements

**PLUS RAPIDE** : durée totale, puis correspondances, puis distance skate,
puis distance à pied.

**MOINS DE SKATE** : distance skate, puis durée totale, puis
correspondances, puis distance à pied.

Un dernier départage garantit qu'à données identiques le résultat ne change
jamais d'une recherche à l'autre.
