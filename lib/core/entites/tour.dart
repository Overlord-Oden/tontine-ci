/// Statut d'un tour de tontine.
enum StatutTour {
  aVenir,
  enCours,
  termine;

  String get libelle {
    switch (this) {
      case StatutTour.aVenir:
        return 'À venir';
      case StatutTour.enCours:
        return 'En cours';
      case StatutTour.termine:
        return 'Terminé';
    }
  }
}

/// Entité représentant un tour de tontine.
class Tour {
  final String id;
  final int numero;
  final String idMembreBeneficiaire;
  final String nomBeneficiaire;
  final num montantTotal;
  final DateTime dateEcheance;
  final StatutTour statut;
  final int nombreCotisationsRecues;
  final int nombreCotisationsAttendues;

  const Tour({
    required this.id,
    required this.numero,
    required this.idMembreBeneficiaire,
    required this.nomBeneficiaire,
    required this.montantTotal,
    required this.dateEcheance,
    required this.statut,
    this.nombreCotisationsRecues = 0,
    required this.nombreCotisationsAttendues,
  });

  double get progression {
    if (nombreCotisationsAttendues == 0) return 0;
    return nombreCotisationsRecues / nombreCotisationsAttendues;
  }

  Tour copierAvec({
    String? id,
    int? numero,
    String? idMembreBeneficiaire,
    String? nomBeneficiaire,
    num? montantTotal,
    DateTime? dateEcheance,
    StatutTour? statut,
    int? nombreCotisationsRecues,
    int? nombreCotisationsAttendues,
  }) {
    return Tour(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      idMembreBeneficiaire: idMembreBeneficiaire ?? this.idMembreBeneficiaire,
      nomBeneficiaire: nomBeneficiaire ?? this.nomBeneficiaire,
      montantTotal: montantTotal ?? this.montantTotal,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      statut: statut ?? this.statut,
      nombreCotisationsRecues:
          nombreCotisationsRecues ?? this.nombreCotisationsRecues,
      nombreCotisationsAttendues:
          nombreCotisationsAttendues ?? this.nombreCotisationsAttendues,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'numero': numero,
        'idMembreBeneficiaire': idMembreBeneficiaire,
        'nomBeneficiaire': nomBeneficiaire,
        'montantTotal': montantTotal,
        'dateEcheance': dateEcheance.toIso8601String(),
        'statut': statut.name,
        'nombreCotisationsRecues': nombreCotisationsRecues,
        'nombreCotisationsAttendues': nombreCotisationsAttendues,
      };

  factory Tour.depuisJson(Map<String, dynamic> json) {
    return Tour(
      id: json['id'] as String,
      numero: json['numero'] as int,
      idMembreBeneficiaire: json['idMembreBeneficiaire'] as String,
      nomBeneficiaire: json['nomBeneficiaire'] as String,
      montantTotal: json['montantTotal'] as num,
      dateEcheance: DateTime.parse(json['dateEcheance'] as String),
      statut: StatutTour.values.byName(json['statut'] as String),
      nombreCotisationsRecues: json['nombreCotisationsRecues'] as int? ?? 0,
      nombreCotisationsAttendues: json['nombreCotisationsAttendues'] as int,
    );
  }
}
