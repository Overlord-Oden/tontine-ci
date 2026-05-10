import 'package:flutter/foundation.dart';

import '../../../../core/entites/cotisation.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/cotisation_repository.dart';

enum EtatCotisations {
  initial,
  enChargement,
  succes,
  erreur,
}

/// Provider qui orchestre les cotisations d'un tour donné.
///
/// Tient à jour la liste des cotisations + offre les actions
/// (marquer payée, valider, annuler) avec rafraîchissement automatique.
class CotisationProvider extends ChangeNotifier {
  final CotisationRepository _repository;

  CotisationProvider(this._repository);

  EtatCotisations _etat = EtatCotisations.initial;
  String? _messageErreur;
  List<Cotisation> _cotisations = const [];
  String? _idTourCourant;

  EtatCotisations get etat => _etat;
  String? get messageErreur => _messageErreur;
  List<Cotisation> get cotisations => _cotisations;
  bool get enChargement => _etat == EtatCotisations.enChargement;

  /// Cotisations à payer (non encore réglées et hors bénéficiaire).
  List<Cotisation> get aPayer => _cotisations
      .where(
        (c) => !c.estBeneficiaire && c.statut == StatutCotisation.attendue,
      )
      .toList();

  /// Cotisations payées en attente de validation par l'admin.
  List<Cotisation> get enAttenteValidation => _cotisations
      .where((c) => c.statut == StatutCotisation.payee)
      .toList();

  /// Cotisations validées.
  List<Cotisation> get validees => _cotisations
      .where((c) => c.statut == StatutCotisation.validee)
      .toList();

  /// Pourcentage de complétion du tour (0.0 à 1.0).
  double get progression {
    final aRegler = _cotisations.where((c) => !c.estBeneficiaire).length;
    if (aRegler == 0) return 0;
    return validees.length / aRegler;
  }

  void _changerEtat(EtatCotisations etat, {String? erreur}) {
    _etat = etat;
    _messageErreur = erreur;
    notifyListeners();
  }

  /// Charge les cotisations d'un tour.
  Future<void> chargerCotisationsTour(String idTour) async {
    _idTourCourant = idTour;
    _changerEtat(EtatCotisations.enChargement);
    try {
      _cotisations = await _repository.listerCotisationsTour(idTour);
      _changerEtat(EtatCotisations.succes);
    } on ExceptionApp catch (e) {
      _changerEtat(EtatCotisations.erreur, erreur: e.message);
    } catch (_) {
      _changerEtat(EtatCotisations.erreur, erreur: 'Erreur inattendue');
    }
  }

  /// Trouve la cotisation d'un membre donné dans la liste actuelle.
  Cotisation? cotisationDuMembre(String idMembre) {
    try {
      return _cotisations.firstWhere((c) => c.idMembre == idMembre);
    } catch (_) {
      return null;
    }
  }

  /// Marque une cotisation comme payée (en mode démo, action du membre).
  Future<bool> marquerPayee(String idCotisation) async {
    try {
      await _repository.marquerPayee(idCotisation);
      await _rafraichir();
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatCotisations.erreur, erreur: e.message);
      return false;
    }
  }

  /// Valide une cotisation (action de l'admin).
  Future<bool> validerCotisation(String idCotisation) async {
    try {
      await _repository.validerCotisation(idCotisation);
      await _rafraichir();
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatCotisations.erreur, erreur: e.message);
      return false;
    }
  }

  /// Annule un paiement (action de l'admin si paiement contesté).
  Future<bool> annulerPaiement(String idCotisation) async {
    try {
      await _repository.annulerPaiement(idCotisation);
      await _rafraichir();
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatCotisations.erreur, erreur: e.message);
      return false;
    }
  }

  /// Vérifie si le tour courant est totalement complet.
  Future<bool> tourEstComplet() async {
    if (_idTourCourant == null) return false;
    return _repository.tourEstComplet(_idTourCourant!);
  }

  Future<void> _rafraichir() async {
    if (_idTourCourant == null) return;
    _cotisations =
        await _repository.listerCotisationsTour(_idTourCourant!);
    _changerEtat(EtatCotisations.succes);
  }
}
