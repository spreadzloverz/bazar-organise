# BACKLOG — GPS NIMBUS

Par ordre d'utilité. Ce qui est fait est dans `docs/STATUS.md`.

## 1. Rendre l'application accessible

- [x] Version web utilisable depuis un iPhone (`nimbus/`).
- [ ] Mettre cette version web en ligne : activer GitHub Pages.
      Étapes dans `docs/STATUS.md`.
- [ ] Produire un APK Android. Bloqué ici par la politique réseau de
      l'environnement (`dl.google.com` inaccessible). Étapes pour
      l'utilisateur dans `docs/STATUS.md`.
- [ ] Vérifier le build iOS natif. Nécessite un Mac avec Xcode.
- [ ] Icône et écran de lancement aux couleurs de GPS NIMBUS — y compris
      l'icône affichée quand la version web est ajoutée à l'écran d'accueil.
- [ ] Alléger le premier chargement web (aujourd'hui ~15 Mo de moteur
      graphique). Piste : la compilation WebAssembly de Flutter.

## 2. Données réelles de transport

- [ ] Importer le GTFS d'Île-de-France Mobilités
      (`GtfsNetworkSource`, aujourd'hui non implémenté).
      Fichiers attendus : `stops.txt`, `routes.txt`, `trips.txt`,
      `stop_times.txt`, `calendar.txt`.
- [ ] Remplacer les intervalles moyens par de vrais horaires : l'attente
      dépendra alors de l'heure de départ, déjà prévue dans `RouteRequest`.
- [ ] Décider du stockage local du réseau (taille, mise à jour).
      → décision de niveau B à documenter le moment venu.

## 3. Tracés de rues réels

- [ ] Brancher OpenStreetMap (`OsmStreetNetworkSource`) pour remplacer
      l'estimation « vol d'oiseau × 1,25 ».
- [ ] Faire consommer les vraies catégories de voies par les politiques
      d'accès marche et skate.

## 4. Profil skate spécifique

- [ ] Remplacer le proxy cyclable par de vraies règles de circulation des
      engins de déplacement personnel motorisés.
- [ ] Retirer l'avertissement « estimé à partir des données cyclables »
      une fois que c'est fait — et pas avant.
- [ ] Étudier pentes et revêtement, qui comptent beaucoup en skate.

## 5. Cartographie

- [ ] Afficher le trajet sur une carte dans l'écran de détail.
      → choix de la bibliothèque = décision de niveau B, à documenter.
      À ne faire qu'une fois les tracés réels disponibles : une carte sans
      tracé réel afficherait des lignes droites trompeuses.

## 6. Recherche de lieux

- [ ] Remplacer le catalogue de 20 lieux par une vraie recherche
      d'adresses. Vérifier d'abord les conditions d'utilisation et si une
      clé d'API est nécessaire → si oui, c'est une décision utilisateur.
- [ ] Position actuelle comme point de départ (demande une autorisation
      de géolocalisation sur Android et iOS).

## 7. Confort d'usage

- [ ] Mémoriser les derniers trajets recherchés.
- [ ] Réglages : vitesse skate et vitesse de marche personnelles
      (`MobilityConfig` le permet déjà, il manque l'écran).
- [ ] Limite de distance skate choisie par l'utilisateur
      (`maxSkateDistanceMeters` est déjà pris en compte par le moteur).

## Volontairement hors du MVP

Compte utilisateur, authentification, Firebase, paiement, abonnement,
publicité, tracking, fonctions sociales, backend, IA embarquée.

Aucun de ces éléments n'est nécessaire pour calculer un trajet.
