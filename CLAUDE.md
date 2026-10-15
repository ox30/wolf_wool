# Loup & Laine — règles de travail

Jeu mobile Android payant, sans pub, solo et hors ligne : on mène un troupeau vers l'alpage (course à portes) et on développe sa ferme de montagne. Moteur Godot 4 (4.7.x), GDScript.

## Références

- Cahier des charges : `docs/SPEC.md` — **à lire avant toute tâche**. C'est la référence.
- Journal des décisions : `docs/DECISIONS.md`.

## Avant de coder

- Si une demande contredit `docs/SPEC.md` ou l'étend, le signaler et attendre la réponse avant de coder.
- Tout changement d'exigence : mettre à jour `docs/SPEC.md` et ajouter une entrée en haut de `docs/DECISIONS.md`, **dans le même commit** que le code.
- Respecter le périmètre V1 (Suisse, moutons, loup, camp éleveur). Ce qui relève des mises à jour (garde-faune, vaches, chèvres, autres pays) n'entre pas en V1 sans décision notée.

## Conventions

- **Langues** : code, identifiants et commentaires en anglais ; documentation et messages de commit en français.
- **GDScript** : typage statique (`var count: int`, fonctions typées). Suivre le guide de style officiel Godot (snake_case, PascalCase pour les classes).
- **Logique séparée de l'affichage** : les règles (opérations des portes, contraintes de nombre, production hors ligne, ordonnances) vivent dans des scripts sans dépendance aux scènes, pour pouvoir les tester seules.
- **Textes** : jamais en dur. Toujours une clé de traduction (`tr("KEY")`) dans les fichiers de `i18n/`. Cinq langues : fr, de, it, rm, en. Allemand en orthographe suisse (ss, jamais ß).
- **Contenu en données** : portes, niveaux, bâtiments et ordonnances dans `data/`, pas dans le code. Ajouter du contenu ne doit pas demander de modifier un script.
- **Temps hors ligne** : la production pendant l'absence se calcule à la réouverture à partir de l'horloge, sans serveur.
- **Aucune donnée collectée**, aucun appel réseau, aucune publicité, aucun achat intégré qui donne un avantage.
- **Pas de violence graphique** : une attaque de loup se montre par des moutons qui fuient ou disparaissent, jamais par du sang.
- **Assets** : uniquement CC0 ou créés pour le projet. Noter chaque source et sa licence dans `assets/CREDITS.md`.
- **Android** : cibler l'API exigée par Google Play (Android 16, API 36). Écran en portrait.

## Sécurité

- Ne jamais committer de keystore, mot de passe ou fichier de signature (`*.keystore`, `*.jks`, `export_credentials.cfg`). Ils sont dans `.gitignore`.

## Git

- Un commit par changement cohérent, message en français à l'impératif (« Ajoute les portes de division »).

## Étape en cours

Prototype de la course seule : troupeau, portes (+ − × ÷), une contrainte de nombre, écran d'arrivée, graphismes provisoires. Objectif : vérifier que la course est amusante en deux minutes.
