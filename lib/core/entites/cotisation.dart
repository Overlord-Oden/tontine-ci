/// Statut d'une cotisation pour un tour donné.
enum StatutCotisation {
  attendue,
  payee,
  validee,
  beneficiaire;

  String get libelle {
    switch (this) {
      case StatutCotisation.attendue:
        return 'En attente';
      case StatutCotisation.payee:
        return 'À valider';
      case StatutCotisation.validee:
        return 'Validée';
      case StatutCotisation.beneficiaire:
        return 'Bénéficiaire';
    }
  }
}

/// Entité représentant la cotisation d'un membre pour un tour donné.
class Cotisation {
  final String id;
  final String idTontine;
  final String idTour;
  final String idMembre;
  final String nomMembre;
  final num montant;
  final StatutCotisation statut;
  final DateTime? datePaiement;
  final DateTime? dateValidation;

  const Cotisation({
    required this.id,
    required this.idTontine,
    required this.idTour,
    required this.idMembre,
    required this.nomMembre,
    required this.montant,
    required this.statut,
    this.datePaiement,
    this.dateValidation,
  });

  bool get estBeneficiaire => statut == StatutCotisation.beneficiaire;
  bool get estReglee => statut == StatutCotisation.validee;

  Cotisation copierAvec({
    String? id,
    String? idTontine,
    String? idTour,
    String? idMembre,
    String? nomMembre,
    num? montant,
    StatutCotisation? statut,
    DateTime? datePaiement,
    DateTime? dateValidation,
  }) {
    return Cotisation(
      id: id ?? this.id,
      idTontine: idTontine ?? this.idTontine,
      idTour: idTour ?? this.idTour,
      idMembre: idMembre ?? this.idMembre,
      nomMembre: nomMembre ?? this.nomMembre,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      datePaiement: datePaiement ?? this.datePaiement,
      dateValidation: dateValidation ?? this.dateValidation,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'idTontine': idTontine,
        'idTour': idTour,
        'idMembre': idMembre,
        'nomMembre': nomMembre,
        'montant': montant,
        'statut': statut.name,
        'datePaiement': datePaiement?.toIso8601String(),
        'dateValidation': dateValidation?.toIso8601String(),
      };

  factory Cotisation.depuisJson(Map<String, dynamic> json) {
    return Cotisation(
      id: json['id'] as String,
      idTontine: json['idTontine'] as String,
      idTour: json['idTour'] as String,
      idMembre: json['idMembre'] as String,
      nomMembre: json['nomMembre'] as String,
      montant: json['montant'] as num,
      statut: StatutCotisation.values.byName(json['statut'] as String),
      datePaiement: json['datePaiement'] != null
          ? DateTime.parse(json['datePaiement'] as String)
          : null,
      dateValidation: json['dateValidation'] != null
          ? DateTime.parse(json['dateValidation'] as String)
          : null,
    );
  }
}
