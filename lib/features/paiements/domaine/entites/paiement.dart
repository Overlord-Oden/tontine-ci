import 'operateur_mm.dart';

/// Statut d'un paiement Mobile Money.
enum StatutPaiement {
  /// L'utilisateur a initié, attend la saisie OTP.
  enAttenteOtp,

  /// OTP correct, traitement par l'opérateur.
  enTraitement,

  /// Paiement réussi, confirmation reçue.
  reussi,

  /// Paiement refusé (OTP incorrect, solde insuffisant simulé, etc.).
  echec,

  /// Annulé par l'utilisateur.
  annule;

  String get libelle {
    switch (this) {
      case StatutPaiement.enAttenteOtp:
        return 'En attente OTP';
      case StatutPaiement.enTraitement:
        return 'En traitement';
      case StatutPaiement.reussi:
        return 'Réussi';
      case StatutPaiement.echec:
        return 'Échec';
      case StatutPaiement.annule:
        return 'Annulé';
    }
  }

  bool get estTermine =>
      this == StatutPaiement.reussi ||
      this == StatutPaiement.echec ||
      this == StatutPaiement.annule;
}

/// Représente une transaction Mobile Money.
class Paiement {
  final String id;
  final String idCotisation;
  final String idTontine;
  final String idMembre;
  final String nomMembre;
  final OperateurMM operateur;
  final String numeroTelephoneMM;
  final num montant;
  final num frais;
  final StatutPaiement statut;
  final String? motifEchec;
  final DateTime dateInitiation;
  final DateTime? dateConfirmation;

  /// Identifiant de transaction côté opérateur (numéro de référence).
  final String? referenceOperateur;

  const Paiement({
    required this.id,
    required this.idCotisation,
    required this.idTontine,
    required this.idMembre,
    required this.nomMembre,
    required this.operateur,
    required this.numeroTelephoneMM,
    required this.montant,
    required this.frais,
    required this.statut,
    this.motifEchec,
    required this.dateInitiation,
    this.dateConfirmation,
    this.referenceOperateur,
  });

  num get montantTotal => montant + frais;

  Paiement copierAvec({
    String? id,
    String? idCotisation,
    String? idTontine,
    String? idMembre,
    String? nomMembre,
    OperateurMM? operateur,
    String? numeroTelephoneMM,
    num? montant,
    num? frais,
    StatutPaiement? statut,
    String? motifEchec,
    DateTime? dateInitiation,
    DateTime? dateConfirmation,
    String? referenceOperateur,
  }) {
    return Paiement(
      id: id ?? this.id,
      idCotisation: idCotisation ?? this.idCotisation,
      idTontine: idTontine ?? this.idTontine,
      idMembre: idMembre ?? this.idMembre,
      nomMembre: nomMembre ?? this.nomMembre,
      operateur: operateur ?? this.operateur,
      numeroTelephoneMM: numeroTelephoneMM ?? this.numeroTelephoneMM,
      montant: montant ?? this.montant,
      frais: frais ?? this.frais,
      statut: statut ?? this.statut,
      motifEchec: motifEchec ?? this.motifEchec,
      dateInitiation: dateInitiation ?? this.dateInitiation,
      dateConfirmation: dateConfirmation ?? this.dateConfirmation,
      referenceOperateur: referenceOperateur ?? this.referenceOperateur,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'idCotisation': idCotisation,
        'idTontine': idTontine,
        'idMembre': idMembre,
        'nomMembre': nomMembre,
        'operateur': operateur.name,
        'numeroTelephoneMM': numeroTelephoneMM,
        'montant': montant,
        'frais': frais,
        'statut': statut.name,
        'motifEchec': motifEchec,
        'dateInitiation': dateInitiation.toIso8601String(),
        'dateConfirmation': dateConfirmation?.toIso8601String(),
        'referenceOperateur': referenceOperateur,
      };

  factory Paiement.depuisJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] as String,
      idCotisation: json['idCotisation'] as String,
      idTontine: json['idTontine'] as String,
      idMembre: json['idMembre'] as String,
      nomMembre: json['nomMembre'] as String,
      operateur: OperateurMM.values.byName(json['operateur'] as String),
      numeroTelephoneMM: json['numeroTelephoneMM'] as String,
      montant: json['montant'] as num,
      frais: json['frais'] as num,
      statut: StatutPaiement.values.byName(json['statut'] as String),
      motifEchec: json['motifEchec'] as String?,
      dateInitiation: DateTime.parse(json['dateInitiation'] as String),
      dateConfirmation: json['dateConfirmation'] != null
          ? DateTime.parse(json['dateConfirmation'] as String)
          : null,
      referenceOperateur: json['referenceOperateur'] as String?,
    );
  }
}
