import 'membre.dart';
import 'tour.dart';

/// Fréquence de cotisation d'une tontine.
enum FrequenceCotisation {
  hebdomadaire,
  bimensuelle,
  mensuelle;

  String get libelle {
    switch (this) {
      case FrequenceCotisation.hebdomadaire:
        return 'Hebdomadaire';
      case FrequenceCotisation.bimensuelle:
        return 'Bi-mensuelle';
      case FrequenceCotisation.mensuelle:
        return 'Mensuelle';
    }
  }

  int get joursEntreTours {
    switch (this) {
      case FrequenceCotisation.hebdomadaire:
        return 7;
      case FrequenceCotisation.bimensuelle:
        return 14;
      case FrequenceCotisation.mensuelle:
        return 30;
    }
  }
}

/// Statut courant d'une tontine.
enum StatutTontine {
  brouillon,
  active,
  terminee;

  String get libelle {
    switch (this) {
      case StatutTontine.brouillon:
        return 'Brouillon';
      case StatutTontine.active:
        return 'Active';
      case StatutTontine.terminee:
        return 'Terminée';
    }
  }
}

/// Entité représentant une tontine.
class Tontine {
  final String id;
  final String nom;
  final String? description;
  final num montantCotisation;
  final FrequenceCotisation frequence;
  final DateTime dateDebut;
  final StatutTontine statut;
  final String idCreateur;
  final List<Membre> membres;
  final List<Tour> tours;
  final DateTime dateCreation;

  const Tontine({
    required this.id,
    required this.nom,
    this.description,
    required this.montantCotisation,
    required this.frequence,
    required this.dateDebut,
    required this.statut,
    required this.idCreateur,
    required this.membres,
    required this.tours,
    required this.dateCreation,
  });

  num get cagnotteParTour => montantCotisation * membres.length;

  num get montantTotalParMembre => montantCotisation * tours.length;

  Tour? get tourEnCours {
    try {
      return tours.firstWhere((t) => t.statut == StatutTour.enCours);
    } catch (_) {
      return null;
    }
  }

  Tour? get prochainTour {
    final aVenir = tours.where((t) => t.statut == StatutTour.aVenir).toList()
      ..sort((a, b) => a.dateEcheance.compareTo(b.dateEcheance));
    return aVenir.isEmpty ? null : aVenir.first;
  }

  List<Tour> get toursTermines =>
      tours.where((t) => t.statut == StatutTour.termine).toList();

  bool estAdmin(String idUtilisateur) {
    return membres.any(
      (m) => m.idUtilisateur == idUtilisateur && m.role == RoleMembre.admin,
    );
  }

  Tontine copierAvec({
    String? id,
    String? nom,
    String? description,
    num? montantCotisation,
    FrequenceCotisation? frequence,
    DateTime? dateDebut,
    StatutTontine? statut,
    String? idCreateur,
    List<Membre>? membres,
    List<Tour>? tours,
    DateTime? dateCreation,
  }) {
    return Tontine(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      montantCotisation: montantCotisation ?? this.montantCotisation,
      frequence: frequence ?? this.frequence,
      dateDebut: dateDebut ?? this.dateDebut,
      statut: statut ?? this.statut,
      idCreateur: idCreateur ?? this.idCreateur,
      membres: membres ?? this.membres,
      tours: tours ?? this.tours,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'montantCotisation': montantCotisation,
        'frequence': frequence.name,
        'dateDebut': dateDebut.toIso8601String(),
        'statut': statut.name,
        'idCreateur': idCreateur,
        'membres': membres.map((m) => m.versJson()).toList(),
        'tours': tours.map((t) => t.versJson()).toList(),
        'dateCreation': dateCreation.toIso8601String(),
      };

  factory Tontine.depuisJson(Map<String, dynamic> json) {
    return Tontine(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String?,
      montantCotisation: json['montantCotisation'] as num,
      frequence:
          FrequenceCotisation.values.byName(json['frequence'] as String),
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      statut: StatutTontine.values.byName(json['statut'] as String),
      idCreateur: json['idCreateur'] as String,
      membres: (json['membres'] as List<dynamic>)
          .map((m) => Membre.depuisJson(m as Map<String, dynamic>))
          .toList(),
      tours: (json['tours'] as List<dynamic>)
          .map((t) => Tour.depuisJson(t as Map<String, dynamic>))
          .toList(),
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );
  }
}
