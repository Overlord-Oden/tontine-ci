import 'package:flutter/material.dart';

/// Palette de couleurs de la TontineApp.
///
/// Inspirée du drapeau de la Côte d'Ivoire :
/// - Orange (couleur principale, dynamique, africaine)
/// - Blanc (fond, espace, neutralité)
/// - Vert (succès, confirmation, croissance)
class CouleursApp {
  CouleursApp._(); // Empêche l'instanciation

  // ─── Couleurs principales (drapeau ivoirien) ─────────────────────
  static const Color orangePrincipal = Color(0xFFF77F00);
  static const Color orangeFonce = Color(0xFFD9620A);
  static const Color orangeClair = Color(0xFFFFA94D);
  static const Color orangeSurface = Color(0xFFFFF1E0);

  static const Color vertPrincipal = Color(0xFF009E60);
  static const Color vertFonce = Color(0xFF00754A);
  static const Color vertClair = Color(0xFF4CAF80);
  static const Color vertSurface = Color(0xFFE3F4EB);

  static const Color blanc = Color(0xFFFFFFFF);

  // ─── Texte ──────────────────────────────────────────────────────
  static const Color textePrincipal = Color(0xFF1A1A1A);
  static const Color texteSecondaire = Color(0xFF666666);
  static const Color texteDesactive = Color(0xFFB0B0B0);

  // ─── Fond ───────────────────────────────────────────────────────
  static const Color fondPrincipal = Color(0xFFFAFAFA);
  static const Color fondSecondaire = Color(0xFFF5F5F5);
  static const Color fondCarte = Color(0xFFFFFFFF);

  // ─── États ──────────────────────────────────────────────────────
  static const Color succes = vertPrincipal;
  static const Color erreur = Color(0xFFE53935);
  static const Color avertissement = Color(0xFFFFA000);
  static const Color information = Color(0xFF1976D2);

  // ─── Bordures et séparateurs ────────────────────────────────────
  static const Color bordure = Color(0xFFE0E0E0);
  static const Color bordureFoncee = Color(0xFFBDBDBD);

  // ─── Mobile Money (couleurs des opérateurs) ─────────────────────
  static const Color wave = Color(0xFF1DB9F2);
  static const Color orangeMoney = Color(0xFFFF6600);
  static const Color mtnMoMo = Color(0xFFFFCB05);
}
