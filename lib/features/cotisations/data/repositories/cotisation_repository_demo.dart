import '../../../../core/donnees/stockage_json.dart';
import '../../../../core/entites/cotisation.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/entites/tour.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/cotisation_repository.dart';

/// Implémentation **persistante** du [CotisationRepository].
///
/// Stocke toutes les cotisations dans un fichier JSON local.
/// Génère lazy-loaded les cotisations d'une tontine si elles n'existent
/// pas déjà dans la BDD locale.
class CotisationRepositoryDemo implements CotisationRepository {
  CotisationRepositoryDemo._interne();
  static final CotisationRepositoryDemo _instance =
      CotisationRepositoryDemo._interne();
  factory CotisationRepositoryDemo() => _instance;

  static const String _nomCollection = 'cotisations';

  final StockageJson _stockage = StockageJson();
  List<Cotisation> _cotisations = [];
  bool _chargeDuDisque = false;

  Future<void> _chargerSiNecessaire() async {
    if (_chargeDuDisque) return;
    _chargeDuDisque = true;

    final brut = await _stockage.charger(_nomCollection);
    if (brut is List) {
      try {
        _cotisations = brut
            .map((e) => Cotisation.depuisJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _cotisations = [];
      }
    }
  }

  Future<void> _sauvegarder() async {
    await _stockage.sauvegarder(
      _nomCollection,
      _cotisations.map((c) => c.versJson()).toList(),
    );
  }

  /// Génère les cotisations d'une tontine si elles n'existent pas encore.
  ///
  /// Pour chaque tour, crée une cotisation par membre.
  /// Le bénéficiaire reçoit le statut [StatutCotisation.beneficiaire].
  ///
  /// Note : la cotisation de l'utilisateur courant ([idUtilisateurCourant])
  /// est forcée à [StatutCotisation.attendue] dans les tours en cours,
  /// pour qu'il puisse toujours tester le flux de paiement Mobile Money.
  Future<void> genererSiNecessaire(
    Tontine tontine, {
    String? idUtilisateurCourant,
  }) async {
    await _chargerSiNecessaire();
    var modifications = false;

    for (final tour in tontine.tours) {
      // Vérifie si des cotisations existent déjà pour ce tour
      final dejaExistantes =
          _cotisations.any((c) => c.idTour == tour.id);
      if (dejaExistantes) continue;

      _genererCotisationsPourTour(tontine, tour, idUtilisateurCourant);
      modifications = true;
    }

    if (modifications) {
      await _sauvegarder();
    }
  }

  void _genererCotisationsPourTour(
    Tontine tontine,
    Tour tour,
    String? idUtilisateurCourant,
  ) {
    for (final membre in tontine.membres) {
      final estBeneficiaire = membre.id == tour.idMembreBeneficiaire;
      final estUtilisateurCourant =
          idUtilisateurCourant != null &&
              membre.idUtilisateur == idUtilisateurCourant;

      StatutCotisation statut;
      DateTime? datePaiement;
      DateTime? dateValidation;

      if (estBeneficiaire) {
        statut = StatutCotisation.beneficiaire;
      } else if (estUtilisateurCourant &&
          tour.statut == StatutTour.enCours) {
        // Force "attendue" pour le user dans les tours en cours,
        // pour qu'il puisse toujours tester le paiement Mobile Money.
        statut = StatutCotisation.attendue;
      } else {
        switch (tour.statut) {
          case StatutTour.termine:
            statut = StatutCotisation.validee;
            datePaiement =
                tour.dateEcheance.subtract(const Duration(days: 2));
            dateValidation = tour.dateEcheance;
            break;
          case StatutTour.enCours:
            final indexMembre = tontine.membres.indexOf(membre);
            final nbValidees = (tontine.membres.length * 0.6).round();
            if (indexMembre < nbValidees) {
              statut = StatutCotisation.validee;
              datePaiement =
                  DateTime.now().subtract(const Duration(days: 1));
              dateValidation = DateTime.now();
            } else {
              statut = StatutCotisation.attendue;
            }
            break;
          case StatutTour.aVenir:
            statut = StatutCotisation.attendue;
            break;
        }
      }

      _cotisations.add(Cotisation(
        id: 'cot_${tour.id}_${membre.id}',
        idTontine: tontine.id,
        idTour: tour.id,
        idMembre: membre.id,
        nomMembre: membre.nomAffichage,
        montant: tontine.montantCotisation,
        statut: statut,
        datePaiement: datePaiement,
        dateValidation: dateValidation,
      ));
    }
  }

  // ─── Méthodes du contrat ──────────────────────────────────────────

  @override
  Future<List<Cotisation>> listerCotisationsTour(String idTour) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _cotisations.where((c) => c.idTour == idTour).toList()
      ..sort((a, b) {
        if (a.estBeneficiaire && !b.estBeneficiaire) return -1;
        if (!a.estBeneficiaire && b.estBeneficiaire) return 1;
        return a.nomMembre.compareTo(b.nomMembre);
      });
  }

  @override
  Future<List<Cotisation>> listerCotisationsMembre(String idMembre) async {
    await _chargerSiNecessaire();
    return _cotisations.where((c) => c.idMembre == idMembre).toList();
  }

  @override
  Future<Cotisation> marquerPayee(String idCotisation) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final modifiee = _modifier(idCotisation, (c) {
      if (c.estBeneficiaire) {
        throw const ExceptionValidation(
          'Le bénéficiaire d\'un tour ne cotise pas pour ce tour',
        );
      }
      if (c.statut == StatutCotisation.validee) {
        throw const ExceptionValidation('Cotisation déjà validée');
      }
      return c.copierAvec(
        statut: StatutCotisation.payee,
        datePaiement: DateTime.now(),
      );
    });
    await _sauvegarder();
    return modifiee;
  }

  @override
  Future<Cotisation> validerCotisation(String idCotisation) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final modifiee = _modifier(idCotisation, (c) {
      if (c.estBeneficiaire) {
        throw const ExceptionValidation(
          'Impossible de valider la cotisation du bénéficiaire',
        );
      }
      return c.copierAvec(
        statut: StatutCotisation.validee,
        datePaiement: c.datePaiement ?? DateTime.now(),
        dateValidation: DateTime.now(),
      );
    });
    await _sauvegarder();
    return modifiee;
  }

  @override
  Future<Cotisation> annulerPaiement(String idCotisation) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final modifiee = _modifier(idCotisation, (c) {
      if (c.estBeneficiaire) {
        throw const ExceptionValidation(
          'Action impossible sur le bénéficiaire',
        );
      }
      return c.copierAvec(statut: StatutCotisation.attendue);
    });
    await _sauvegarder();
    return modifiee;
  }

  @override
  Future<bool> tourEstComplet(String idTour) async {
    await _chargerSiNecessaire();
    final cotisations = _cotisations.where((c) => c.idTour == idTour).toList();
    if (cotisations.isEmpty) return false;
    return cotisations.every((c) => c.estBeneficiaire || c.estReglee);
  }

  // ─── Helper ──────────────────────────────────────────────────────

  Cotisation _modifier(
    String idCotisation,
    Cotisation Function(Cotisation) modificateur,
  ) {
    final index = _cotisations.indexWhere((c) => c.id == idCotisation);
    if (index == -1) {
      throw const ExceptionInconnue('Cotisation introuvable');
    }
    final modifiee = modificateur(_cotisations[index]);
    _cotisations[index] = modifiee;
    return modifiee;
  }
}
