/// Centralise toutes les chaînes de l'application.
///
/// Permet de préparer une éventuelle internationalisation
/// et d'éviter les chaînes magiques dans le code.
class ChainesApp {
  ChainesApp._();

  // ─── Application ────────────────────────────────────────────────
  static const String nomApp = 'TontineApp';
  static const String slogan = 'La tontine en confiance';

  // ─── Splash ─────────────────────────────────────────────────────
  static const String splashTagline = 'La tontine, version moderne';

  // ─── Onboarding / Inscription ───────────────────────────────────
  static const String inscriptionTitre = 'Créer un compte';
  static const String inscriptionSousTitre =
      'Entrez votre numéro de téléphone pour commencer';
  static const String champTelephone = 'Numéro de téléphone';
  static const String boutonContinuer = 'Continuer';
  static const String boutonSuivant = 'Suivant';

  static const String dejaCompte = 'Déjà un compte ?';
  static const String seConnecter = 'Se connecter';
  static const String pasDeCompte = 'Pas encore de compte ?';
  static const String creerCompte = 'Créer un compte';

  // ─── OTP ────────────────────────────────────────────────────────
  static const String otpTitre = 'Vérification';
  static const String otpSousTitre =
      'Saisissez le code à 6 chiffres envoyé au';
  static const String otpAideDemo =
      'Mode démo : utilisez le code 123456';
  static const String renvoyerCode = 'Renvoyer le code';
  static const String dansSecondes = 'dans %d s';

  // ─── Création de profil ─────────────────────────────────────────
  static const String profilTitre = 'Votre profil';
  static const String profilSousTitre =
      'Ces informations seront visibles par les membres de vos tontines';
  static const String champPrenom = 'Prénom';
  static const String champNom = 'Nom';
  static const String champEmail = 'Email (optionnel)';
  static const String boutonTerminer = 'Terminer';

  // ─── Connexion ──────────────────────────────────────────────────
  static const String connexionTitre = 'Bon retour !';
  static const String connexionSousTitre =
      'Entrez votre numéro de téléphone pour vous connecter';

  // ─── Accueil ────────────────────────────────────────────────────
  static const String accueilSalutation = 'Akwaba';
  static const String accueilTontinesActives = 'Tontines actives';
  static const String accueilCotisationsEnAttente = 'Cotisations en attente';
  static const String accueilTotalEpargne = 'Total épargné';

  // ─── Navigation ─────────────────────────────────────────────────
  static const String navAccueil = 'Accueil';
  static const String navMesGroupes = 'Mes groupes';
  static const String navPaiements = 'Paiements';
  static const String navProfil = 'Profil';

  // ─── Erreurs ────────────────────────────────────────────────────
  static const String erreurChampObligatoire = 'Ce champ est obligatoire';
  static const String erreurTelephoneInvalide =
      'Numéro de téléphone invalide';
  static const String erreurOtpInvalide = 'Code OTP incorrect';
  static const String erreurReseau = 'Erreur réseau, veuillez réessayer';
  static const String erreurInconnue =
      'Une erreur est survenue, veuillez réessayer';

  // ─── Succès ─────────────────────────────────────────────────────
  static const String succesInscription = 'Compte créé avec succès !';
  static const String succesConnexion = 'Connexion réussie';
}
