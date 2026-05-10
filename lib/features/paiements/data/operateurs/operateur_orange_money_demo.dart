import '../../domaine/contracts/exception_paiement.dart';
import '../../domaine/contracts/operateur_mobile_money.dart';
import '../../domaine/entites/operateur_mm.dart';

/// Implémentation simulée d'**Orange Money**.
///
/// Orange Money est l'opérateur historique en CI : flux plus formel,
/// frais ~1.5%, OTP à 4 chiffres envoyé par USSD/SMS.
class OperateurOrangeMoneyDemo implements OperateurMobileMoney {
  static const String _codeOtpDemo = '1234';

  @override
  OperateurMM get type => OperateurMM.orangeMoney;

  @override
  Future<ResultatInitiation> initierPaiement({
    required String numeroTelephone,
    required num montant,
  }) async {
    // Orange Money : flux un peu plus lent (réseau historique)
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return ResultatInitiation(
      referenceOperateur: _genererReference('OM'),
      frais: calculerFrais(montant),
      dureeOtpSecondes: 120,
    );
  }

  @override
  Future<void> confirmerOtp({
    required String referenceOperateur,
    required String codeOtp,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (codeOtp != _codeOtpDemo) {
      throw const ExceptionPaiement(
        'Code Orange Money incorrect. En mode démo, utilisez 1234.',
      );
    }
  }

  @override
  num calculerFrais(num montant) {
    return (montant * OperateurMM.orangeMoney.tauxFrais).ceil();
  }

  String _genererReference(String prefixe) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefixe${timestamp.toString().substring(6)}';
  }
}
