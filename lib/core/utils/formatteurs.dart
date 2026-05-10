import 'package:intl/intl.dart';

/// Collection de formatteurs pour l'affichage de données.
class Formatteurs {
  Formatteurs._();

  /// Formate un montant en FCFA avec espaces comme séparateurs de milliers.
  ///
  /// Exemple : `formatterFCFA(125000)` → `"125 000 FCFA"`
  static String formatterFCFA(num montant) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    final formate = formatter.format(montant).replaceAll(',', ' ');
    return '$formate FCFA';
  }

  /// Masque un numéro de téléphone pour l'affichage.
  ///
  /// Exemple : `masquerTelephone("+2250707978218")` → `"+225 07 ** ** 82 18"`
  static String masquerTelephone(String numero) {
    final nettoye = numero.replaceAll(RegExp(r'[^0-9+]'), '');
    if (nettoye.length < 10) return numero;

    // Garde les 4 premiers et 4 derniers caractères, masque le milieu
    final debut = nettoye.substring(0, nettoye.length - 8);
    final milieu = nettoye.substring(nettoye.length - 8, nettoye.length - 4);
    final fin = nettoye.substring(nettoye.length - 4);

    final milieuMasque = milieu.replaceAll(RegExp(r'[0-9]'), '*');
    return '$debut $milieuMasque $fin';
  }

  /// Formate une date au format français court.
  ///
  /// Exemple : `formatterDateCourte(DateTime(2026, 5, 9))` → `"09/05/2026"`
  static String formatterDateCourte(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  /// Formate une date avec le mois en lettres.
  ///
  /// Exemple : `formatterDateLongue(DateTime(2026, 5, 9))` → `"9 mai 2026"`
  static String formatterDateLongue(DateTime date) {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }
}
