# 📦 Sprint 4a — Persistance locale

> Delta à appliquer sur le projet Sprint 3.
> **À partir de maintenant, plus rien ne disparaît au redémarrage de l'app.** 🎯

---

## 📋 Contenu (10 fichiers)

### 🆕 Nouveau (1)

- `lib/core/donnees/stockage_json.dart` — Service de persistance JSON cross-platform

### ✏️ Fichiers modifiés (9)

- `pubspec.yaml` — ajout de la dépendance `path_provider`
- `lib/main.dart` — initialisation async de la persistance
- `lib/core/entites/tontine.dart` — sérialisation `versJson` / `depuisJson`
- `lib/core/entites/membre.dart` — sérialisation
- `lib/core/entites/tour.dart` — sérialisation
- `lib/core/entites/cotisation.dart` — sérialisation
- `lib/features/tontines/data/repositories/tontine_repository_demo.dart` — devient **persistant**
- `lib/features/cotisations/data/repositories/cotisation_repository_demo.dart` — devient **persistant**
- `lib/features/accueil/presentation/ecrans/profil_ecran.dart` — bouton **« Réinitialiser les données démo »**

---

## 🚀 Comment appliquer

### 1️⃣ Sauvegarde Sprint 3
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects
xcopy tontineapp tontineapp_sprint3_backup /E /I /Q
```

### 2️⃣ Extrais le ZIP, copie-colle dans `tontineapp/`
Sélectionne tout (`lib/`, `pubspec.yaml`, `LIRE_MOI_SPRINT_4a.md`) → **« Remplacer »**.

### 3️⃣ Récupérer la nouvelle dépendance
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
flutter pub get
```

### 4️⃣ Lance
```powershell
flutter run
```

---

## ✨ Le test critique

1. **Lance l'app** → tu vois les 3 tontines de démo (comme avant)
2. **Crée une nouvelle tontine** "Test Persistance"
3. **Invite un membre** dedans
4. **Active-la**
5. **Marque quelques cotisations comme payées**
6. **Ferme complètement l'app** (swipe dans la liste des apps récentes Android, ou ⌘Q sur desktop)
7. **Relance l'app**
8. → 🎉 **Tout est encore là** : ta tontine "Test Persistance", ton membre invité, tes cotisations marquées payées

C'est ça la vraie victoire de ce sprint.

### Bonus : le bouton « Tout effacer »
Va dans **Profil → Données → Réinitialiser les données démo**.
- Toutes les tontines et cotisations sont effacées
- L'app se ferme automatiquement (Android)
- Au prochain lancement, les 3 tontines de démo sont régénérées

---

## 🧠 Comment ça marche techniquement ?

Au démarrage :
1. Le repo `TontineRepositoryDemo` (gardé sous le même nom mais désormais persistant) charge le contenu de `tontineapp_tontines.json` depuis le dossier documents de l'app
2. Si le fichier n'existe pas → premier lancement → seed avec les 3 tontines de démo + sauvegarde
3. Si le fichier existe → on charge ce qui était sauvegardé

Lors de chaque mutation (créer tontine, inviter membre, valider cotisation, etc.) :
1. La modification est appliquée en mémoire
2. **Le fichier JSON est ré-écrit immédiatement** sur le disque

**Localisation du fichier** :
- Android : `/data/data/<package>/app_flutter/tontineapp_*.json`
- Windows : `C:\Users\<TonNom>\Documents\...`
- iOS : sandbox app

Tu peux `adb pull` le fichier sur Android pour l'inspecter — c'est du JSON lisible.

---

## ⚠️ Points à savoir

- **L'auth (compte utilisateur) était déjà persistée** depuis le Sprint 1 via SharedPreferences — on n'a rien changé là-dessus
- **Le seed n'a lieu qu'une seule fois**, au tout premier lancement (ou après réinitialisation)
- Si tu veux changer les données démo (modifier les tontines de seed), il faut **réinitialiser** d'abord via le bouton dans Profil
- **Pas de SQLite cette fois** — JSON simple. C'est largement suffisant pour les volumes d'une tontine. Si on a besoin de requêtes complexes plus tard, on pourra migrer.

---

## 🐛 Si quelque chose plante

| Symptôme | Cause probable | Solution |
|---|---|---|
| `MissingPluginException: getApplicationDocumentsDirectory` | Pas de `flutter pub get` après l'ajout de path_provider | `flutter pub get` puis arrêter et relancer (pas hot reload) |
| Les données de démo ne se rechargent pas après reset | Cache résiduel | Désinstalle complètement l'app sur l'émulateur, puis relance |
| Erreur de désérialisation au démarrage | Format JSON modifié entre versions | Bouton "Réinitialiser les données démo" |

---

🚀 **Sprint 4b (Mobile Money — Wave / Orange Money / MTN MoMo)** dès que tout marche !
