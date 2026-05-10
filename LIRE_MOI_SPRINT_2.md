# 📦 Sprint 2 — Delta à appliquer

> Mini-ZIP contenant **uniquement** les fichiers nouveaux et modifiés
> à ajouter par-dessus le projet Sprint 1.

---

## 📋 Contenu (18 fichiers)

### 🆕 Nouveaux fichiers (12)

**Entités du domaine** (3) :
- `lib/core/entites/tontine.dart`
- `lib/core/entites/membre.dart`
- `lib/core/entites/tour.dart`

**Module tontines** (9) :
- `lib/features/tontines/domaine/contracts/tontine_repository.dart`
- `lib/features/tontines/data/repositories/tontine_repository_demo.dart`
- `lib/features/tontines/presentation/providers/tontine_provider.dart`
- `lib/features/tontines/presentation/widgets/tontine_carte.dart`
- `lib/features/tontines/presentation/widgets/membre_ligne.dart`
- `lib/features/tontines/presentation/widgets/tour_carte.dart`
- `lib/features/tontines/presentation/ecrans/liste_tontines_ecran.dart`
- `lib/features/tontines/presentation/ecrans/creer_tontine_ecran.dart`
- `lib/features/tontines/presentation/ecrans/detail_tontine_ecran.dart`

### ✏️ Fichiers modifiés (à remplacer par les versions du ZIP) (6)

- `pubspec.yaml` — ajout de `flutter_localizations`
- `lib/main.dart` — ajout du `TontineProvider` et localisation FR
- `lib/core/constantes/routes_noms.dart` — 2 nouvelles routes
- `lib/core/routes/routes_app.dart` — table de routes mise à jour
- `lib/features/accueil/presentation/ecrans/mes_groupes_ecran.dart` — délègue à `ListeTontinesEcran`
- `lib/features/accueil/presentation/ecrans/tableau_bord_ecran.dart` — vraies stats + tontines actives

---

## 🚀 Comment appliquer le delta

### Étape 1 — Sauvegarder ton projet Sprint 1 (par sécurité)
```bash
cd C:\Users\Allassane_Diomande\StudioProjects\
xcopy tontineapp tontineapp_sprint1_backup /E /I
```

### Étape 2 — Extraire le mini-ZIP
Extrais `tontineapp_sprint_2_delta.zip` dans un dossier temporaire.
Tu obtiens un dossier `tontineapp_sprint_2_delta/` avec la même
arborescence `lib/...` que ton projet.

### Étape 3 — Copier par-dessus
**Avec l'explorateur Windows :**
1. Sélectionne tout le contenu du dossier extrait (`lib/`, `pubspec.yaml`)
2. Copie → colle dans `C:\Users\Allassane_Diomande\StudioProjects\tontineapp\`
3. Quand Windows demande, choisis **« Remplacer les fichiers dans la destination »**

**Ou en ligne de commande (PowerShell) :**
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
Copy-Item -Path "C:\chemin\vers\tontineapp_sprint_2_delta\*" -Destination . -Recurse -Force
```

### Étape 4 — Récupérer la nouvelle dépendance
```bash
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
flutter pub get
```

### Étape 5 — Lancer
```bash
flutter run
```

---

## 🎯 Quoi tester

1. **Lance l'app** → tu es auto-reconnecté (session Sprint 1 conservée)
2. **Va sur l'onglet « Mes groupes »** → tu vois maintenant **3 tontines de démo** :
   - 🟢 « Famille Yopougon » — Active, tour 3 en cours, tu es admin
   - 🟢 « Collègues du bureau » — Active, tour 2 en cours, tu es membre
   - 🟡 « Voyage Bassam » — Brouillon, en préparation, tu es admin
3. **Tape sur une tontine active** → 3 onglets :
   - **Membres** : liste avec rôles, statuts, ordres de passage
   - **Calendrier** : tours à venir + tour en cours avec barre de progression
   - **Historique** : tours déjà terminés
4. **Tape sur la tontine en brouillon « Voyage Bassam »** :
   - Bouton **Inviter** en bas → ouvre une dialog
   - Saisis un nom et un numéro → le membre apparaît dans la liste
   - Quand tu as ≥ 2 membres → bouton vert **Activer** apparaît
   - Active → le calendrier des tours est généré automatiquement
5. **Reviens sur l'onglet Accueil** → les stats sont **vraies** :
   - Tontines actives : 2 (ou 3 si tu as activé Voyage Bassam)
   - Cotisations en attente
   - Total épargné (calculé sur les tours terminés)
   - Liste des tontines actives en bas
6. **Crée une nouvelle tontine** :
   - Bouton flottant **« Nouvelle tontine »** sur l'onglet Mes groupes
   - Remplis le formulaire : nom, montant, fréquence, date de début
   - Tu es créé(e) admin automatiquement
   - Invite des membres, active

---

## ⚠️ Important — Mode démo

- Les 3 tontines sont **réinitialisées au lancement de l'app** (mémoire)
- Les tontines que tu crées toi-même **disparaîtront** au redémarrage (Sprint 4 ajoutera la persistance complète)
- Les paiements via Mobile Money sont **simulés** (vraie intégration au Sprint 4)

---

## 🐛 En cas de problème

| Erreur | Solution |
|---|---|
| `Could not find package "flutter_localizations"` | Lance `flutter pub get` |
| `Tontine introuvable` | Probablement un id invalide, redémarre l'app |
| L'écran reste blanc sur l'onglet Mes groupes | Vérifie qu'il n'y a pas d'erreur rouge en haut, partage-moi le message |

---

🚀 **Sprint 3 (Cotisations & cycles de paiement)** dès que tout marche !
