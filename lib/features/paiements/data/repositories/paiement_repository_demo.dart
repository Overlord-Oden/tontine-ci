import '../../../../core/donnees/stockage_json.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../../cotisations/domaine/contracts/cotisation_repository.dart';
import '../../domaine/contracts/exception_paiement.dart';
import '../../domaine/contracts/operateur_mobile_money.dart';
import '../../domaine/contracts/paiement_repository.dart';
import '../../domaine/entites/operateur_mm.dart';
import '../../domaine/entites/paiement.dart';
import '../operateurs/operateur_mtn_momo_demo.dart';
import '../operateurs/operateur_orange_money_demo.dart';
import '../operateurs/operateur_wave_demo.dart';

/// Implémentation persistante du [PaiementRepository].
///
/// Délègue à la bonne implémentation [OperateurMobileMoney] (Wave,
/// Orange Money, MTN MoMo) selon le choix de l'utilisateur.
///
/// Lors d'un paiement réussi, met automatiquement à jour la cotisation
/// liée via [CotisationRepository] (statut → validée).
class PaiementRepositoryDemo implements PaiementRepository {
  PaiementRepositoryDemo._interne(this._cotisationRepo);

  static PaiementRepositoryDemo? _instance;
  factory PaiementRepositoryDemo(CotisationRepository cotisationRepo) {
    return _instance ??= PaiementRepositoryDemo._interne(cotisationRepo);
  }

  static const String _nomCollection = 'paiements';

  final StockageJson _stockage = StockageJson();
  final CotisationRepository _cotisationRepo;

  /// Map opérateur → strategy.
  final Map<OperateurMM, OperateurMobileMoney> _operateurs = {
    OperateurMM.wave: OperateurWaveDemo(),
    OperateurMM.orangeMoney: OperateurOrangeMoneyDemo(),
    OperateurMM.mtnMomo: OperateurMtnMomoDemo(),
  };

  List<Paiement> _paiements = [];
  bool _chargeDuDisque = false;

  Future<void> _chargerSiNecessaire() async {
    if (_chargeDuDisque) return;
    _chargeDuDisque = true;

    final brut = await _stockage.charger(_nomCollection);
    if (brut is List) {
      try {
        _paiements = brut
            .map((e) => Paiement.depuisJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _paiements = [];
      }
    }
  }

  Future<void> _sauvegarder() async {
    await _stockage.sauvegarder(
      _nomCollection,
      _paiements.map((p) => p.versJson()).toList(),
    );
  }

  // ─── Méthodes du contrat ──────────────────────────────────────────

  @override
  Future<Paiement> initierPaiement({
    required String idCotisation,
    required String idTontine,
    required String idMembre,
    required String nomMembre,
    required OperateurMM operateur,
    required String numeroTelephoneMM,
    required num montant,
  }) async {
    await _chargerSiNecessaire();

    final strategy = _operateurs[operateur];
    if (strategy == null) {
      throw const ExceptionInconnue('Opérateur non supporté');
    }

    final resultat = await strategy.initierPaiement(
      numeroTelephone: numeroTelephoneMM,
      montant: montant,
    );

    final paiement = Paiement(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      idCotisation: idCotisation,
      idTontine: idTontine,
      idMembre: idMembre,
      nomMembre: nomMembre,
      operateur: operateur,
      numeroTelephoneMM: numeroTelephoneMM,
      montant: montant,
      frais: resultat.frais,
      statut: StatutPaiement.enAttenteOtp,
      dateInitiation: DateTime.now(),
      referenceOperateur: resultat.referenceOperateur,
    );

    _paiements.add(paiement);
    await _sauvegarder();
    return paiement;
  }

  @override
  Future<Paiement> confirmerOtp({
    required String idPaiement,
    required String codeOtp,
  }) async {
    await _chargerSiNecessaire();

    final index = _paiements.indexWhere((p) => p.id == idPaiement);
    if (index == -1) {
      throw const ExceptionInconnue('Paiement introuvable');
    }
    final paiement = _paiements[index];

    if (paiement.statut != StatutPaiement.enAttenteOtp) {
      throw const ExceptionPaiement(
        'Ce paiement n\'est plus en attente d\'OTP',
      );
    }

    final strategy = _operateurs[paiement.operateur]!;

    // Phase 1 : passe en "en traitement"
    _paiements[index] = paiement.copierAvec(
      statut: StatutPaiement.enTraitement,
    );
    await _sauvegarder();

    // Phase 2 : appel à la strategy de l'opérateur
    try {
      await strategy.confirmerOtp(
        referenceOperateur: paiement.referenceOperateur!,
        codeOtp: codeOtp,
      );
    } on ExceptionPaiement catch (e) {
      // Échec : on enregistre puis on relance l'exception
      _paiements[index] = paiement.copierAvec(
        statut: StatutPaiement.echec,
        motifEchec: e.message,
        dateConfirmation: DateTime.now(),
      );
      await _sauvegarder();
      rethrow;
    }

    // Succès : on met à jour le paiement ET la cotisation liée
    final paiementReussi = paiement.copierAvec(
      statut: StatutPaiement.reussi,
      dateConfirmation: DateTime.now(),
    );
    _paiements[index] = paiementReussi;
    await _sauvegarder();

    // Effet de bord : marque la cotisation comme validée automatiquement
    try {
      await _cotisationRepo.validerCotisation(paiement.idCotisation);
    } catch (_) {
      // Si la cotisation est déjà validée, on ignore (idempotence)
    }

    return paiementReussi;
  }

  @override
  Future<Paiement> annulerPaiement(String idPaiement) async {
    await _chargerSiNecessaire();

    final index = _paiements.indexWhere((p) => p.id == idPaiement);
    if (index == -1) {
      throw const ExceptionInconnue('Paiement introuvable');
    }
    final paiement = _paiements[index];

    if (paiement.statut.estTermine) {
      throw const ExceptionPaiement(
        'Ce paiement est déjà finalisé, impossible de l\'annuler',
      );
    }

    final annule = paiement.copierAvec(
      statut: StatutPaiement.annule,
      dateConfirmation: DateTime.now(),
    );
    _paiements[index] = annule;
    await _sauvegarder();
    return annule;
  }

  @override
  Future<List<Paiement>> listerPaiementsMembre(String idMembre) async {
    await _chargerSiNecessaire();
    final mes = _paiements.where((p) => p.idMembre == idMembre).toList()
      ..sort((a, b) => b.dateInitiation.compareTo(a.dateInitiation));
    return mes;
  }

  @override
  Future<List<Paiement>> listerPaiementsTontine(String idTontine) async {
    await _chargerSiNecessaire();
    return _paiements.where((p) => p.idTontine == idTontine).toList()
      ..sort((a, b) => b.dateInitiation.compareTo(a.dateInitiation));
  }
}
