import '../../domaine/contracts/exception_paiement.dart';
import '../../domaine/contracts/operateur_mobile_money.dart';
import '../../domaine/entites/operateur_mm.dart';

/// Implémentation simulée de **MTN MoMo**.
///
/// MTN MoMo a une UX simple mais des temps réseau parfois plus longs.
class OperateurMtnMomoDemo implements OperateurMobileMoney {
  static const String _codeOtpDemo = '1234';

  @override
  OperateurMM get type => OperateurMM.mtnMomo;

  @override
  Future<ResultatInitiation> initierPaiement({
    required String numeroTelephone,
    required num montant,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return ResultatInitiation(
      referenceOperateur: _genererReference('MTN'),
      frais: calculerFrais(montant),
      dureeOtpSecondes: 90,
    );
  }

  @override
  Future<void> confirmerOtp({
    required String referenceOperateur,
    required String codeOtp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (codeOtp != _codeOtpDemo) {
      throw const ExceptionPaiement(
        'Code MTN MoMo incorrect. En mode démo, utilisez 1234.',
      );
    }
  }

  @override
  num calculerFrais(num montant) {
    return (montant * OperateurMM.mtnMomo.tauxFrais).ceil();
  }

  String _genererReference(String prefixe) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefixe${timestamp.toString().substring(6)}';
  }
}
