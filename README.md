<div align="center">

# 📱 TontineApp

### Application mobile Flutter de digitalisation des tontines avec intégration Mobile Money pour la Côte d'Ivoire 🇨🇮

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![License](https://img.shields.io/badge/Licence-MIT-success?style=for-the-badge)](LICENSE)
[![Status](https://img.shields.io/badge/Statut-v1.0.0-orange?style=for-the-badge)]()

**Wave 🌊 · Orange Money 🟠 · MTN MoMo 🟡**

</div>

---

## 📖 À propos

**TontineApp** digitalise les **tontines** — un mécanisme d'épargne collective rotative ancré dans la culture financière ivoirienne, où chaque membre cotise régulièrement et reçoit à tour de rôle la totalité de la cagnotte.

L'application répond à trois problèmes du modèle traditionnel : la **traçabilité** (registres papier qui se perdent), la **confiance** (gestion manuelle propice aux litiges) et la **friction des paiements** (cash à transporter physiquement).

Elle propose une expérience mobile-first pensée pour le contexte ivoirien : interface en français, identité visuelle aux couleurs nationales, intégration des trois opérateurs Mobile Money dominants (Wave, Orange Money, MTN MoMo), et persistance locale pour fonctionner même en cas de connexion intermittente.

> ℹ️ **Note** : ce projet est un démonstrateur technique (POC). L'intégration Mobile Money est **simulée** via le pattern Strategy — l'architecture est prête à brancher de vraies API en production.

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription / connexion par numéro de téléphone (préfixe +225)
- Vérification OTP à 6 chiffres (mode démo : `123456`)
- Création de profil avec validation
- Session persistante via `SharedPreferences`

### 👥 Gestion des tontines
- Création de tontines avec montant, fréquence (hebdo/bi-mensuelle/mensuelle), date de début
- Invitation de membres par numéro
- Activation avec génération automatique du calendrier des tours
- Vue détaillée avec membres, calendrier, statistiques

### 💰 Cotisations
- Génération automatique des cotisations par tour
- Workflow de statuts : `attendue` → `payée` → `validée`
- Validation par l'administrateur (mode hors-ligne)
- Clôture automatique du tour quand toutes les cotisations sont validées

### 💸 Paiements Mobile Money
- Sélecteur d'opérateur avec habillage propre à chaque marque
- Flux de paiement complet : choix → saisie OTP → confirmation → reçu
- Auto-validation de la cotisation au succès du paiement
- Historique complet avec frais détaillés
- Codes de démo : OTP universel `1234`

### 🔔 Notifications
- Centre de notifications in-app avec badge de non-lues
- Notifications natives Android (`flutter_local_notifications`)
- Déclenchement automatique sur les événements importants (paiement, validation, clôture)

### 👤 Profil
- Modification du profil (prénom, nom, email)
- Statistiques personnelles enrichies (tontines actives, total cotisé, total reçu)
- Réinitialisation des données démo

---

## 📸 Captures d'écran

> 🚧 Captures à venir.

<!--
Une fois tes captures prêtes, remplace cette section par :

| Onboarding | Tableau de bord | Détail tour |
|:---:|:---:|:---:|
| ![Splash](assets/screenshots/01_splash.png) | ![Dashboard](assets/screenshots/02_dashboard.png) | ![Detail](assets/screenshots/03_detail_tour.png) |

| Choix opérateur | Confirmation Wave | Reçu de paiement |
|:---:|:---:|:---:|
| ![Operateur](assets/screenshots/04_choix_operateur.png) | ![Wave](assets/screenshots/05_wave_otp.png) | ![Recu](assets/screenshots/06_recu.png) |
-->

---

## 🏗️ Architecture

Le projet suit une **Clean Architecture feature-first** combinée à plusieurs design patterns clés :

```
lib/
├── core/                        # Couche transversale
│   ├── constantes/              # Couleurs, tailles, routes nommées, textes
│   ├── donnees/                 # Service de persistance JSON cross-platform
│   ├── entites/                 # Entités métier (Utilisateur, Tontine, Tour...)
│   ├── erreurs/                 # Hiérarchie d'exceptions métier
│   ├── routes/                  # Configuration de navigation
│   ├── themes/                  # Theme Material 3 personnalisé
│   └── utils/                   # Formatteurs (FCFA, dates) et validateurs
│
├── features/                    # Modules feature isolés
│   ├── authentification/        # Inscription, OTP, profil
│   ├── splash/                  # Écran de démarrage
│   ├── accueil/                 # Navigation principale (4 onglets)
│   ├── tontines/                # Création, gestion, membres, calendrier
│   ├── cotisations/             # Workflow des cotisations
│   ├── paiements/               # Mobile Money (Wave / OM / MTN)
│   └── notifications/           # Centre in-app + notifications natives
│
└── shared/                      # Composants UI réutilisables
    └── widgets/                 # Boutons, champs, cartes statistiques...
```

Chaque module **feature** est organisé en trois sous-couches :

```
features/<nom>/
├── domaine/                     # Contrats abstraits (interfaces) et entités spécifiques
│   ├── contracts/
│   └── entites/
├── data/                        # Implémentations concrètes
│   ├── repositories/            # Persistance JSON
│   └── services/                # Services techniques (notifs natives...)
└── presentation/                # UI et état
    ├── providers/               # ChangeNotifier (gestion d'état)
    ├── widgets/                 # Composants spécifiques au module
    └── ecrans/                  # Écrans complets
```

### Patterns appliqués

| Pattern | Où | Pourquoi |
|---|---|---|
| **Repository Pattern** | Chaque feature a son `XxxRepository` (contrat) + impl | Découple la logique métier de la persistance |
| **Strategy Pattern** | `OperateurMobileMoney` + 3 implémentations (Wave, OM, MTN) | Ajouter un nouvel opérateur ne touche pas le reste du code |
| **Provider Pattern** | Tous les états UI via `provider` package | Réactivité fine sans complexité de Bloc/Riverpod |
| **Proxy Provider** | `TontineProvider` dépend de `AuthProvider` | Compose les providers de manière déclarative |
| **Singleton** | Repositories `*Demo` | Une seule source de vérité en mémoire |

---

## 🛠️ Stack technique

- **Framework** : Flutter 3.27+
- **Langage** : Dart 3.6+ (null-safety, sealed/abstract classes)
- **State Management** : `provider`
- **Persistance** : JSON local via `path_provider` + sérialisation manuelle (`versJson` / `depuisJson`)
- **UI Kit** : Material 3 + thème personnalisé aux couleurs ivoiriennes
- **Notifications natives** : `flutter_local_notifications` + core library desugaring
- **Internationalisation** : `flutter_localizations` (FR par défaut)
- **Saisie spécialisée** : `intl_phone_field` (numéro CI), `pin_code_fields` (OTP)
- **Architecture** : Clean Architecture · Repository Pattern · Strategy Pattern

---

## 🚀 Installation et lancement

### Prérequis

- Flutter SDK ≥ 3.27 ([guide d'installation](https://docs.flutter.dev/get-started/install))
- Android Studio ou VS Code avec extension Flutter
- Émulateur Android (API 24+) ou appareil physique
- JDK 17

### Lancer le projet

```bash
# Cloner le repo
git clone https://github.com/Overlord-Oden/tontine-ci.git
cd tontine-ci

# Installer les dépendances
flutter pub get

# Lancer l'app sur un émulateur démarré
flutter run
```

### Permission Android pour les notifications

Sur Android 13+ (API 33+), assurez-vous que la permission `POST_NOTIFICATIONS` est déclarée dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Codes de démo

| Étape | Code |
|---|---|
| 🔐 Vérification OTP de connexion | `123456` |
| 💸 Confirmation paiement Mobile Money (Wave / OM / MTN) | `1234` |

---

## 🎯 Décisions techniques notables

### Pourquoi JSON et pas SQLite ?

Pour une app de tontine, les volumes restent modestes (quelques Mo max) et les requêtes sont simples (filtrer par utilisateur ou par tontine). La persistance JSON via `path_provider` offre :

- 🪶 Aucune dépendance native (Android, iOS, Windows desktop, web sans config)
- 🔍 Fichiers lisibles et inspectables pour debug
- 🧪 Plus simple à tester
- 🚀 Migration vers SQLite possible plus tard sans changer les contrats

### Pourquoi le pattern Strategy pour Mobile Money ?

Les trois opérateurs (Wave, Orange Money, MTN MoMo) ont des spécificités (frais, format OTP, branding) mais le **flux global est identique**. Une interface `OperateurMobileMoney` avec trois implémentations permet :

- ➕ Ajouter un nouvel opérateur = créer une nouvelle classe, rien d'autre
- 🔁 Remplacer la version simulée par une vraie API ne touche que la classe concernée
- 🧪 Mocker un opérateur en test est trivial

### Pourquoi pas de backend ?

Le scope du projet est volontairement **front-only** :
- ✅ Démontre une architecture mobile complète et maîtrisée
- ✅ Permet une démo offline immédiate
- ✅ Le backend est un projet à part entière (qui mériterait son propre repo)

L'architecture est prête à brancher un backend : chaque repository `*Demo` peut être remplacé par un `*Api` qui appelle des endpoints REST/GraphQL.

---

## 📊 Statistiques du projet

- 📁 **72 fichiers Dart**
- 📝 **~10 800 lignes de code**
- 🧩 **7 modules feature**
- 🎯 **5 sprints livrés** (Auth → Tontines → Cotisations → Persistance → Mobile Money → Notifications)

---

## 🗺️ Roadmap

Pistes d'évolution explorables :

- [ ] Intégration de vraies API Mobile Money (Wave, OM, MTN)
- [ ] Backend Node.js / Firebase pour la synchronisation multi-appareils
- [ ] Tests unitaires et d'intégration
- [ ] Mode sombre
- [ ] Internationalisation (anglais, langues locales)
- [ ] Export PDF des relevés de cotisation
- [ ] Notifications push via Firebase Cloud Messaging
- [ ] Signature numérique des accords de tontine

---

## 📄 Licence

Ce projet est distribué sous licence **MIT** — voir le fichier [LICENSE](LICENSE) pour les détails.

---

## 👤 Auteur

**Allassane Diomandé**

- 💼 LinkedIn : *[www.linkedin.com/in/
allassane-diomande-90281934a
]*
- 🐙 GitHub : [@Overlord-Oden](https://github.com/Overlord-Oden)
- 📍 Abidjan, Côte d'Ivoire 🇨🇮

---

<div align="center">

⭐ Si ce projet t'intéresse, n'hésite pas à laisser une étoile !

</div>
