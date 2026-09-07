# GOLDEN ROUTES — GPS NIMBUS

Dernière mise à jour : 2026-09-07

Les Golden Routes sont des cas terrain utilisés pour empêcher les régressions
du moteur. Les points de domicile et d'arrivée sont remplacés par des
identifiants de test ; seuls les arrêts publics sont nommés.

## GOLDEN-001 — Alfortville → Issy-les-Moulineaux

### Identifiants de test

- Départ : `GOLDEN-001_ORIGIN_ALFORTVILLE`
- Destination : `GOLDEN-001_DESTINATION_ISSY`

Les détails de localisation nécessaires aux essais personnels restent hors du
dépôt, dans un fichier local ignoré par Git.

### Observations terrain

| Segment | Mode | Observation |
|---|---|---:|
| Départ → Quai de la Gare | skate | environ 10 min |
| Départ → gare d'Ivry-sur-Seine | skate | environ 7 à 10 min |
| Mairie d'Issy → destination | skate | environ 5 min |

Ces mesures ont priorité sur une durée générique calculée uniquement avec
`distance / 27 km/h`, à condition que le sens, le mode et les extrémités du
segment correspondent.

### Itinéraire de référence A

```text
SKATE
→ Quai de la Gare
→ MÉTRO 6
→ Pasteur
→ CORRESPONDANCE À PIED
→ MÉTRO 12
→ Mairie d'Issy
→ SKATE
→ destination
```

### Itinéraire candidat B

```text
SKATE
→ gare d'Ivry-sur-Seine
→ RER C
→ Issy ou Issy–Val de Seine selon la mission réelle
→ SKATE ou MARCHE
→ destination
```

Le réseau fictif sait désormais représenter les deux corridors. Il ne dispose
pas encore des horaires IDFM, des perturbations, ni des vrais tracés de rue :
aucun gagnant réel ne doit donc être annoncé à partir de ce test seul.

La gare d'Ivry-sur-Seine reste candidate lorsqu'elle est explicitement donnée.
Le moteur ne la remplace jamais silencieusement par Bibliothèque
François-Mitterrand.

### Règles de non-régression

1. Les observations utilisateur compatibles remplacent l'estimation générique.
2. Une plage de 7 à 10 min reste une plage ; elle n'est pas transformée en
   mesure prétendument exacte.
3. Une observation A → B ne s'applique pas automatiquement à B → A.
4. Ivry-sur-Seine reste un point d'accès candidat explicite.
5. Une station absente du réseau mock est signalée comme non calculable ; elle
   n'est ni supprimée ni remplacée.
6. Une perturbation temporaire devra être liée à une période de validité ; elle
   ne deviendra jamais une règle permanente.
7. Le classement final devra distinguer données mockées, horaires prévus,
   données temps réel et mesures terrain.

### État vérifié

- Modèle d'observation utilisateur : `TESTED`
- Application aux tronçons marche/skate compatibles : `TESTED`
- Protection des stations explicites : `TESTED`
- Métro 6 Quai de la Gare → Pasteur : `TESTED / MOCKED`
- Métro 12 Pasteur → Mairie d'Issy : `TESTED / MOCKED`
- RER C Ivry-sur-Seine → Issy–Val de Seine : `TESTED / MOCKED`
- Variante M6 + M12 avec temps terrain d'accès et de sortie : `TESTED / MOCKED`
- Variante RER C avec plage terrain 7–10 min : `TESTED / MOCKED`
- Suite complète : 95 tests réussis dans le run CI `34141968781`
- Horaires et perturbations IDFM : `NOT IMPLEMENTED`
- Comparaison porte-à-porte sur données réelles : `NOT IMPLEMENTED`
- Essai sur appareil physique : `NOT DEVICE_TESTED`
