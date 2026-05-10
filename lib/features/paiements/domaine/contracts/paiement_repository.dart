import '../entites/operateur_mm.dart';
import '../entites/paiement.dart';

/// Contrat du repository des paiements Mobile Money.
abstract class PaiementRepository {
  /// Initie un nouveau paiement Mobile Money.
  ///
  /// Retourne un [Paiement] en statut [StatutPaiement.enAttenteOtp]
  /// avec une référence opérateur.
  Future<Paiement> initierPaiement({
    required String idCotisation,
    required String idTontine,
    required String idMembre,
    required String nomMembre,
    required OperateurMM operateur,
    required String numeroTelephoneMM,
    required num montant,
  });

  /// Confirme un paiement avec son OTP.
  ///
  /// En cas de succès : le paiement passe à [StatutPaiement.reussi]
  /// et la cotisation correspondante est marquée [validee].
  Future<Paiement> confirmerOtp({
    required String idPaiement,
    required String codeOtp,
  });

  /// Annule un paiement en cours (avant confirmation OTP).
  Future<Paiement> annulerPaiement(String idPaiement);

  /// Liste les paiements d'un membre, triés du plus récent au plus ancien.
  Future<List<Paiement>> listerPaiementsMembre(String idMembre);

  /// Liste les paiements d'une tontine.
  Future<List<Paiement>> listerPaiementsTontine(String idTontine);
}
