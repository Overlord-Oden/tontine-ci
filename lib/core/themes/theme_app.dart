import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constantes/couleurs.dart';
import '../constantes/tailles.dart';

/// Thème principal de la TontineApp.
///
/// Basé sur Material 3, avec :
/// - une seed color orange (drapeau ivoirien)
/// - une typographie Roboto par défaut (système)
/// - des composants harmonisés (boutons, champs, cartes)
class ThemeApp {
  ThemeApp._();

  static ThemeData get themeClair {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: CouleursApp.orangePrincipal,
      primary: CouleursApp.orangePrincipal,
      onPrimary: CouleursApp.blanc,
      secondary: CouleursApp.vertPrincipal,
      onSecondary: CouleursApp.blanc,
      error: CouleursApp.erreur,
      surface: CouleursApp.blanc,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CouleursApp.fondPrincipal,
      fontFamily: 'Roboto',

      // ─── AppBar ────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: CouleursApp.blanc,
        foregroundColor: CouleursApp.textePrincipal,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: CouleursApp.textePrincipal,
          fontSize: TaillesApp.texteGrand,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Boutons elevated ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.orangePrincipal,
          foregroundColor: CouleursApp.blanc,
          minimumSize: const Size(double.infinity, TaillesApp.hauteurBouton),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          ),
          textStyle: const TextStyle(
            fontSize: TaillesApp.texteMoyen,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // ─── Boutons texte ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CouleursApp.orangePrincipal,
          textStyle: const TextStyle(
            fontSize: TaillesApp.textePetit,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── Champs de saisie ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CouleursApp.blanc,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TaillesApp.espacement16,
          vertical: TaillesApp.espacement16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          borderSide: const BorderSide(color: CouleursApp.bordure),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          borderSide: const BorderSide(color: CouleursApp.bordure),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          borderSide: const BorderSide(
            color: CouleursApp.orangePrincipal,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          borderSide: const BorderSide(color: CouleursApp.erreur),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          borderSide: const BorderSide(
            color: CouleursApp.erreur,
            width: 1.5,
          ),
        ),
        labelStyle: const TextStyle(
          color: CouleursApp.texteSecondaire,
          fontSize: TaillesApp.textePetit,
        ),
        hintStyle: const TextStyle(
          color: CouleursApp.texteDesactive,
          fontSize: TaillesApp.texteMoyen,
        ),
      ),

      // ─── Cartes ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: CouleursApp.fondCarte,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
          side: const BorderSide(color: CouleursApp.bordure, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Navigation Bar (bottom) ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CouleursApp.blanc,
        indicatorColor: CouleursApp.orangeSurface,
        height: TaillesApp.hauteurNavigationBas,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: TaillesApp.texteTresPetit,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: CouleursApp.orangePrincipal);
          }
          return const IconThemeData(color: CouleursApp.texteSecondaire);
        }),
      ),

      // ─── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CouleursApp.textePrincipal,
        contentTextStyle: const TextStyle(
          color: CouleursApp.blanc,
          fontSize: TaillesApp.textePetit,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        ),
      ),
    );
  }
}
