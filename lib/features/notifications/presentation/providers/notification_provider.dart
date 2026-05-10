import 'package:flutter/foundation.dart';

import '../../domaine/contracts/notification_repository.dart';
import '../../domaine/entites/notification_app.dart';

/// Provider qui expose les notifications de l'utilisateur courant.
///
/// Tient à jour la liste + le compteur de non-lues, et offre des
/// raccourcis pour créer rapidement des notifications typées
/// (cotisation validée, paiement réussi, tour clôturé…).
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository) {
    charger();
  }

  List<NotificationApp> _notifications = const [];
  int _nbNonLues = 0;

  List<NotificationApp> get notifications => _notifications;
  int get nbNonLues => _nbNonLues;
  bool get aDesNonLues => _nbNonLues > 0;

  Future<void> charger() async {
    _notifications = await _repository.lister();
    _nbNonLues = _notifications.where((n) => !n.lue).length;
    notifyListeners();
  }

  // ─── Création générique ─────────────────────────────────────────

  Future<void> creer({
    required TypeNotification type,
    required String titre,
    required String message,
    Map<String, String> donnees = const {},
  }) async {
    await _repository.creer(
      type: type,
      titre: titre,
      message: message,
      donnees: donnees,
    );
    await charger();
  }

  // ─── Raccourcis typés ──────────────────────────────────────────

  Future<void> notifierCotisationValidee({
    required String nomMembre,
    required String nomTontine,
    required num montant,
  }) {
    return creer(
      type: TypeNotification.cotisationValidee,
      titre: 'Cotisation validée ✅',
      message:
          'La cotisation de $nomMembre pour "$nomTontine" a été validée.',
    );
  }

  Future<void> notifierPaiementReussi({
    required String operateur,
    required num montant,
    required String nomTontine,
  }) {
    return creer(
      type: TypeNotification.paiementReussi,
      titre: 'Paiement réussi 💸',
      message:
          'Votre cotisation a été envoyée via $operateur pour "$nomTontine".',
    );
  }

  Future<void> notifierTourCloture({
    required String nomTontine,
    required int numeroTour,
    required String nomBeneficiaire,
  }) {
    return creer(
      type: TypeNotification.tourCloture,
      titre: 'Tour $numeroTour clôturé 🎉',
      message:
          '$nomBeneficiaire peut recevoir la cagnotte de "$nomTontine".',
    );
  }

  Future<void> notifierTontineActivee({
    required String nomTontine,
    required int nbMembres,
  }) {
    return creer(
      type: TypeNotification.tontineActivee,
      titre: 'Tontine activée 🚀',
      message:
          '"$nomTontine" est maintenant active avec $nbMembres membres.',
    );
  }

  Future<void> notifierNouveauMembre({
    required String nomMembre,
    required String nomTontine,
  }) {
    return creer(
      type: TypeNotification.nouveauMembre,
      titre: 'Nouveau membre 👤',
      message: '$nomMembre a été invité à "$nomTontine".',
    );
  }

  // ─── Actions ─────────────────────────────────────────────────────

  Future<void> marquerLue(String idNotification) async {
    await _repository.marquerLue(idNotification);
    await charger();
  }

  Future<void> marquerToutesLues() async {
    await _repository.marquerToutesLues();
    await charger();
  }

  Future<void> supprimer(String idNotification) async {
    await _repository.supprimer(idNotification);
    await charger();
  }

  Future<void> effacerTout() async {
    await _repository.effacerTout();
    await charger();
  }
}
