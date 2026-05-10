/// Noms des routes nommées utilisées dans l'application.
class RoutesNoms {
  RoutesNoms._();

  // ─── Onboarding & Auth ──────────────────────────────────────────
  static const String splash = '/';
  static const String inscription = '/inscription';
  static const String verificationOtp = '/verification-otp';
  static const String creationProfil = '/creation-profil';
  static const String connexion = '/connexion';
  static const String editionProfil = '/edition-profil'; // Sprint 5

  // ─── Accueil principal ──────────────────────────────────────────
  static const String accueilPrincipal = '/accueil';

  // ─── Tontines (Sprint 2) ────────────────────────────────────────
  static const String creerTontine = '/tontines/creer';
  static const String detailTontine = '/tontines/detail';

  // ─── Cotisations (Sprint 3) ─────────────────────────────────────
  static const String detailTour = '/tours/detail';

  // ─── Paiements Mobile Money (Sprint 4b) ─────────────────────────
  static const String choixOperateur = '/paiements/choix-operateur';
  static const String confirmationPaiement = '/paiements/confirmation';
  static const String recuPaiement = '/paiements/recu';

  // ─── Notifications (Sprint 5) ───────────────────────────────────
  static const String notifications = '/notifications';
}
