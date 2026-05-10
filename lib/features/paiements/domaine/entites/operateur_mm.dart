import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';

/// Opérateurs Mobile Money supportés en Côte d'Ivoire.
enum OperateurMM {
  wave,
  orangeMoney,
  mtnMomo;

  /// Libellé court affiché à l'utilisateur.
  String get libelle {
    switch (this) {
      case OperateurMM.wave:
        return 'Wave';
      case OperateurMM.orangeMoney:
        return 'Orange Money';
      case OperateurMM.mtnMomo:
        return 'MTN MoMo';
    }
  }

  /// Libellé court pour les badges.
  String get codeCourt {
    switch (this) {
      case OperateurMM.wave:
        return 'WAVE';
      case OperateurMM.orangeMoney:
        return 'OM';
      case OperateurMM.mtnMomo:
        return 'MTN';
    }
  }

  /// Couleur principale de l'opérateur (charte officielle).
  Color get couleur {
    switch (this) {
      case OperateurMM.wave:
        return CouleursApp.wave;
      case OperateurMM.orangeMoney:
        return CouleursApp.orangeMoney;
      case OperateurMM.mtnMomo:
        return CouleursApp.mtnMoMo;
    }
  }

  /// Couleur du texte sur fond opérateur (contraste optimisé).
  Color get couleurTexte {
    switch (this) {
      case OperateurMM.wave:
      case OperateurMM.orangeMoney:
        return Colors.white;
      case OperateurMM.mtnMomo:
        return Colors.black87; // Le jaune MTN nécessite du texte sombre
    }
  }

  /// Surnom de l'opérateur (apparaît sur les écrans de saisie).
  String get baseline {
    switch (this) {
      case OperateurMM.wave:
        return 'L\'argent libre';
      case OperateurMM.orangeMoney:
        return 'L\'argent à portée';
      case OperateurMM.mtnMomo:
        return 'Y\'ello Mobile Money';
    }
  }

  /// Préfixe de numéro le plus courant pour cet opérateur en CI.
  String get prefixeIndicatif {
    switch (this) {
      case OperateurMM.wave:
        return ''; // Wave accepte tous les opérateurs
      case OperateurMM.orangeMoney:
        return '07';
      case OperateurMM.mtnMomo:
        return '05';
    }
  }

  /// Frais simulés (en pourcentage) — purement démo, valeurs cohérentes.
  double get tauxFrais {
    switch (this) {
      case OperateurMM.wave:
        return 0.01; // 1% — réputation du moins cher
      case OperateurMM.orangeMoney:
        return 0.015; // 1.5%
      case OperateurMM.mtnMomo:
        return 0.015;
    }
  }
}
