/// Rôle d'un membre au sein d'une tontine.
enum RoleMembre {
  admin,
  membre;

  String get libelle {
    switch (this) {
      case RoleMembre.admin:
        return 'Admin';
      case RoleMembre.membre:
        return 'Membre';
    }
  }
}

/// Statut d'un membre dans une tontine.
enum StatutMembre {
  invite, // invitation envoyée, pas encore acceptée
  actif,
  retire;

  String get libelle {
    switch (this) {
      case StatutMembre.invite:
        return 'Invité';
      case StatutMembre.actif:
        return 'Actif';
      case StatutMembre.retire:
        return 'Retiré';
    }
  }
}

/// Entité représentant un membre d'une tontine.
class Membre {
  final String id;
  final String? idUtilisateur;
  final String numeroTelephone;
  final String nomAffichage;
  final RoleMembre role;
  final StatutMembre statut;
  final int ordrePassage;
  final DateTime dateAjout;

  const Membre({
    required this.id,
    this.idUtilisateur,
    required this.numeroTelephone,
    required this.nomAffichage,
    required this.role,
    required this.statut,
    required this.ordrePassage,
    required this.dateAjout,
  });

  String get initiales {
    final parties = nomAffichage.trim().split(RegExp(r'\s+'));
    if (parties.isEmpty) return '?';
    if (parties.length == 1) {
      return parties.first.substring(0, 1).toUpperCase();
    }
    return (parties.first.substring(0, 1) + parties.last.substring(0, 1))
        .toUpperCase();
  }

  Membre copierAvec({
    String? id,
    String? idUtilisateur,
    String? numeroTelephone,
    String? nomAffichage,
    RoleMembre? role,
    StatutMembre? statut,
    int? ordrePassage,
    DateTime? dateAjout,
  }) {
    return Membre(
      id: id ?? this.id,
      idUtilisateur: idUtilisateur ?? this.idUtilisateur,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
      nomAffichage: nomAffichage ?? this.nomAffichage,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      ordrePassage: ordrePassage ?? this.ordrePassage,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  // ─── Sérialisation JSON ──────────────────────────────────────────

  Map<String, dynamic> versJson() => {
        'id': id,
        'idUtilisateur': idUtilisateur,
        'numeroTelephone': numeroTelephone,
        'nomAffichage': nomAffichage,
        'role': role.name,
        'statut': statut.name,
        'ordrePassage': ordrePassage,
        'dateAjout': dateAjout.toIso8601String(),
      };

  factory Membre.depuisJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'] as String,
      idUtilisateur: json['idUtilisateur'] as String?,
      numeroTelephone: json['numeroTelephone'] as String,
      nomAffichage: json['nomAffichage'] as String,
      role: RoleMembre.values.byName(json['role'] as String),
      statut: StatutMembre.values.byName(json['statut'] as String),
      ordrePassage: json['ordrePassage'] as int,
      dateAjout: DateTime.parse(json['dateAjout'] as String),
    );
  }
}
