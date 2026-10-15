# Loup & Laine

Jeu mobile Android : mène ton troupeau vers l'alpage, arrive avec le bon nombre de moutons, développe ta ferme de montagne — et lis bien la Feuille officielle. Payant, sans pub, solo et hors ligne.

**État** : prototype de la course (troupeau, portes + − × ÷, ponts, écran d'arrivée, graphismes provisoires).

- Cahier des charges : [docs/SPEC.md](docs/SPEC.md)
- Journal des décisions : [docs/DECISIONS.md](docs/DECISIONS.md)
- Règles de travail pour Claude Code : [CLAUDE.md](CLAUDE.md)

Moteur : [Godot 4](https://godotengine.org/) (GDScript).

## Lancer le prototype

1. Installer [Godot 4.7](https://godotengine.org/download) (version standard, pas .NET).
2. Ouvrir le projet (`project.godot`) dans l'éditeur, puis lancer avec F5.
3. Sur PC : glisser avec la souris ou utiliser les flèches ← → pour changer de côté.

## Organisation

| Dossier | Contenu |
| --- | --- |
| `data/` | Courses (`levels/*.json`) et apparence des portes (`gates.json`) |
| `i18n/` | Textes du jeu (`strings.csv`, une colonne par langue) |
| `scripts/logic/` | Règles sans affichage : portes, ponts, course, résultat, chargement des données |
| `scripts/view/` | Affichage : moutons, portes, ponts, décor, HUD, écran d'arrivée |
| `scenes/` | Scène de course et interfaces |
| `tests/` | Tests des règles |

Ajouter une course : copier `data/levels/level_01.json`, modifier les obstacles et ajouter le chemin dans `tests/test_level_loader.gd` (le test vérifie qu'un chemin atteint la cible exacte).

## Tests

```sh
godot --headless --path . --import          # une fois, après un clone
godot --headless --path . -s tests/run_tests.gd
```

## Export Android

Lors de la création du préréglage d'export Android, ajouter `data/*.json` dans « Filtres pour exporter des fichiers non-ressources » : sans cela, les courses ne sont pas incluses dans l'APK.
