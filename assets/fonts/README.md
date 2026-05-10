# Dossier fonts

Pour ajouter une police personnalisée (par exemple, une typographie
plus typée africaine), placez les fichiers .ttf ici puis déclarez-les
dans `pubspec.yaml` :

```yaml
flutter:
  fonts:
    - family: MaPolice
      fonts:
        - asset: assets/fonts/MaPolice-Regular.ttf
        - asset: assets/fonts/MaPolice-Bold.ttf
          weight: 700
```

Pour le Sprint 1, on utilise la police système Roboto par défaut.
