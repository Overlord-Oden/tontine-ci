import '../constantes/chaines.dart';

/// Collection de validateurs réutilisables pour les formulaires.
///
/// Chaque validateur retourne `null` si la valeur est valide,
/// ou un message d'erreur (String) sinon.
class Validateurs {
  Validateurs._();

  /// Champ obligatoire (non vide après trim).
  static String? obligatoire(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return ChainesApp.erreurChampObligatoire;
    }
    return null;
  }

  /// Numéro de téléphone ivoirien.
  ///
  /// Format attendu après nettoyage : 10 chiffres commençant par 0
  /// (ex : 0707978218) ou format international 225 + 10 chiffres.
  static String? telephoneIvoirien(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return ChainesApp.erreurChampObligatoire;
    }
    final nettoye = valeur.replaceAll(RegExp(r'[^0-9]'), '');
    // Accepte 10 chiffres (national) ou 13 chiffres (avec 225)
    if (nettoye.length != 10 && nettoye.length != 13) {
      return ChainesApp.erreurTelephoneInvalide;
    }
    return null;
  }

  /// Code OTP : exactement 6 chiffres.
  static String? otp(String? valeur) {
    if (valeur == null || valeur.length != 6) {
      return ChainesApp.erreurOtpInvalide;
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(valeur)) {
      return ChainesApp.erreurOtpInvalide;
    }
    return null;
  }

  /// Email — vide accepté (champ optionnel), sinon doit être valide.
  static String? emailOptionnel(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w.\-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!regex.hasMatch(valeur.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  /// Prénom / nom : au moins 2 caractères, lettres uniquement.
  static String? nom(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return ChainesApp.erreurChampObligatoire;
    }
    if (valeur.trim().length < 2) {
      return 'Au moins 2 caractères';
    }
    return null;
  }
}
