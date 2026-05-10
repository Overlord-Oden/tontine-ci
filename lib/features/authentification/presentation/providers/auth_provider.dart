import 'package:flutter/foundation.dart';

import '../../../../core/entites/utilisateur.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/auth_repository.dart';

/// Différents états possibles du flux d'authentification.
enum EtatAuth {
  initial,
  enChargement,
  succes,
  erreur,
}

/// Provider qui orchestre l'authentification de l'utilisateur.
///
/// Expose l'utilisateur courant, l'état du dernier appel,
/// et toutes les opérations (demande OTP, vérification, création profil).
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  // ─── État ───────────────────────────────────────────────────────
  EtatAuth _etat = EtatAuth.initial;
  String? _messageErreur;
  Utilisateur? _utilisateur;
  String? _numeroTelephoneEnCours;

  EtatAuth get etat => _etat;
  String? get messageErreur => _messageErreur;
  Utilisateur? get utilisateur => _utilisateur;
  String? get numeroTelephoneEnCours => _numeroTelephoneEnCours;
  bool get estConnecte => _utilisateur != null;
  bool get enChargement => _etat == EtatAuth.enChargement;

  // ─── Actions ────────────────────────────────────────────────────

  void _changerEtat(EtatAuth nouvelEtat, {String? erreur}) {
    _etat = nouvelEtat;
    _messageErreur = erreur;
    notifyListeners();
  }

  /// Récupère la session existante au démarrage de l'app.
  Future<void> chargerSessionExistante() async {
    _changerEtat(EtatAuth.enChargement);
    try {
      _utilisateur = await _repository.recupererSession();
      _changerEtat(EtatAuth.succes);
    } catch (e) {
      _changerEtat(EtatAuth.erreur, erreur: e.toString());
    }
  }

  /// Demande l'envoi d'un code OTP au numéro fourni.
  Future<bool> demanderOtp(String numeroTelephone) async {
    _changerEtat(EtatAuth.enChargement);
    try {
      await _repository.demanderOtp(numeroTelephone);
      _numeroTelephoneEnCours = numeroTelephone;
      _changerEtat(EtatAuth.succes);
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatAuth.erreur, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatAuth.erreur, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Vérifie le code OTP saisi par l'utilisateur.
  Future<bool> verifierOtp(String code) async {
    if (_numeroTelephoneEnCours == null) {
      _changerEtat(EtatAuth.erreur, erreur: 'Aucun numéro en cours');
      return false;
    }
    _changerEtat(EtatAuth.enChargement);
    try {
      await _repository.verifierOtp(
        numeroTelephone: _numeroTelephoneEnCours!,
        code: code,
      );
      _changerEtat(EtatAuth.succes);
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatAuth.erreur, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatAuth.erreur, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Finalise l'inscription en créant le profil de l'utilisateur.
  Future<bool> creerProfil({
    required String prenom,
    required String nom,
    String? email,
  }) async {
    if (_numeroTelephoneEnCours == null) {
      _changerEtat(EtatAuth.erreur, erreur: 'Aucun numéro en cours');
      return false;
    }
    _changerEtat(EtatAuth.enChargement);
    try {
      _utilisateur = await _repository.creerProfil(
        numeroTelephone: _numeroTelephoneEnCours!,
        prenom: prenom,
        nom: nom,
        email: email,
      );
      _changerEtat(EtatAuth.succes);
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatAuth.erreur, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatAuth.erreur, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Met à jour le profil de l'utilisateur courant.
  Future<bool> modifierProfil({
    required String prenom,
    required String nom,
    String? email,
  }) async {
    if (_utilisateur == null) return false;
    _changerEtat(EtatAuth.enChargement);
    try {
      _utilisateur = await _repository.modifierProfil(
        prenom: prenom,
        nom: nom,
        email: email,
      );
      _changerEtat(EtatAuth.succes);
      return true;
    } on ExceptionApp catch (e) {
      _changerEtat(EtatAuth.erreur, erreur: e.message);
      return false;
    } catch (_) {
      _changerEtat(EtatAuth.erreur, erreur: 'Erreur inattendue');
      return false;
    }
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> seDeconnecter() async {
    await _repository.seDeconnecter();
    _utilisateur = null;
    _numeroTelephoneEnCours = null;
    _changerEtat(EtatAuth.initial);
  }
}
