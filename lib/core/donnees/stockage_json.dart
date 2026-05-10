import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Service centralisé de persistance JSON sur le système de fichiers local.
///
/// Stocke chaque "collection" dans un fichier `.json` séparé sous le
/// dossier "documents" de l'application (visible/invisible selon
/// la plateforme, mais toujours privé à l'app).
///
/// **Pourquoi JSON et pas SQLite ?**
/// - Cross-platform sans dépendances natives (Android, iOS, Windows desktop, web)
/// - Simple à inspecter (on peut ouvrir le fichier dans un éditeur)
/// - Largement suffisant pour le volume d'une tontine (quelques Mo max)
/// - Migration vers SQLite ultérieure possible si besoin
class StockageJson {
  StockageJson._interne();
  static final StockageJson _instance = StockageJson._interne();
  factory StockageJson() => _instance;

  Directory? _dossierCache;

  /// Récupère le dossier de stockage de l'application (cache).
  Future<Directory> _dossier() async {
    if (_dossierCache != null) return _dossierCache!;
    _dossierCache = await getApplicationDocumentsDirectory();
    return _dossierCache!;
  }

  Future<File> _fichier(String nomCollection) async {
    final dossier = await _dossier();
    return File('${dossier.path}/tontineapp_$nomCollection.json');
  }

  /// Sauvegarde une structure JSON-sérialisable dans une collection.
  ///
  /// Écrase le contenu existant. Crée le fichier si nécessaire.
  Future<void> sauvegarder(String nomCollection, Object donnees) async {
    final fichier = await _fichier(nomCollection);
    await fichier.writeAsString(jsonEncode(donnees), flush: true);
  }

  /// Charge le contenu d'une collection.
  ///
  /// Retourne `null` si le fichier n'existe pas ou est corrompu.
  Future<Object?> charger(String nomCollection) async {
    try {
      final fichier = await _fichier(nomCollection);
      if (!await fichier.exists()) return null;
      final contenu = await fichier.readAsString();
      if (contenu.trim().isEmpty) return null;
      return jsonDecode(contenu);
    } catch (_) {
      // Fichier corrompu : on retourne null, l'appelant ré-initialisera
      return null;
    }
  }

  /// Indique si une collection existe déjà sur le disque.
  Future<bool> existe(String nomCollection) async {
    final fichier = await _fichier(nomCollection);
    return fichier.exists();
  }

  /// Supprime une collection du disque (utile pour la fonction "Réinitialiser").
  Future<void> effacer(String nomCollection) async {
    final fichier = await _fichier(nomCollection);
    if (await fichier.exists()) {
      await fichier.delete();
    }
  }

  /// Efface **toutes** les collections de l'app (mode "factory reset").
  Future<void> effacerTout() async {
    final dossier = await _dossier();
    if (!await dossier.exists()) return;
    await for (final entite in dossier.list()) {
      if (entite is File &&
          entite.path.contains('tontineapp_') &&
          entite.path.endsWith('.json')) {
        await entite.delete();
      }
    }
  }
}
