# Journal des décisions

Chaque décision qui change le projet y est notée : date, décision, raison. Les nouvelles entrées s'ajoutent **en haut**, et une décision qui modifie `docs/SPEC.md` est committée avec la mise à jour du cahier des charges.

## 2026-10-15 — Prototype de la course

| # | Décision | Raison |
| --- | --- | --- |
| 19 | Tests automatiques avec un petit lanceur maison (`tests/run_tests.gd`), sans addon | Suffit pour tester les règles ; aucune dépendance externe à suivre ni à créditer. |
| 18 | Données de jeu en JSON (`data/`), validées au chargement | Lisible et modifiable à la main, facile à vérifier dans les tests. |
| 17 | Barème de l'arrivée : 3 étoiles pour le nombre exact, 2 à ±10 %, 1 à ±25 %, 0 sinon | Récompense le « bon nombre » sans punir un léger écart ; les récompenses viendront avec la ferme. |
| 16 | Division arrondie à l'inférieur, avec une animation pour chaque mouton perdu ; soustraction plancher à 0 ; troupeau vide = course perdue ; règles expliquées dans le tutoriel | Règle simple et visible : le joueur comprend pourquoi il perd des moutons. |
| 15 | Deux ponts : le pont en bois cède (course perdue), le pont en pierre ramène le troupeau à son maximum | Deux niveaux de sévérité : l'un oblige à anticiper, l'autre influence la suite de la course. |
| 14 | Prototype en français seul ; les autres langues arrivent avant la V1 | Le prototype sert à valider le plaisir de jeu ; les textes passent déjà tous par les fichiers de traduction. |

## 2026-10-15 — Phase d'exploration

| # | Décision | Raison |
| --- | --- | --- |
| 13 | Prix cible : 2 CHF, à confirmer avant le test fermé | 1 CHF fait « gadget » et rapporte trop peu ; 3 CHF freine l'achat d'un jeu inconnu. Ne jamais publier en gratuit : une app gratuite ne redevient jamais payante. |
| 12 | Compte développeur Google Play personnel | Pas d'entreprise ; le compte organisation exige un numéro D-U-N-S. Conséquence acceptée : adresse complète visible sur la fiche, et test fermé de 12 testeurs pendant 14 jours. |
| 11 | Option « Suisse authentique » activée par défaut ; le tutoriel explique comment la désactiver | Le gag des langues fait partie de l'identité du jeu, mais ne doit pas piéger le joueur. |
| 10 | Écran en portrait, jouable à une main | Sessions courtes, dans le bus ou en pause. |
| 9 | Nom : « Loup & Laine » (Wolf & Wolle, Lupo & Lana, Luf & Launa, Wolf & Wool) | Allitération dans les cinq langues ; le « & » dit cohabitation, pas affrontement. Disponibilité à vérifier (Play Store, Swissreg, EUIPO). |
| 8 | Style low poly doux, base d'assets CC0 (Quaternius) | Réalisable sans illustrateur ; cohérent et animable. Filtre aquarelle reporté en finition. |
| 7 | Langues : FR, DE (orthographe suisse), IT, RM (rumantsch grischun), EN | Thème suisse ; le romanche est la langue de l'administration, donc des ordonnances. Relecture native obligatoire pour le romanche. |
| 6 | Moteur Godot 4, GDScript | Gratuit, sans commission, export Android ; GDScript proche de Python ; même projet réutilisable pour iOS, PC et web. |
| 5 | « Feuille officielle » : ordonnances saisonnières d'un parlement fictif | Clin d'œil à la politique qui pèse sur l'éleveur ; neutre (aucun vrai parti) ; règles annoncées à l'avance et consultables. |
| 4 | V1 : camp éleveur seul ; camp garde-faune en mise à jour | Garder une V1 réaliste à terminer. |
| 3 | Thème : alpage suisse, moutons et loup, problèmes réels des éleveurs | Thème rare sur le store, ancré dans l'actualité 2026 ; évite les univers sous licence (pas d'éléments de Dune). |
| 2 | Mécanique du « bon nombre » : arriver avec le bon effectif, pas le plus grand | Innover sur le genre des portes ; rendre les diviseurs utiles. |
| 1 | Genre : course à portes (+ − × ÷) liée à une ferme à développer, solo et hors ligne, achat unique sans pub | Jouable par petits moments sans rester connecté ; éviter le multijoueur pay-to-win. |
