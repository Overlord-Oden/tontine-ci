# 📦 Sprint 5 — Notifications, profil, stats, finitions ✨

> Le sprint final ! Notifications natives + centre de notifications +
> édition profil + stats personnelles enrichies.

---

## 📋 Contenu (20 fichiers)

### 🆕 Nouveaux fichiers (10)

**Module notifications complet** (8) :
- `lib/features/notifications/domaine/entites/notification_app.dart`
- `lib/features/notifications/domaine/contracts/notification_repository.dart`
- `lib/features/notifications/data/services/service_notifications_natives.dart`
- `lib/features/notifications/data/repositories/notification_repository_demo.dart`
- `lib/features/notifications/presentation/providers/notification_provider.dart`
- `lib/features/notifications/presentation/widgets/ligne_notification.dart`
- `lib/features/notifications/presentation/widgets/icone_cloche.dart`
- `lib/features/notifications/presentation/ecrans/notifications_ecran.dart`

**Édition profil + stats** (2) :
- `lib/features/authentification/presentation/ecrans/edition_profil_ecran.dart`
- `lib/shared/widgets/carte_stat_riche.dart`

### ✏️ Fichiers modifiés (10)

- `pubspec.yaml` — ajout de `flutter_local_notifications`
- `lib/main.dart` — init notifs natives + nouveau provider
- `lib/core/constantes/routes_noms.dart` — 2 nouvelles routes
- `lib/core/routes/routes_app.dart` — table mise à jour
- `lib/features/authentification/domaine/contracts/auth_repository.dart` — `modifierProfil`
- `lib/features/authentification/data/repositories/auth_repository_demo.dart` — implémentation
- `lib/features/authentification/presentation/providers/auth_provider.dart` — méthode publique
- `lib/features/accueil/presentation/ecrans/profil_ecran.dart` — stats riches + édition
- `lib/features/accueil/presentation/ecrans/tableau_bord_ecran.dart` — cloche dynamique
- `lib/features/paiements/presentation/ecrans/confirmation_paiement_ecran.dart` — notif au paiement réussi

---

## 🚀 Comment appliquer

### 1️⃣ Sauvegarde Sprint 4b
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects
xcopy tontineapp tontineapp_sprint4b_backup /E /I /Q
```

### 2️⃣ Extrais le ZIP, copie tout dans `tontineapp/` → **« Remplacer »**

### 3️⃣ Récupère la nouvelle dépendance
```powershell
cd C:\Users\Allassane_Diomande\StudioProjects\tontineapp
flutter pub get
```

### 4️⃣ ⚠️ IMPORTANT — Permission Android pour les notifications

Sur Android 13+ (API 33+), il faut déclarer la permission de notification.

Ouvre le fichier :
```
android\app\src\main\AndroidManifest.xml
```

Et ajoute cette ligne **juste avant la balise `<application>`** (au niveau de `<manifest>`) :

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Exemple de structure :
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />  <!-- AJOUTER ICI -->

    <application ...>
        ...
```

> 💡 Sans cette permission, les notifications natives n'apparaissent pas sur Android 13+. Les notifications **in-app** (cloche dans l'app) fonctionnent quand même.

### 5️⃣ Lance
```powershell
flutter run
```

> Au premier lancement, Android te demandera **« TontineApp veut t'envoyer des notifications »**. Accepte.

---

## 🎬 Le scénario à tester

### Test 1 — Notifications natives 🔔

1. Lance l'app, autorise les notifications quand on te demande
2. Va sur une cotisation à payer → **Payer via Wave** → OTP `1234`
3. Regarde en haut de ton écran : **une notification système Android** s'affiche : *« Paiement réussi 💸 »*
4. La cloche dans l'app prend une **pastille rouge avec « 1 »**

### Test 2 — Centre de notifications

1. Tape sur la **cloche** en haut de l'onglet Accueil
2. Tu vois la liste de tes notifications avec :
   - Icônes colorées par type
   - Date relative (« il y a 2 min »)
   - Pastille orange pour celles non lues
3. **Swipe à gauche** sur une notification pour la supprimer
4. Bouton **« Tout marquer lu »** en haut à droite
5. Menu **⋮ → Tout effacer**

### Test 3 — Édition du profil ✏️

1. Onglet **Profil** → tape sur **« Modifier mon profil »**
2. Modifie ton prénom, nom, ou ajoute un email
3. Clique **« Enregistrer les modifications »**
4. ✅ Snackbar de succès, retour au profil avec les nouvelles infos
5. **Ferme et relance l'app** → les modifications sont **persistées** 💾

### Test 4 — Stats personnelles 📊

Sur l'onglet **Profil**, tu vois maintenant 3 cartes :
- 🟠 **Tontines actives** (compteur)
- 🔵 **Total cotisé via Mobile Money** (somme des paiements réussis)
- 🟢 **Total reçu** (cagnottes des tours terminés où tu es bénéficiaire)

Plus tu fais de paiements, plus le total augmente.

---

## 🧠 Architecture

Le **module notifications** suit la même Clean Architecture que les autres :

```
notifications/
├── domaine/           ← Métier pur (entités + contrats)
│   ├── entites/notification_app.dart
│   └── contracts/notification_repository.dart
├── data/              ← Implémentations concrètes
│   ├── repositories/notification_repository_demo.dart  (persistance JSON)
│   └── services/service_notifications_natives.dart      (Android/iOS)
└── presentation/      ← UI
    ├── providers/notification_provider.dart
    ├── widgets/{ligne,icone_cloche}
    └── ecrans/notifications_ecran.dart
```

**Le pattern intéressant** : le repo persiste en JSON ET déclenche en parallèle la notif native système. Une seule API publique (`creer()`) pour les deux effets.

```dart
final notif = NotificationApp(...);
_notifications.insert(0, notif);     // 1. Persiste
await _sauvegarder();
_serviceNatif.afficher(...);          // 2. Notification système
```

---

## 🎓 Pour ton mémoire — conclusion

Avec ce sprint, tu as maintenant un **produit complet** avec tous les éléments d'une vraie app moderne :

| Couche | Implémentation |
|---|---|
| **UI/UX** | Material 3, identité ivoirienne, animations, empty states |
| **Architecture** | Clean Architecture + Feature-First, Repository Pattern, Strategy |
| **Gestion d'état** | Provider, ChangeNotifierProxyProvider |
| **Persistance** | JSON cross-platform (path_provider) |
| **Notifications** | In-app + natives système (flutter_local_notifications) |
| **Mobile Money** | 3 opérateurs simulés (Wave, OM, MTN) avec habillage propre |
| **i18n** | flutter_localizations FR pour tous les composants natifs |

**Stats finales du projet** :
- **72 fichiers Dart**
- **~10 800 lignes**
- **6 modules feature** : auth, splash, accueil, tontines, cotisations, paiements, notifications
- **5 sprints livrés** sur 5 prévus 🎯

---

## 🐛 En cas de problème

| Symptôme | Solution |
|---|---|
| `Could not find package "flutter_local_notifications"` | `flutter pub get` |
| Pas de notification native sur Android 13+ | Ajoute la permission `POST_NOTIFICATIONS` dans AndroidManifest.xml (étape 4) |
| Build Android échoue | Stop, supprime `build/` puis `flutter clean` puis `flutter run` |
| Les notifications n'apparaissent pas | Vérifie dans Paramètres Android → TontineApp → Notifications que c'est activé |

---

🎉 **C'est terminé !** Tu as maintenant ton appli complète, prête pour la soutenance. 🇨🇮💪🏾
