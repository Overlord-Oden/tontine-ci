import 'package:flutter/foundation.dart';

import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/exception_paiement.dart';
import '../../domaine/contracts/paiement_repository.dart';
import '../../domaine/entites/operateur_mm.dart';
import '../../domaine/entites/paiement.dart';

enum EtatPaiement {
  initial,
  enInitiation,
  attenteOtp,
  enTraitement,
  reussi,
  echec,
}

/// Provider qui pilote le flux de paiement Mobile Money en cours.
class PaiementProvider extends ChangeNotifier {
  final PaiementRepository _repository;

  PaiementProvider(this._repository);

  EtatPaiement _etat = EtatPaiement.initial;
  String? _messageErreur;
  Paiement? _paiementCourant;
  List<Paiement> _historique = const [];

  EtatPaiement get etat => _etat;
  String? get messageErreur => _messageErreur;
  Paiement? get paiementCourant => _paiementCourant;
  List<Paiement> get historique => _historique;

  bool get enChargement =>
      _etat == EtatPaiement.enInitiation ||
      _etat == EtatPaiement.enTraitement;

  void _changerEtat(EtatPaiement etat, {String? erreur}) {
    _etat = etat;
    _messageErreur = erreur;
    notifyListeners();
  }

  /// Réinitialise l'état (à appeler avant un nouveau paiement).
  void reinitialiser() {
    _paiementCourant = null;
    _changerEtat(EtatPaiement.initial);
  }

  /// Initie un paiement Mobile Money.
  Future<bool> initierPaiement({
    required String idCotisation,
    required String idTontine,
    required String idMembre,
    required String nomMembre,
    required OperateurMM operateur,
    required String numeroTelephoneMM,
    required num montant,
  }) async {
    _changerEtat(EtatPaiement.enInitiation);
    try {
      _paiementCourant = await _repository.initierPaiement(
        idCotisation: idCotisation,
        idTontine: idTontine,
        idMembre: idMembre,
        nomMembre: nomMembre,
        operateur: operateur,
        numeroTelephoneMM: numeroTelephoneMM,
        montant: montant,
      );
      _changerEtat(EtatPaiement.attenteOtp);
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatPaiement.echec, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatPaiement.echec, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Confirme l'OTP du paiement courant.
  Future<bool> confirmerOtp(String codeOtp) async {
    if (_paiementCourant == null) return false;

    _changerEtat(EtatPaiement.enTraitement);
    try {
      _paiementCourant = await _repository.confirmerOtp(
        idPaiement: _paiementCourant!.id,
        codeOtp: codeOtp,
      );
      _changerEtat(EtatPaiement.reussi);
      return true;
    } on ExceptionPaiement catch (e) {
      // L'OTP est faux : on retourne en attente OTP pour réessayer
      _changerEtat(EtatPaiement.attenteOtp, erreur: e.message);
      return false;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatPaiement.echec, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatPaiement.echec, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Annule le paiement en cours (avant confirmation OTP).
  Future<void> annulerPaiementCourant() async {
    if (_paiementCourant == null) return;
    try {
      await _repository.annulerPaiement(_paiementCourant!.id);
    } catch (_) {
      // On continue même en cas d'erreur d'annulation
    }
    reinitialiser();
  }

  /// Charge l'historique des paiements d'un membre.
  Future<void> chargerHistoriqueMembre(String idMembre) async {
    try {
      _historique = await _repository.listerPaiementsMembre(idMembre);
      notifyListeners();
    } catch (_) {
      _historique = const [];
      notifyListeners();
    }
  }
}
