import 'package:flutter/foundation.dart';

import '../../../../core/entites/membre.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/tontine_repository.dart';

enum EtatTontines {
  initial,
  enChargement,
  succes,
  erreur,
}

/// Provider qui gère la liste des tontines de l'utilisateur courant
/// et fournit les opérations de création, invitation, activation.
class TontineProvider extends ChangeNotifier {
  final TontineRepository _repository;

  TontineProvider(this._repository);

  EtatTontines _etat = EtatTontines.initial;
  String? _messageErreur;
  List<Tontine> _tontines = const [];
  String? _idUtilisateurCourant;

  EtatTontines get etat => _etat;
  String? get messageErreur => _messageErreur;
  List<Tontine> get tontines => _tontines;
  bool get enChargement => _etat == EtatTontines.enChargement;

  /// Filtre les tontines par statut.
  List<Tontine> tontinesParStatut(StatutTontine statut) =>
      _tontines.where((t) => t.statut == statut).toList();

  /// Nombre de cotisations en attente de l'utilisateur courant
  /// (pour les tours en cours de ses tontines actives).
  int get cotisationsEnAttente {
    int total = 0;
    for (final t in _tontines.where((t) => t.statut == StatutTontine.active)) {
      final tourEnCours = t.tourEnCours;
      if (tourEnCours == null) continue;
      // Si l'utilisateur n'est pas le bénéficiaire, il doit cotiser
      final membreCourant = t.membres.firstWhere(
        (m) => m.idUtilisateur == _idUtilisateurCourant,
        orElse: () => t.membres.first,
      );
      if (membreCourant.id != tourEnCours.idMembreBeneficiaire) {
        total++;
      }
    }
    return total;
  }

  /// Total déjà épargné (cotisations versées sur les tours terminés).
  num get totalEpargne {
    num total = 0;
    for (final t in _tontines) {
      total += t.toursTermines.length * t.montantCotisation;
    }
    return total;
  }

  void _changerEtat(EtatTontines etat, {String? erreur}) {
    _etat = etat;
    _messageErreur = erreur;
    notifyListeners();
  }

  /// Charge les tontines de l'utilisateur courant.
  Future<void> chargerMesTontines(String idUtilisateur) async {
    _idUtilisateurCourant = idUtilisateur;
    _changerEtat(EtatTontines.enChargement);
    try {
      _tontines = await _repository.listerMesTontines(idUtilisateur);
      _changerEtat(EtatTontines.succes);
    } on ExceptionApp catch (e) {
      _changerEtat(EtatTontines.erreur, erreur: e.message);
    } catch (_) {
      _changerEtat(EtatTontines.erreur, erreur: 'Erreur inattendue');
    }
  }

  /// Récupère le détail d'une tontine.
  Future<Tontine?> obtenirTontine(String idTontine) async {
    try {
      return await _repository.obtenirTontine(idTontine);
    } catch (_) {
      return null;
    }
  }

  /// Crée une nouvelle tontine.
  Future<Tontine?> creerTontine({
    required String nom,
    String? description,
    required num montantCotisation,
    required FrequenceCotisation frequence,
    required DateTime dateDebut,
    required String idCreateur,
    required String nomCreateur,
    required String numeroTelephoneCreateur,
  }) async {
    _changerEtat(EtatTontines.enChargement);
    try {
      final tontine = await _repository.creerTontine(
        nom: nom,
        description: description,
        montantCotisation: montantCotisation,
        frequence: frequence,
        dateDebut: dateDebut,
        idCreateur: idCreateur,
        nomCreateur: nomCreateur,
        numeroTelephoneCreateur: numeroTelephoneCreateur,
      );
      _tontines = [..._tontines, tontine];
      _changerEtat(EtatTontines.succes);
      return tontine;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatTontines.erreur, erreur: e.message);
      return null;
    } catch (_) {
      _changerEtat(EtatTontines.erreur, erreur: 'Erreur inattendue');
      return null;
    }
  }

  /// Invite un nouveau membre dans une tontine.
  Future<Membre?> inviterMembre({
    required String idTontine,
    required String numeroTelephone,
    required String nomAffichage,
  }) async {
    try {
      final membre = await _repository.inviterMembre(
        idTontine: idTontine,
        numeroTelephone: numeroTelephone,
        nomAffichage: nomAffichage,
      );
      // Rafraîchit la liste locale
      if (_idUtilisateurCourant != null) {
        await chargerMesTontines(_idUtilisateurCourant!);
      }
      return membre;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatTontines.erreur, erreur: e.message);
      return null;
    }
  }

  /// Retire un membre d'une tontine.
  Future<bool> retirerMembre({
    required String idTontine,
    required String idMembre,
  }) async {
    try {
      await _repository.retirerMembre(
        idTontine: idTontine,
        idMembre: idMembre,
      );
      if (_idUtilisateurCourant != null) {
        await chargerMesTontines(_idUtilisateurCourant!);
      }
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatTontines.erreur, erreur: e.message);
      return false;
    }
  }

  /// Active une tontine (brouillon → active).
  Future<Tontine?> activerTontine(String idTontine) async {
    try {
      final tontine = await _repository.activerTontine(idTontine);
      if (_idUtilisateurCourant != null) {
        await chargerMesTontines(_idUtilisateurCourant!);
      }
      return tontine;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatTontines.erreur, erreur: e.message);
      return null;
    }
  }
}
