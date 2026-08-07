# Adaptateurs de données

Ce dossier contient les **points de branchement** vers les sources réelles.

Règle absolue du projet : **aucune API réelle n'est simulée ici.**
Tant qu'une source n'est pas branchée, son adaptateur :

1. expose l'interface définie dans `lib/routing/routing_service.dart` ;
2. déclare honnêtement qu'il n'est pas configuré (`isConfigured == false`) ;
3. lève `RoutingUnavailable` plutôt que de renvoyer des données inventées ;
4. laisse le moteur fictif (`MockRoutingService`) prendre le relais.

| Dossier | Source visée | État |
|---------|--------------|------|
| `otp/` | OpenTripPlanner (calcul multimodal) | interface prête, serveur non configuré |
| `gtfs/` | GTFS Île-de-France Mobilités (horaires, lignes, arrêts) | interface prête, jeu de données non importé |
| `osm/` | OpenStreetMap (tracé des rues pour marche et skate) | interface prête, source non configurée |

Ce qu'il manque pour passer au réel est listé dans `docs/BACKLOG.md`
et dans `docs/notebooklm/05_SOURCES.md`.
