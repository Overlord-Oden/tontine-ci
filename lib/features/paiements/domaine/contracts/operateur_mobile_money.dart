import '../entites/operateur_mm.dart';

/// Résultat d'une initiation de paiement par un opérateur.
class ResultatInitiation {
  final String referenceOperateur;
  final num frais;
  final int dureeOtpSecondes;

  const ResultatInitiation({
    required this.referenceOperateur,
    required this.frais,
    required this.dureeOtpSecondes,
  });
}

/// Contrat **Strategy** pour intégrer un opérateur Mobile Money.
///
/// Chaque implémentation (Wave, Orange Money, MTN MoMo) suit le même
/// flux mais peut avoir des spécificités (frais, format OTP, durée…).
///
/// **Mode démo** : toutes les implémentations actuelles sont simulées
/// (pas d'appel réseau). Elles seront remplacées par des intégrations
/// API réelles dans une version production sans toucher au reste du code.
abstract class OperateurMobileMoney {
  /// L'opérateur que cette stratégie représente.
  OperateurMM get type;

  /// Initie un paiement vers cet opérateur.
  ///
  /// En mode démo : retourne immédiatement une référence et déclenche
  /// (côté UI) la saisie OTP.
  ///
  /// En production : appellerait l'API de l'opérateur pour déclencher
  /// l'envoi du SMS OTP.
  Future<ResultatInitiation> initierPaiement({
    required String numeroTelephone,
    required num montant,
  });

  /// Vérifie l'OTP saisi par l'utilisateur.
  ///
  /// En mode démo : `1234` est toujours valide.
  /// Lève [ExceptionPaiement] sinon.
  Future<void> confirmerOtp({
    required String referenceOperateur,
    required String codeOtp,
  });

  /// Calcule les frais pour un montant donné.
  num calculerFrais(num montant);
}
