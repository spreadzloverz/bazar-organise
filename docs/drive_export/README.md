# Export Drive — GPS NIMBUS

Drive sert d'archive et de documentation. **L'application n'en dépend pas** :
si Drive n'est pas disponible, le développement continue normalement.

## Structure cible dans Drive

```
GPS_NIMBUS/
├── 00_ADMIN
├── 01_PRODUIT
├── 02_ARCHITECTURE
├── 03_ROUTING
├── 04_API_SOURCES
├── 05_TESTS
├── 06_SESSIONS
├── 07_EXPORTS
└── 99_ARCHIVES
```

## Quoi déposer, et où

| Dossier Drive | Fichier du dépôt |
|---------------|------------------|
| 01_PRODUIT | `docs/notebooklm/01_VISION.md` |
| 02_ARCHITECTURE | `docs/ARCHITECTURE.md`, `docs/notebooklm/02_ARCHITECTURE.md` |
| 03_ROUTING | `docs/notebooklm/03_ROUTING.md` |
| 04_API_SOURCES | `docs/notebooklm/05_SOURCES.md` |
| 05_TESTS | la sortie de `flutter test` |
| 06_SESSIONS | `docs/STATUS.md`, `docs/DECISIONS.md` |
| 07_EXPORTS | l'APK, une fois qu'il aura pu être produit |

## À ne jamais transférer

- fichiers `.env`
- clés d'API, jetons, mots de passe, identifiants
- caches (`.dart_tool/`, `build/`)
- dépendances compilées

Aucun de ces éléments n'existe aujourd'hui dans le projet : GPS NIMBUS
n'utilise ni service externe ni secret.
