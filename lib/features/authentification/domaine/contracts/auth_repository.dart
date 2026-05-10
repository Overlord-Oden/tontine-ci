import '../../../../core/entites/utilisateur.dart';

/// Contrat de la couche d'authentification.
///
/// Définit les opérations métier indépendamment de l'implémentation
/// (démo en mémoire, API REST, Firebase…).
abstract class AuthRepository {
  /// Demande l'envoi d'un code OTP au numéro fourni.
  ///
  /// Retourne `true` si l'envoi est effectué.
  /// Lève [ExceptionReseau] en cas d'échec.
  Future<bool> demanderOtp(String numeroTelephone);

  /// Vérifie le code OTP saisi par l'utilisateur.
  ///
  /// Retourne `true` si le code est correct.
  /// Lève [ExceptionAuth] si le code est incorrect.
  Future<bool> verifierOtp({
    required String numeroTelephone,
    required String code,
  });

  /// Crée le profil de l'utilisateur après vérification OTP.
  Future<Utilisateur> creerProfil({
    required String numeroTelephone,
    required String prenom,
    required String nom,
    String? email,
  });

  /// Vérifie si une session est déjà active.
  ///
  /// Retourne l'utilisateur courant ou `null`.
  Future<Utilisateur?> recupererSession();

  /// Met à jour le profil de l'utilisateur courant.
  Future<Utilisateur> modifierProfil({
    required String prenom,
    required String nom,
    String? email,
  });

  /// Termine la session courante.
  Future<void> seDeconnecter();
}
