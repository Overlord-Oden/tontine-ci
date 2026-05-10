import '../../domaine/contracts/exception_paiement.dart';
import '../../domaine/contracts/operateur_mobile_money.dart';
import '../../domaine/entites/operateur_mm.dart';

/// Implémentation simulée de **Wave**.
///
/// Wave est connu en CI pour des frais bas (~1%) et une UX rapide.
/// Cette implémentation reflète ces caractéristiques en mode démo.
class OperateurWaveDemo implements OperateurMobileMoney {
  static const String _codeOtpDemo = '1234';

  @override
  OperateurMM get type => OperateurMM.wave;

  @override
  Future<ResultatInitiation> initierPaiement({
    required String numeroTelephone,
    required num montant,
  }) async {
    // Wave est rapide : 600ms
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return ResultatInitiation(
      referenceOperateur: _genererReference('WV'),
      frais: calculerFrais(montant),
      dureeOtpSecondes: 90,
    );
  }

  @override
  Future<void> confirmerOtp({
    required String referenceOperateur,
    required String codeOtp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (codeOtp != _codeOtpDemo) {
      throw const ExceptionPaiement(
        'Code Wave incorrect. En mode démo, utilisez 1234.',
      );
    }
  }

  @override
  num calculerFrais(num montant) {
    return (montant * OperateurMM.wave.tauxFrais).ceil();
  }

  String _genererReference(String prefixe) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefixe${timestamp.toString().substring(6)}';
  }
}
