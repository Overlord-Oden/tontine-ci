/// Type de notification dans l'app.
enum TypeNotification {
  cotisationValidee,
  paiementReussi,
  paiementEchoue,
  tourClotureProchaine,
  tourCloture,
  nouveauMembre,
  tontineActivee,
  rappel,
  systeme;

  String get libelle {
    switch (this) {
      case TypeNotification.cotisationValidee:
        return 'Cotisation validée';
      case TypeNotification.paiementReussi:
        return 'Paiement réussi';
      case TypeNotification.paiementEchoue:
        return 'Paiement échoué';
      case TypeNotification.tourClotureProchaine:
        return 'Tour bientôt clôturé';
      case TypeNotification.tourCloture:
        return 'Tour clôturé';
      case TypeNotification.nouveauMembre:
        return 'Nouveau membre';
      case TypeNotification.tontineActivee:
        return 'Tontine activée';
      case TypeNotification.rappel:
        return 'Rappel';
      case TypeNotification.systeme:
        return 'Système';
    }
  }
}

/// Entité représentant une notification dans l'app.
class NotificationApp {
  final String id;
  final TypeNotification type;
  final String titre;
  final String message;
  final DateTime dateCreation;
  final bool lue;

  /// Données contextuelles optionnelles (id de tontine, de tour, de paiement…)
  final Map<String, String> donnees;

  const NotificationApp({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    required this.dateCreation,
    this.lue = false,
    this.donnees = const {},
  });

  NotificationApp copierAvec({
    String? id,
    TypeNotification? type,
    String? titre,
    String? message,
    DateTime? dateCreation,
    bool? lue,
    Map<String, String>? donnees,
  }) {
    return NotificationApp(
      id: id ?? this.id,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      dateCreation: dateCreation ?? this.dateCreation,
      lue: lue ?? this.lue,
      donnees: donnees ?? this.donnees,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'type': type.name,
        'titre': titre,
        'message': message,
        'dateCreation': dateCreation.toIso8601String(),
        'lue': lue,
        'donnees': donnees,
      };

  factory NotificationApp.depuisJson(Map<String, dynamic> json) {
    return NotificationApp(
      id: json['id'] as String,
      type: TypeNotification.values.byName(json['type'] as String),
      titre: json['titre'] as String,
      message: json['message'] as String,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      lue: json['lue'] as bool? ?? false,
      donnees: (json['donnees'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          const {},
    );
  }
}
