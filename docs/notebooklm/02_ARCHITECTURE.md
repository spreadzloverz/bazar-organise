# Architecture

Application Flutter en Dart, pour Android et iPhone.

## Quatre couches, une seule direction

1. **Interface** — les écrans.
2. **Domaine métier** — tronçons, itinéraires, profils de mobilité,
   classements. Ne connaît ni Flutter ni le réseau.
3. **Routing** — le réseau de transport, la recherche de chemin, le
   planificateur.
4. **Données** — les branchements vers OpenTripPlanner, GTFS et
   OpenStreetMap.

Chaque couche ne dépend que de celle du dessous. Le domaine est testable
seul, et il l'est : la plupart des tests ne lancent aucune interface.

## Les deux objets centraux

**Le tronçon** : un mode unique, un point de départ, un point d'arrivée, une
distance, une durée, éventuellement une ligne de transport.

**L'itinéraire** : une suite ordonnée de tronçons. Toutes les valeurs
affichées — durée, distances, correspondances — sont recalculées à partir
des tronçons. Aucune n'est stockée en double, donc le résumé ne peut jamais
contredire le détail.

## Le cas de la marche

Deux types distincts, dès le départ :
- la marche qui sert vraiment à se déplacer (du domicile à la station) ;
- la marche d'une correspondance (d'un quai à un autre).

Elles ont aujourd'hui la même vitesse, mais elles sont séparées pour pouvoir
recevoir des règles différentes plus tard.

## Le cas du skate

Une couche « politique d'accès » répond à « ce mode a-t-il le droit de
passer ici ? », séparément du profil qui répond à « à quelle vitesse ? ».

Cette séparation existe pour empêcher le skateboard électrique de devenir
un simple alias du vélo. Au MVP il emprunte les règles cyclables, mais cet
emprunt est isolé dans une seule classe, affiché à l'utilisateur, et
désactivable.
