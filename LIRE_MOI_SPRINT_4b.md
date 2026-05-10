# 📦 Sprint 4b — Mobile Money 💸

> Wave 🌊 / Orange Money 🟠 / MTN MoMo 🟡
> Pattern Strategy + simulation complète du flux de paiement.

---

## 📋 Contenu (21 fichiers)

### 🆕 Nouveaux fichiers (15)

**Module paiements complet** :

```
lib/features/paiements/
├── domaine/
│   ├── entites/
│   │   ├── operateur_mm.dart           (1)
│   │   └── paiement.dart               (2)
│   └── contracts/
│       ├── operateur_mobile_money.dart (3)  ← Strategy contract
│       ├── exception_paiement.dart     (4)
│       └── paiement_repository.dart    (5)
├── data/
│   ├── operateurs/
│   │   ├── operateur_wave_demo.dart           (6)  ← Strategy impl
│   │   ├── operateur_orange_money_demo.dart   (7)  ← Strategy impl
│   │   └── operateur_mtn_momo_demo.dart       (8)  ← Strategy impl
│   └── repositories/
│       └── paiement_repository_demo.dart      (9)
└── presentation/
    ├── providers/
    │   └── paiement_provider.dart      (10)
    ├── widgets/
    │   ├── carte_operateur.dart        (11)
    │   └── carte_paiement.dart         (12)
    └── ecrans/
        ├── choix_operateur_ecran.dart        (13)
        ├── confirmation_paiement_ecran.dart  (14)
        └── recu_paiement_ecran.dart          (15)
```

### ✏️ Fichiers modifiés (6)

- `lib/main.dart` — ajout du `PaiementProvider`
- `lib/core/constantes/routes_noms.dart` — 3 nouvelles routes
- `lib/core/routes/routes_app.dart` — table de routes
- `lib/features/cotisations/presentation/widgets/cotisation_carte.dart` — bouton "Payer via Mobile Money"
- `lib/features/cotisations/presentation/ecrans/detail_tour_ecran.dart` — lance le flux paiement
- `lib/features/accueil/presentation/ecrans/paiements_ecran.dart` — onglet historique fonctionnel

---

## 🚀 Comment appliquer

### 1️⃣ Sauvegarde Sprint 4a
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects
xcopy tontineapp tontineapp_sprint4a_backup /E /I /Q
```

### 2️⃣ Extrais le ZIP, copie tout dans `tontineapp/` → **« Remplacer »**

### 3️⃣ Lance
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
flutter run
```

> Pas de nouvelle dépendance — pas besoin de `flutter pub get`.

---

## 🎯 Le flux complet à tester (5 minutes)

### Parcours « Membre paie via Wave »

1. **Va sur Famille Yopougon → Tour 3 (en cours)**
2. Trouve une cotisation **À cotiser** où tu apparais comme membre
3. Clique sur **« Payer via Mobile Money »** 💸
4. Tu arrives sur l'écran **Choix de l'opérateur** :
   - Récap montant en haut (gros)
   - 3 cartes : Wave / Orange Money / MTN MoMo
   - Chaque carte affiche frais (1% Wave, 1.5% OM/MTN), nom, baseline
5. Tape sur **Wave** → la carte devient bleue ciel, surbrillance
6. Saisis ton numéro Mobile Money (pré-rempli)
7. Clique sur **Continuer**
8. Tu arrives sur l'écran **Confirmation Wave** :
   - Fond bleu Wave + en-tête avec logo "WAVE"
   - Carte blanche en bas avec récap (montant, frais, total, numéro, référence)
   - Champs PIN à 4 chiffres
   - Note verte : « Mode démo : utilisez 1234 »
   - Timer "Code expiré dans 90s"
9. Saisis **`1234`**
10. → Animation de chargement « Connexion à Wave... »
11. → 🎉 **Écran Reçu** : check vert animé, montant en gros, détails complets
12. Clique sur **Retour à la tontine**
13. → Tu retournes sur le détail tour, et la cotisation est **passée en Validée** automatiquement (plus besoin de l'admin)

### Parcours « Mauvais OTP »

1. Refais le même flux
2. Saisis **`9999`** (mauvais code) à l'OTP
3. → Snackbar rouge : « Code incorrect. En mode démo, utilisez 1234. »
4. Le champ se vide, tu peux réessayer

### Parcours « Annulation »

1. Sur l'écran Confirmation, clique sur la croix **X** en haut à gauche
2. Dialog de confirmation
3. → Retour propre, pas de paiement enregistré comme réussi

### Onglet Paiements 📊

1. Va sur l'onglet **Paiements** (4e en bas)
2. Tu vois maintenant :
   - 🟢 **Carte verte récap** : total payé via MM + total des frais
   - 📜 **Liste de tes paiements** avec logo opérateur, statut, montant, date, référence

### Test des 3 opérateurs

Refais le flux mais avec **Orange Money** (fond orange vif) puis **MTN MoMo** (fond jaune avec texte noir). Chaque opérateur a son habillage propre, ses délais, sa baseline.

---

## 🎨 Détails de design (pour ton mémoire)

| Aspect | Implémentation |
|---|---|
| Pattern | **Strategy** : 1 contrat, 3 implémentations interchangeables |
| Couleurs | Officielles de chaque opérateur (Wave bleu ciel, OM orange vif, MTN jaune) |
| OTP | 4 chiffres (différent du 6 chiffres auth — réaliste pour MM) |
| Frais | 1% Wave, 1.5% OM, 1.5% MTN |
| Auto-validation | À chaque paiement réussi, la cotisation passe en `validee` automatiquement (le repo paiement appelle `cotisationRepo.validerCotisation`) |
| Persistance | Tous les paiements (réussis, échecs, annulés) sont persistés en JSON |

### Pourquoi le pattern Strategy ?

```dart
abstract class OperateurMobileMoney {       // ← Contrat unique
  Future<ResultatInitiation> initierPaiement(...);
  Future<void> confirmerOtp(...);
  num calculerFrais(num montant);
}

class OperateurWaveDemo implements OperateurMobileMoney { ... }
class OperateurOrangeMoneyDemo implements OperateurMobileMoney { ... }
class OperateurMtnMomoDemo implements OperateurMobileMoney { ... }
```

Le repository garde une `Map<OperateurMM, OperateurMobileMoney>` et délègue selon le choix de l'utilisateur.

**Avantage immense** : pour passer en production, il suffira de remplacer chaque `OperateurXxxDemo` par `OperateurXxxApi` qui appelle la vraie API de l'opérateur. **Aucun autre fichier ne change.**

---

## ⚠️ Points à savoir

- **Code OTP universel mode démo** : `1234` (pour les 3 opérateurs)
- **Pas de vraie connexion API** — c'est un POC propre, pas un système de paiement réel
- **Frais ajoutés au montant débité** mais le bénéficiaire reçoit toujours le montant net (les frais vont à l'opérateur)
- Le bouton "Marquer reçue (admin)" reste disponible pour les paiements **hors Mobile Money** (cash) — utile en pratique

---

## 📈 Bilan global du projet

| Sprint | Fichiers ajoutés | Lignes |
|---|---|---|
| 1 — Auth | 30 | ~2 700 |
| 2 — Tontines | +12 | +2 700 |
| 3 — Cotisations | +6 | +1 400 |
| 4a — Persistance | +1 | ~7 100 (au total) |
| 4b — Mobile Money | +15 | **~9 400 au total** |

**62 fichiers Dart, 9 400 lignes de code, 5 modules feature, architecture Clean Strategy.** 🏗️

---

🎉 **Sprint 5 (notifications + finitions)** dès que tout marche !
