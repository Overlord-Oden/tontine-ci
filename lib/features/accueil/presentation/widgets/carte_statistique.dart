import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';

/// Carte de statistique compacte affichant un libellé, une valeur et une icône.
///
/// Utilisée sur le tableau de bord d'accueil.
class CarteStatistique extends StatelessWidget {
  final String libelle;
  final String valeur;
  final IconData icone;
  final Color couleurAccent;

  const CarteStatistique({
    super.key,
    required this.libelle,
    required this.valeur,
    required this.icone,
    this.couleurAccent = CouleursApp.orangePrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      decoration: BoxDecoration(
        color: CouleursApp.fondCarte,
        borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
        border: Border.all(color: CouleursApp.bordure, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: couleurAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
            ),
            child: Icon(
              icone,
              size: TaillesApp.iconeMoyenne,
              color: couleurAccent,
            ),
          ),
          const SizedBox(height: TaillesApp.espacement12),
          Text(
            libelle,
            style: const TextStyle(
              fontSize: TaillesApp.texteTresPetit,
              color: CouleursApp.texteSecondaire,
            ),
          ),
          const SizedBox(height: TaillesApp.espacement4),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: TaillesApp.texteGrand,
              fontWeight: FontWeight.w700,
              color: CouleursApp.textePrincipal,
            ),
          ),
        ],
      ),
    );
  }
}
