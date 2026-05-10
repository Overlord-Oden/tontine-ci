# 📦 Sprint 3 — Delta à appliquer

> Mini-ZIP contenant **uniquement** les fichiers nouveaux et modifiés
> à ajouter par-dessus le projet Sprint 2.

---

## 📋 Contenu (12 fichiers)

### 🆕 Nouveaux fichiers (6)

**Entité** (1) :
- `lib/core/entites/cotisation.dart`

**Module cotisations** (5) :
- `lib/features/cotisations/domaine/contracts/cotisation_repository.dart`
- `lib/features/cotisations/data/repositories/cotisation_repository_demo.dart`
- `lib/features/cotisations/presentation/providers/cotisation_provider.dart`
- `lib/features/cotisations/presentation/widgets/cotisation_carte.dart`
- `lib/features/cotisations/presentation/ecrans/detail_tour_ecran.dart`

### ✏️ Fichiers modifiés (à remplacer) (6)

- `lib/main.dart` — ajout du `CotisationProvider` + génération auto des cotisations démo
- `lib/core/constantes/routes_noms.dart` — nouvelle route `detailTour`
- `lib/core/routes/routes_app.dart` — table de routes mise à jour
- `lib/features/tontines/presentation/widgets/tour_carte.dart` — devient cliquable (`onTap` optionnel)
- `lib/features/tontines/presentation/ecrans/detail_tontine_ecran.dart` — navigue vers le détail tour au tap
- `lib/features/accueil/presentation/ecrans/tableau_bord_ecran.dart` — clic sur tontine active → directement le détail tour en cours

---

## 🚀 Comment appliquer

### 1️⃣ Sauvegarde Sprint 2 (par sécurité)
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects
xcopy tontineapp tontineapp_sprint2_backup /E /I /Q
```

### 2️⃣ Extraire le mini-ZIP, puis copier par-dessus
Sélectionne tout (`lib/`, `LIRE_MOI_SPRINT_3.md`) → colle dans `tontineapp/` → **« Remplacer »**.

### 3️⃣ Lancer
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
flutter run
```

> Pas de nouvelle dépendance dans pubspec.yaml — pas besoin de `flutter pub get` cette fois.

---

## 🎯 Quoi tester

### Parcours « Membre »
1. Ouvre **Famille Yopougon** (tu es admin de cette tontine)
2. Onglet **Calendrier** → tape sur le **Tour 3 (En cours)**
3. Tu vois :
   - Bandeau orange avec le bénéficiaire et la cagnotte
   - Barre de progression (~60 %)
   - **Bénéficiaire** en haut (ne paie pas)
   - **À cotiser** : les membres pas encore payés
   - **Cotisations reçues** : déjà validées
4. Si tu apparais dans **À cotiser** : bouton **« J'ai payé »** → la cotisation passe en *À valider*

### Parcours « Admin »
1. Sur le même tour, en tant qu'admin tu peux :
   - **Valider** une cotisation marquée payée → elle passe en *Cotisations reçues*
   - **Refuser** une cotisation → elle revient en *À cotiser*
   - **Marquer reçue** une cotisation directement (sans passer par "J'ai payé")

### Clôture automatique 🎉
1. Valide **toutes** les cotisations restantes du tour
2. Une popup apparaît : **« Tour complet ! 🎉 »**
3. *(Le passage automatique au tour suivant arrive au Sprint 4)*

### Accès rapide depuis l'accueil
1. Reviens à l'onglet **Accueil**
2. Clique sur une tontine active → tu arrives **directement sur le tour en cours** (plus rapide que de passer par le détail tontine)

### Ouvrir un tour passé (historique)
1. Sur **Famille Yopougon**, onglet **Historique**
2. Tape sur un tour terminé → tu vois la liste complète des cotisations validées (read-only)

---

## ⚠️ Points à savoir

- Les cotisations sont **régénérées à chaque lancement** de l'app (mode démo en mémoire)
- En mode démo, ~60 % des cotisations sont déjà validées sur les tours en cours, pour que tu puisses tester rapidement la validation des restantes
- Les cotisations que tu marques toi-même (payées/validées/refusées) **persistent dans la session** mais disparaissent au redémarrage
- La vraie persistance + intégration Mobile Money arrive au **Sprint 4**

---

🚀 **Sprint 4 (Mobile Money — Wave / Orange Money / MTN MoMo)** dès que tout marche !
