import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/entites/utilisateur.dart';
import '../../../../core/erreurs/exceptions.dart';
import '../../domaine/contracts/auth_repository.dart';

/// Implémentation **démo** du [AuthRepository].
///
/// - Aucune connexion à un serveur n'est nécessaire.
/// - Le code OTP correct en mode démo est **123456**.
/// - La session est persistée dans SharedPreferences.
///
/// À remplacer par une implémentation REST/Firebase au Sprint 4.
class AuthRepositoryDemo implements AuthRepository {
  static const String _cleSession = 'tontineapp_session_utilisateur';
  static const String _codeOtpDemo = '123456';

  @override
  Future<bool> demanderOtp(String numeroTelephone) async {
    // Simule un délai réseau
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return true;
  }

  @override
  Future<bool> verifierOtp({
    required String numeroTelephone,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (code != _codeOtpDemo) {
      throw const ExceptionAuth(
        'Code OTP incorrect. En mode démo, utilisez 123456.',
      );
    }
    return true;
  }

  @override
  Future<Utilisateur> creerProfil({
    required String numeroTelephone,
    required String prenom,
    required String nom,
    String? email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final utilisateur = Utilisateur(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      numeroTelephone: numeroTelephone,
      prenom: prenom,
      nom: nom,
      email: email,
      dateInscription: DateTime.now(),
    );

    // Persiste la session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleSession, jsonEncode(utilisateur.versJson()));

    return utilisateur;
  }

  @override
  Future<Utilisateur?> recupererSession() async {
    final prefs = await SharedPreferences.getInstance();
    final brut = prefs.getString(_cleSession);
    if (brut == null) return null;
    try {
      final json = jsonDecode(brut) as Map<String, dynamic>;
      return Utilisateur.depuisJson(json);
    } catch (_) {
      // Session corrompue : on la nettoie
      await prefs.remove(_cleSession);
      return null;
    }
  }

  @override
  Future<Utilisateur> modifierProfil({
    required String prenom,
    required String nom,
    String? email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final session = await recupererSession();
    if (session == null) {
      throw const ExceptionAuth('Aucune session active');
    }

    final misAJour = session.copierAvec(
      prenom: prenom,
      nom: nom,
      email: email,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleSession, jsonEncode(misAJour.versJson()));

    return misAJour;
  }

  @override
  Future<void> seDeconnecter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cleSession);
  }
}
