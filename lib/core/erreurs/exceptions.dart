/// Hiérarchie d'exceptions de l'application.
///
/// Toutes les erreurs métier héritent d'[ExceptionApp].
/// Cela facilite la gestion centralisée des erreurs.
abstract class ExceptionApp implements Exception {
  final String message;
  const ExceptionApp(this.message);

  @override
  String toString() => message;
}

/// Erreur d'authentification (OTP invalide, session expirée…)
class ExceptionAuth extends ExceptionApp {
  const ExceptionAuth(super.message);
}

/// Erreur de réseau (pas de connexion, timeout…)
class ExceptionReseau extends ExceptionApp {
  const ExceptionReseau(super.message);
}

/// Erreur de validation côté serveur.
class ExceptionValidation extends ExceptionApp {
  const ExceptionValidation(super.message);
}

/// Erreur générique inconnue.
class ExceptionInconnue extends ExceptionApp {
  const ExceptionInconnue(super.message);
}
