import '../../../../core/entites/cotisation.dart';

/// Contrat du repository des cotisations.
abstract class CotisationRepository {
  /// Récupère toutes les cotisations d'un tour.
  Future<List<Cotisation>> listerCotisationsTour(String idTour);

  /// Récupère les cotisations d'un membre (toutes tontines confondues).
  Future<List<Cotisation>> listerCotisationsMembre(String idMembre);

  /// Marque une cotisation comme payée par le membre.
  Future<Cotisation> marquerPayee(String idCotisation);

  /// Marque une cotisation comme validée par l'admin (paiement reçu).
  Future<Cotisation> validerCotisation(String idCotisation);

  /// Annule un paiement (repasse à "attendue").
  Future<Cotisation> annulerPaiement(String idCotisation);

  /// Vérifie si toutes les cotisations d'un tour sont validées.
  Future<bool> tourEstComplet(String idTour);
}
