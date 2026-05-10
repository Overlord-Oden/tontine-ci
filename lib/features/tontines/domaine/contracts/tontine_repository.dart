import '../../../../core/entites/membre.dart';
import '../../../../core/entites/tontine.dart';

/// Contrat du repository des tontines.
abstract class TontineRepository {
  /// Liste les tontines auxquelles participe l'utilisateur.
  Future<List<Tontine>> listerMesTontines(String idUtilisateur);

  /// Récupère le détail d'une tontine par son id.
  Future<Tontine?> obtenirTontine(String idTontine);

  /// Crée une nouvelle tontine. Le créateur devient automatiquement
  /// le premier membre avec le rôle admin.
  Future<Tontine> creerTontine({
    required String nom,
    String? description,
    required num montantCotisation,
    required FrequenceCotisation frequence,
    required DateTime dateDebut,
    required String idCreateur,
    required String nomCreateur,
    required String numeroTelephoneCreateur,
  });

  /// Ajoute un nouveau membre invité à une tontine.
  Future<Membre> inviterMembre({
    required String idTontine,
    required String numeroTelephone,
    required String nomAffichage,
  });

  /// Retire un membre d'une tontine (admin uniquement).
  Future<void> retirerMembre({
    required String idTontine,
    required String idMembre,
  });

  /// Active une tontine (passe de brouillon → active) et génère
  /// automatiquement le calendrier des tours.
  Future<Tontine> activerTontine(String idTontine);
}
