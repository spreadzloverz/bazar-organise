# BACKLOG — GPS NIMBUS

Dernière mise à jour : 2026-09-07

Par ordre d'utilité. Les statuts prouvés sont dans `docs/STATUS.md`.

## 1. Sécuriser la base actuelle

- [x] Isoler les corrections sur `gps-nimbus/hardening-v1`.
- [x] Interdire le déploiement du portfolio depuis une branche Claude.
- [x] Ajouter les niveaux `MOCKED / IMPLEMENTED / TESTED /
      DEVICE_TESTED / LIVE_DATA / PRODUCTION`.
- [x] Ajouter une CI sans déploiement : format, analyse, tests, build web.
- [x] Obtenir une CI verte sur la calibration et les corridors GOLDEN-001.
- [x] Ouvrir une pull request de revue en brouillon vers la branche Claude,
      jamais vers `main`.
- [ ] Conserver la pull request en brouillon jusqu'à la migration ; ne pas
      fusionner le projet GPS dans la branche principale du portfolio.

## 2. Migrer GPS NIMBUS hors du portfolio

- [ ] Créer le dépôt indépendant `spreadzloverz/gps-nimbus`.
- [ ] Y transférer `gps_nimbus/`, la documentation et la CI utile.
- [ ] Utiliser `main` pour la version stable et des branches courtes pour le
      développement.
- [ ] Construire le web avec GitHub Actions depuis la source.
- [ ] N'activer Pages qu'après validation de l'artefact et sans publier la
      racine du site Bazar Organisé.

La création du nouveau dépôt n'est pas disponible via le connecteur actuel.
Elle demandera une action humaine simple ou un environnement GitHub CLI
autorisé.

## 3. Transformer GOLDEN-001 en référence réelle

- [x] Documenter le trajet Alfortville → Issy sous identifiants anonymisés.
- [x] Modéliser les durées terrain et leur priorité.
- [x] Appliquer une observation compatible à un tronçon marche/skate.
- [x] Protéger un point d'accès explicite lorsqu'il existe dans le réseau.
- [x] Signaler un point explicite absent au lieu de le remplacer.
- [x] Ajouter au réseau de test Quai de la Gare, Pasteur, Mairie d'Issy,
      Ivry-sur-Seine, Issy–Val de Seine, métro 12 et RER C.
- [x] Tester la structure des variantes M6 + M12 et RER C avec les durées
      terrain anonymisées.
- [ ] Ajouter localement les détails de localisation nécessaires aux essais,
      sans les committer.
- [ ] Comparer les deux variantes avec vrais horaires, vrais accès de rue et
      une heure de départ donnée.

## 4. Données réelles de transport

- [ ] Importer le GTFS d'Île-de-France Mobilités.
- [ ] Remplacer les intervalles moyens par les horaires réels selon l'heure de
      départ déjà prévue dans `RouteRequest`.
- [ ] Ajouter les prochains passages et perturbations temps réel avec date de
      fraîcheur et source.
- [ ] Séparer `scheduledTime`, `expectedTime` et observation terrain.
- [ ] Décider du stockage local et de la fréquence de mise à jour.

## 5. Tracés de rues et recherche de lieux

- [ ] Remplacer « vol d'oiseau × facteur » par un vrai réseau de rues OSM.
- [ ] Ajouter un géocodage dont les conditions d'utilisation et quotas ont été
      vérifiés.
- [ ] Ajouter la position actuelle avec autorisation explicite de l'utilisateur.
- [ ] Ne jamais exposer de clé privée dans le JavaScript web.

## 6. Road Intelligence progressive

- [ ] Prévoir les champs source, fraîcheur, confiance et impact routing.
- [ ] Intégrer d'abord uniquement les fermetures certaines, perturbations
      datées et pentes fiables.
- [ ] Collecter surface, état de voirie, travaux et accidents comme données
      informatives avant de leur attribuer des coefficients.
- [ ] Calibrer les effets avec des mesures terrain ; ne pas inventer des
      multiplicateurs pseudo-scientifiques.

## 7. Builds et tests appareils

- [ ] Produire un APK Android dans un environnement disposant du SDK.
- [ ] Tester la version web sur un iPhone réel avec Safari et ajout à l'écran
      d'accueil.
- [ ] Vérifier le cache et la mise à jour de version PWA.
- [ ] Vérifier le build iOS sur Mac avec Xcode.
- [ ] Ne jamais appeler un test Chromium redimensionné `DEVICE_TESTED`.

## 8. Cartographie et confort

- [ ] Afficher une carte seulement lorsque les tracés réels existent.
- [ ] Ajouter vitesse skate/marche réglables dans l'interface.
- [ ] Ajouter la limite de distance skate déjà supportée par le moteur.
- [ ] Mémoriser les derniers trajets sans publier l'historique privé.

## Volontairement hors MVP

Compte utilisateur, paiement, publicité, tracking marketing, fonctions
sociales, IA embarquée, microservices et calcul batterie prétendument précis.
