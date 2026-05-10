import '../../../../core/donnees/stockage_json.dart';
import '../../../../core/entites/membre.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/entites/tour.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/tontine_repository.dart';

/// Implémentation **persistante** du [TontineRepository].
///
/// Stocke toutes les tontines dans un fichier JSON local.
/// Au premier lancement, seed avec 3 tontines de démonstration
/// contenant des noms ivoiriens. Aux lancements suivants, recharge
/// l'état persisté.
///
/// Conserve le nom `TontineRepositoryDemo` pour minimiser l'impact
/// sur le reste du code (pas de modification dans main.dart, etc.).
class TontineRepositoryDemo implements TontineRepository {
  TontineRepositoryDemo._interne();
  static final TontineRepositoryDemo _instance =
      TontineRepositoryDemo._interne();
  factory TontineRepositoryDemo() => _instance;

  static const String _nomCollection = 'tontines';

  final StockageJson _stockage = StockageJson();
  List<Tontine> _tontines = [];
  bool _chargeDuDisque = false;

  /// Charge les tontines depuis le disque (une seule fois par session).
  Future<void> _chargerSiNecessaire() async {
    if (_chargeDuDisque) return;
    _chargeDuDisque = true;

    final brut = await _stockage.charger(_nomCollection);
    if (brut is List) {
      try {
        _tontines = brut
            .map((e) => Tontine.depuisJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fichier corrompu : on repart à vide
        _tontines = [];
      }
    }
  }

  Future<void> _sauvegarder() async {
    await _stockage.sauvegarder(
      _nomCollection,
      _tontines.map((t) => t.versJson()).toList(),
    );
  }

  /// Initialise les 3 tontines de démo si la collection est vide
  /// (premier lancement de l'app).
  Future<void> initialiserSiNecessaire(
    String idUtilisateurCourant,
    String nomUtilisateurCourant,
  ) async {
    await _chargerSiNecessaire();
    if (_tontines.isNotEmpty) return; // Déjà initialisé

    final maintenant = DateTime.now();

    // ─── Tontine 1 : "Famille Yopougon" — Active, l'utilisateur est admin
    final membres1 = [
      _membre('m1_1', idUtilisateurCourant, '+2250707978218',
          nomUtilisateurCourant, RoleMembre.admin, StatutMembre.actif, 1),
      _membre('m1_2', 'usr_awa', '+2250101010101', 'Awa Kouassi',
          RoleMembre.membre, StatutMembre.actif, 2),
      _membre('m1_3', 'usr_seko', '+2250202020202', 'Sékou Traoré',
          RoleMembre.membre, StatutMembre.actif, 3),
      _membre('m1_4', 'usr_konan', '+2250303030303', 'Konan Yao',
          RoleMembre.membre, StatutMembre.actif, 4),
      _membre('m1_5', 'usr_mariam', '+2250404040404', 'Mariama Diallo',
          RoleMembre.membre, StatutMembre.actif, 5),
    ];
    _tontines.add(Tontine(
      id: 't1',
      nom: 'Famille Yopougon',
      description: 'Tontine mensuelle entre amis du quartier',
      montantCotisation: 25000,
      frequence: FrequenceCotisation.mensuelle,
      dateDebut: maintenant.subtract(const Duration(days: 60)),
      statut: StatutTontine.active,
      idCreateur: idUtilisateurCourant,
      membres: membres1,
      tours: _genererTours(
        idTontine: 't1',
        membres: membres1,
        montantCotisation: 25000,
        dateDebut: maintenant.subtract(const Duration(days: 60)),
        joursEntreTours: 30,
        tourEnCoursIndex: 2,
      ),
      dateCreation: maintenant.subtract(const Duration(days: 70)),
    ));

    // ─── Tontine 2 : "Collègues du bureau" — Active, l'utilisateur est membre
    final membres2 = [
      _membre('m2_1', 'usr_admin2', '+2250505050505', 'Aïcha Bamba',
          RoleMembre.admin, StatutMembre.actif, 1),
      _membre('m2_2', idUtilisateurCourant, '+2250707978218',
          nomUtilisateurCourant, RoleMembre.membre, StatutMembre.actif, 2),
      _membre('m2_3', 'usr_kouame', '+2250606060606', 'Kouamé N\'Guessan',
          RoleMembre.membre, StatutMembre.actif, 3),
      _membre('m2_4', 'usr_fatou', '+2250707070707', 'Fatou Coulibaly',
          RoleMembre.membre, StatutMembre.actif, 4),
    ];
    _tontines.add(Tontine(
      id: 't2',
      nom: 'Collègues du bureau',
      description: 'Tontine bi-mensuelle pour le projet équipe',
      montantCotisation: 50000,
      frequence: FrequenceCotisation.bimensuelle,
      dateDebut: maintenant.subtract(const Duration(days: 14)),
      statut: StatutTontine.active,
      idCreateur: 'usr_admin2',
      membres: membres2,
      tours: _genererTours(
        idTontine: 't2',
        membres: membres2,
        montantCotisation: 50000,
        dateDebut: maintenant.subtract(const Duration(days: 14)),
        joursEntreTours: 14,
        tourEnCoursIndex: 1,
      ),
      dateCreation: maintenant.subtract(const Duration(days: 20)),
    ));

    // ─── Tontine 3 : "Voyage Bassam" — Brouillon
    final membres3 = [
      _membre('m3_1', idUtilisateurCourant, '+2250707978218',
          nomUtilisateurCourant, RoleMembre.admin, StatutMembre.actif, 1),
      _membre('m3_2', 'usr_yann', '+2250808080808', 'Yann Brou',
          RoleMembre.membre, StatutMembre.invite, 2),
    ];
    _tontines.add(Tontine(
      id: 't3',
      nom: 'Voyage Bassam',
      description: 'Pour notre escapade à Grand-Bassam',
      montantCotisation: 15000,
      frequence: FrequenceCotisation.hebdomadaire,
      dateDebut: maintenant.add(const Duration(days: 7)),
      statut: StatutTontine.brouillon,
      idCreateur: idUtilisateurCourant,
      membres: membres3,
      tours: const [],
      dateCreation: maintenant.subtract(const Duration(days: 2)),
    ));

    await _sauvegarder();
  }

  /// Liste toutes les tontines (utilisé par le seed des cotisations).
  Future<List<Tontine>> listerToutes() async {
    await _chargerSiNecessaire();
    return List.unmodifiable(_tontines);
  }

  // ─── Méthodes du contrat ──────────────────────────────────────────

  @override
  Future<List<Tontine>> listerMesTontines(String idUtilisateur) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _tontines
        .where((t) => t.membres.any((m) => m.idUtilisateur == idUtilisateur))
        .toList();
  }

  @override
  Future<Tontine?> obtenirTontine(String idTontine) async {
    await _chargerSiNecessaire();
    try {
      return _tontines.firstWhere((t) => t.id == idTontine);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Tontine> creerTontine({
    required String nom,
    String? description,
    required num montantCotisation,
    required FrequenceCotisation frequence,
    required DateTime dateDebut,
    required String idCreateur,
    required String nomCreateur,
    required String numeroTelephoneCreateur,
  }) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final id = 't_${DateTime.now().millisecondsSinceEpoch}';
    final maintenant = DateTime.now();

    final premierMembre = Membre(
      id: 'm_${maintenant.millisecondsSinceEpoch}',
      idUtilisateur: idCreateur,
      numeroTelephone: numeroTelephoneCreateur,
      nomAffichage: nomCreateur,
      role: RoleMembre.admin,
      statut: StatutMembre.actif,
      ordrePassage: 1,
      dateAjout: maintenant,
    );

    final tontine = Tontine(
      id: id,
      nom: nom,
      description: description,
      montantCotisation: montantCotisation,
      frequence: frequence,
      dateDebut: dateDebut,
      statut: StatutTontine.brouillon,
      idCreateur: idCreateur,
      membres: [premierMembre],
      tours: const [],
      dateCreation: maintenant,
    );

    _tontines.add(tontine);
    await _sauvegarder();
    return tontine;
  }

  @override
  Future<Membre> inviterMembre({
    required String idTontine,
    required String numeroTelephone,
    required String nomAffichage,
  }) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final indexTontine = _tontines.indexWhere((t) => t.id == idTontine);
    if (indexTontine == -1) {
      throw const ExceptionInconnue('Tontine introuvable');
    }
    final tontine = _tontines[indexTontine];

    if (tontine.statut != StatutTontine.brouillon) {
      throw const ExceptionValidation(
        'Impossible d\'inviter un membre dans une tontine déjà active',
      );
    }
    if (tontine.membres.any((m) => m.numeroTelephone == numeroTelephone)) {
      throw const ExceptionValidation(
        'Ce numéro est déjà membre de la tontine',
      );
    }

    final nouveauMembre = Membre(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      numeroTelephone: numeroTelephone,
      nomAffichage: nomAffichage,
      role: RoleMembre.membre,
      statut: StatutMembre.invite,
      ordrePassage: tontine.membres.length + 1,
      dateAjout: DateTime.now(),
    );

    _tontines[indexTontine] = tontine.copierAvec(
      membres: [...tontine.membres, nouveauMembre],
    );
    await _sauvegarder();
    return nouveauMembre;
  }

  @override
  Future<void> retirerMembre({
    required String idTontine,
    required String idMembre,
  }) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final indexTontine = _tontines.indexWhere((t) => t.id == idTontine);
    if (indexTontine == -1) {
      throw const ExceptionInconnue('Tontine introuvable');
    }
    final tontine = _tontines[indexTontine];

    if (tontine.statut != StatutTontine.brouillon) {
      throw const ExceptionValidation(
        'Impossible de retirer un membre d\'une tontine active',
      );
    }

    final nouveauxMembres =
        tontine.membres.where((m) => m.id != idMembre).toList();
    for (int i = 0; i < nouveauxMembres.length; i++) {
      nouveauxMembres[i] =
          nouveauxMembres[i].copierAvec(ordrePassage: i + 1);
    }

    _tontines[indexTontine] = tontine.copierAvec(membres: nouveauxMembres);
    await _sauvegarder();
  }

  @override
  Future<Tontine> activerTontine(String idTontine) async {
    await _chargerSiNecessaire();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final indexTontine = _tontines.indexWhere((t) => t.id == idTontine);
    if (indexTontine == -1) {
      throw const ExceptionInconnue('Tontine introuvable');
    }
    final tontine = _tontines[indexTontine];

    if (tontine.statut != StatutTontine.brouillon) {
      throw const ExceptionValidation('La tontine est déjà active');
    }
    if (tontine.membres.length < 2) {
      throw const ExceptionValidation(
        'Une tontine doit avoir au moins 2 membres pour être activée',
      );
    }

    final membresActifs = tontine.membres
        .map((m) => m.copierAvec(statut: StatutMembre.actif))
        .toList();

    final tours = _genererTours(
      idTontine: tontine.id,
      membres: membresActifs,
      montantCotisation: tontine.montantCotisation,
      dateDebut: tontine.dateDebut,
      joursEntreTours: tontine.frequence.joursEntreTours,
      tourEnCoursIndex: 0,
    );

    final tontineActive = tontine.copierAvec(
      statut: StatutTontine.active,
      membres: membresActifs,
      tours: tours,
    );

    _tontines[indexTontine] = tontineActive;
    await _sauvegarder();
    return tontineActive;
  }

  // ─── Helpers de construction ──────────────────────────────────────

  Membre _membre(String id, String idUtilisateur, String tel, String nom,
      RoleMembre role, StatutMembre statut, int ordre) {
    return Membre(
      id: id,
      idUtilisateur: idUtilisateur,
      numeroTelephone: tel,
      nomAffichage: nom,
      role: role,
      statut: statut,
      ordrePassage: ordre,
      dateAjout: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  List<Tour> _genererTours({
    required String idTontine,
    required List<Membre> membres,
    required num montantCotisation,
    required DateTime dateDebut,
    required int joursEntreTours,
    required int tourEnCoursIndex,
  }) {
    final cagnotte = montantCotisation * membres.length;
    final tours = <Tour>[];

    for (int i = 0; i < membres.length; i++) {
      final membre = membres[i];
      final dateEcheance =
          dateDebut.add(Duration(days: joursEntreTours * i));

      StatutTour statut;
      int recues;
      if (i < tourEnCoursIndex) {
        statut = StatutTour.termine;
        recues = membres.length;
      } else if (i == tourEnCoursIndex) {
        statut = StatutTour.enCours;
        recues = (membres.length * 0.6).round();
      } else {
        statut = StatutTour.aVenir;
        recues = 0;
      }

      tours.add(Tour(
        id: '${idTontine}_tour_${i + 1}',
        numero: i + 1,
        idMembreBeneficiaire: membre.id,
        nomBeneficiaire: membre.nomAffichage,
        montantTotal: cagnotte,
        dateEcheance: dateEcheance,
        statut: statut,
        nombreCotisationsRecues: recues,
        nombreCotisationsAttendues: membres.length,
      ));
    }

    return tours;
  }
}
