# 🇨🇮 TontineApp — Sprint 1

> Application mobile Flutter de gestion de tontines numériques pour la Côte d'Ivoire.

---

## 📌 État du projet

✅ **Sprint 1 livré** — Onboarding complet + Authentification + Navigation

### Fonctionnalités opérationnelles
- 🌅 **Splash Screen** avec motif kente et vérification automatique de session
- 📱 **Inscription** par numéro de téléphone (sélecteur de pays — drapeau CI par défaut)
- 🔢 **Vérification OTP** à 6 chiffres avec timer de renvoi (60 s)
- 👤 **Création de profil** (prénom, nom, email optionnel)
- 🔐 **Connexion** d'un utilisateur existant
- 🏠 **Tableau de bord** avec salutation personnalisée + cartes de statistiques
- 🧭 **Navigation principale** à 4 onglets (Accueil, Mes groupes, Paiements, Profil)
- 🔓 **Déconnexion** sécurisée avec confirmation
- 💾 **Persistance de session** via SharedPreferences (auto-reconnexion au lancement)

### Mode démo intégré 🎯
Aucun backend nécessaire pour tester :
- Le code OTP valide est **`123456`**
- Toutes les données utilisateur sont stockées localement
- Tu peux faire tout le parcours d'inscription → accueil sans serveur

### À venir (sprints suivants)
- 🔜 **Sprint 2** — Création et gestion des tontines (groupes, membres)
- 🔜 **Sprint 3** — Cotisations et cycles de paiement
- 🔜 **Sprint 4** — Intégration Mobile Money (Wave, Orange Money, MTN MoMo)
- 🔜 **Sprint 5** — Notifications push, paramètres avancés, finitions

---

## 🚀 Démarrage rapide

### Prérequis
- **Flutter SDK** ≥ 3.27.0 ([installer Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK** ≥ 3.6.0 (inclus avec Flutter)
- **Android Studio** ou **VS Code** avec l'extension Flutter
- Un émulateur Android, un simulateur iOS, ou un appareil physique

### 1️⃣ Vérifier l'installation Flutter

Ouvre un terminal et lance :
```bash
flutter doctor
```
Toutes les coches `[✓]` doivent être vertes pour Flutter, l'éditeur et au moins une plateforme cible (Android ou iOS).

### 2️⃣ Cloner / extraire le projet

Place le dossier `tontineapp/` dans ton workspace, puis :
```bash
cd tontineapp
```

### 3️⃣ Installer les dépendances
```bash
flutter pub get
```

### 4️⃣ Lancer l'application
```bash
flutter run
```
Sélectionne ton appareil dans la liste si plusieurs sont disponibles.

### 5️⃣ Tester le parcours
1. Au lancement, l'écran Splash s'affiche pendant 2 secondes
2. Tu arrives sur l'écran de **Connexion**
3. Clique sur **« Créer un compte »** en bas
4. Saisis un numéro de téléphone valide (ex. `07 07 97 82 18`)
5. Clique sur **Continuer** → écran OTP
6. Saisis le code **`123456`** (mode démo)
7. Renseigne ton prénom et nom → **Terminer**
8. 🎉 Tu arrives sur le tableau de bord !

---

## 🏗️ Architecture du projet

Le projet adopte une **Clean Architecture** combinée à une organisation **feature-first** :

```
tontineapp/
│
├── pubspec.yaml                  # Dépendances et configuration Flutter
├── analysis_options.yaml         # Règles du linter Dart
├── .gitignore                    # Fichiers ignorés par Git
├── README.md                     # Ce fichier
│
├── lib/                          # Tout le code Dart
│   │
│   ├── main.dart                 # 🚪 Point d'entrée
│   │
│   ├── core/                     # 🧱 Code transverse à toute l'application
│   │   ├── constantes/
│   │   │   ├── couleurs.dart     #   Palette ivoirienne (orange, vert, blanc)
│   │   │   ├── tailles.dart      #   Espacements, rayons, hauteurs
│   │   │   ├── chaines.dart      #   Chaînes de caractères centralisées
│   │   │   └── routes_noms.dart  #   Noms des routes nommées
│   │   ├── themes/
│   │   │   └── theme_app.dart    #   Thème Material 3
│   │   ├── routes/
│   │   │   └── routes_app.dart   #   Table de routes
│   │   ├── utils/
│   │   │   ├── validateurs.dart  #   Validateurs (téléphone, OTP, email)
│   │   │   └── formatteurs.dart  #   Formatteurs (FCFA, dates)
│   │   ├── erreurs/
│   │   │   └── exceptions.dart   #   Hiérarchie d'exceptions
│   │   └── entites/
│   │       └── utilisateur.dart  #   Modèle de domaine Utilisateur
│   │
│   ├── features/                 # 📦 Modules fonctionnels indépendants
│   │   │
│   │   ├── splash/
│   │   │   └── presentation/ecrans/splash_ecran.dart
│   │   │
│   │   ├── authentification/
│   │   │   ├── data/
│   │   │   │   └── repositories/auth_repository_demo.dart
│   │   │   ├── domaine/
│   │   │   │   └── contracts/auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── ecrans/
│   │   │       │   ├── inscription_ecran.dart
│   │   │       │   ├── verification_otp_ecran.dart
│   │   │       │   ├── creation_profil_ecran.dart
│   │   │       │   └── connexion_ecran.dart
│   │   │       └── providers/auth_provider.dart
│   │   │
│   │   └── accueil/
│   │       └── presentation/
│   │           ├── ecrans/
│   │           │   ├── accueil_principal_ecran.dart  # Hôte avec NavigationBar
│   │           │   ├── tableau_bord_ecran.dart       # Onglet 1
│   │           │   ├── mes_groupes_ecran.dart        # Onglet 2 (placeholder)
│   │           │   ├── paiements_ecran.dart          # Onglet 3 (placeholder)
│   │           │   └── profil_ecran.dart             # Onglet 4
│   │           └── widgets/
│   │               └── carte_statistique.dart
│   │
│   └── shared/                   # 🤝 Widgets et services partagés
│       └── widgets/
│           ├── bouton_primaire.dart
│           ├── champ_texte.dart
│           └── motif_kente.dart  # Motif géométrique inspiré du Kente
│
├── assets/
│   ├── images/                   # (Vide pour l'instant — Sprint 1 sans images)
│   └── fonts/                    # (Pour ajouter des polices custom plus tard)
│
└── test/
    └── widget_test.dart          # Test de fumée minimal
```

### Pourquoi cette structure ?

- **`core/`** contient ce qui est partagé entre toutes les features : couleurs, thème, validateurs, etc.
- **`features/`** isole chaque domaine fonctionnel. On peut ajouter `tontines/`, `paiements/`, `notifications/` sans toucher au reste.
- Chaque feature a 3 sous-couches :
  - **`data/`** — implémentations concrètes (API, BDD, mémoire)
  - **`domaine/`** — contrats, entités métier (indépendants de la techno)
  - **`presentation/`** — UI (écrans, providers, widgets spécifiques)
- **`shared/`** contient les widgets génériques utilisés par plusieurs features.

---

## 🎨 Identité visuelle

Inspirée du **drapeau de la Côte d'Ivoire** :
- 🟠 **Orange `#F77F00`** — couleur principale, énergie, dynamisme
- ⚪ **Blanc `#FFFFFF`** — neutralité, espaces, fond
- 🟢 **Vert `#009E60`** — succès, confirmations, croissance

Le **motif kente** sur le Splash apporte une touche d'authenticité africaine.

---

## 🛠️ Stack technique

| Catégorie         | Technologie                  |
|-------------------|------------------------------|
| Framework         | Flutter 3.27+                |
| Langage           | Dart 3.6+                    |
| Design system     | Material 3                   |
| Gestion d'état    | Provider                     |
| Stockage local    | shared_preferences           |
| OTP UI            | pin_code_fields              |
| Téléphone i18n    | intl_phone_field             |
| Internationalisation | intl                      |
| Linter            | flutter_lints                |

---

## 🧪 Lancer les tests
```bash
flutter test
```

---

## 📝 Conventions de code

- **Langue du code** : français (variables, classes, commentaires)
- **Nommage des fichiers** : `snake_case.dart`
- **Nommage des classes** : `PascalCase` en français (ex. `BoutonPrimaire`)
- **Nommage des variables** : `camelCase` en français (ex. `numeroTelephone`)
- **const partout où possible** (le linter le rappelle)
- **Trailing commas** obligatoires (le linter le rappelle)

---

## 🐛 Problèmes connus

- Si `flutter pub get` échoue, vérifie ta version de Flutter (`flutter --version`).
- Sur iOS, après `pub get`, il peut être nécessaire de lancer `cd ios && pod install && cd ..`.
- Le motif kente du Splash peut être lourd sur très anciens appareils — c'est volontairement décoratif.

---

## 📞 Contact projet

Application développée dans le cadre du projet **TontineApp** — digitalisation des tontines en Côte d'Ivoire.

🇨🇮 **Akwaba sur TontineApp !**
