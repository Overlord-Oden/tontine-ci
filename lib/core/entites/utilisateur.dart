/// Entité représentant un utilisateur de la TontineApp.
///
/// C'est un modèle immuable du domaine, indépendant de toute
/// source de données (API, BDD, mémoire).
class Utilisateur {
  final String id;
  final String numeroTelephone;
  final String prenom;
  final String nom;
  final String? email;
  final DateTime dateInscription;

  const Utilisateur({
    required this.id,
    required this.numeroTelephone,
    required this.prenom,
    required this.nom,
    this.email,
    required this.dateInscription,
  });

  /// Nom complet pour affichage.
  String get nomComplet => '$prenom $nom';

  /// Initiales pour avatar.
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  Utilisateur copierAvec({
    String? id,
    String? numeroTelephone,
    String? prenom,
    String? nom,
    String? email,
    DateTime? dateInscription,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      dateInscription: dateInscription ?? this.dateInscription,
    );
  }

  Map<String, dynamic> versJson() => {
        'id': id,
        'numeroTelephone': numeroTelephone,
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'dateInscription': dateInscription.toIso8601String(),
      };

  factory Utilisateur.depuisJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as String,
      numeroTelephone: json['numeroTelephone'] as String,
      prenom: json['prenom'] as String,
      nom: json['nom'] as String,
      email: json['email'] as String?,
      dateInscription: DateTime.parse(json['dateInscription'] as String),
    );
  }
}
