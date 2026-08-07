# STATUS — GPS NIMBUS

Dernière mise à jour : 2026-08-07

## État actuel

Le cœur de GPS NIMBUS fonctionne et est testé. L'application Flutter tourne
sur le moteur réel, avec un réseau de transport fictif clairement signalé.

**76 tests passent. `flutter analyze` ne relève aucun problème.**

## Terminé

**Moteur métier**
- Tronçons (`RouteSegment`) : marche de déplacement, marche de
  correspondance, skate, métro, RER, tram, bus, attente.
- Itinéraires (`RouteOption`) : durée totale, distance totale, distance
  skate, distance marche, temps de transport, attente, nombre de
  transports, nombre de correspondances, séquence lisible.
- Profils de mobilité : skate 27 km/h, marche 5 km/h, configurables.
- Politique d'accès séparée du profil, pour que le skate ne devienne pas
  un alias permanent du vélo.

**Classements**
- PLUS RAPIDE et MOINS DE SKATE, avec tous leurs départages.
- Résultat déterministe : à données égales, même ordre à chaque appel.

**Routing**
- Réseau francilien simplifié : 43 stations, 9 lignes
  (métro 1/4/6, RER A/B, tram T2/T3a, bus 38/91).
- Recherche de chemin réelle (Dijkstra sur station × ligne), qui produit
  attentes, correspondances à pied et fusion des arrêts d'une même ligne.
- Génération de candidats : marche seule, skate seul, et toutes les
  combinaisons accès/sortie marche ou skate.

**Application Flutter**
- Accueil : départ, destination, inversion, Calculer, hypothèses de calcul.
- Résultats : les deux recommandations, puis les autres itinéraires.
- Détail : chiffres clés et séquence étape par étape.
- Thème clair et sombre.

**Harnais de test**
- `dart run tool/nimbus_cli.dart` exerce tout le moteur sans interface.

**Honnêteté**
- Le réseau fictif, l'approximation des distances et le proxy skate/vélo
  sont affichés dans l'application, pas seulement dans le code.
- Les adaptateurs OTP / GTFS / OSM refusent de répondre tant qu'ils ne
  sont pas configurés. Aucune API réelle n'est simulée.

## En cours

Rien. Le lot est terminé.

## Prochaine action

Voir `docs/BACKLOG.md`. Par ordre d'utilité :

1. Faire produire un APK Android (voir « Blocages » ci-dessous).
2. Remplacer le réseau fictif par les données GTFS d'Île-de-France Mobilités.
3. Remplacer les distances à vol d'oiseau par de vrais tracés de rues.

## Blocages

### Build Android — non produit ici

L'environnement de développement à distance bloque l'accès à
`dl.google.com`. Or le SDK Android et les greffons Gradle ne se
téléchargent que depuis cette adresse. **Aucun APK n'a donc été produit,
et aucun build Android n'est présenté comme existant.**

Le projet Android lui-même est complet et correctement configuré
(nom « GPS NIMBUS », identifiant `fr.gpsnimbus.gps_nimbus`).

**ACTION REQUISE — pour obtenir l'application sur un téléphone Android :**

1. Installe Android Studio sur ton ordinateur (gratuit,
   <https://developer.android.com/studio>).
2. Installe Flutter en suivant <https://docs.flutter.dev/get-started/install>.
3. Ouvre un terminal dans le dossier `gps_nimbus` du projet.
4. Tape : `flutter build apk --debug`
5. Le fichier obtenu est dans
   `build/app/outputs/flutter-apk/app-debug.apk` — copie-le sur ton
   téléphone et ouvre-le.

### Build iOS — non produit

Un Mac avec Xcode est indispensable pour compiler une application iPhone.
Cette machine tourne sous Linux. Le projet iOS est présent et configuré,
mais **aucun build iOS n'a été produit**.

**ACTION REQUISE — sur un Mac, si tu en as un :**

1. Installe Xcode depuis le Mac App Store.
2. Installe Flutter (<https://docs.flutter.dev/get-started/install/macos>).
3. Ouvre un terminal dans le dossier `gps_nimbus`.
4. Tape : `flutter run` avec ton iPhone branché en USB.

La publication sur l'App Store demande un compte développeur Apple payant :
c'est une décision qui t'appartient, elle n'a pas été engagée.
