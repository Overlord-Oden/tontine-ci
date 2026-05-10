import 'package:flutter/material.dart';

import '../../core/constantes/couleurs.dart';
import '../../core/constantes/tailles.dart';

/// Carte stat compacte avec icône, libellé et valeur.
///
/// Variant "rich" du widget CarteStatistique : autorise un sous-libellé
/// optionnel (ex : "+12 % vs mois dernier").
class CarteStatRiche extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final String valeur;
  final String? sousLibelle;
  final Color couleur;

  const CarteStatRiche({
    super.key,
    required this.icone,
    required this.libelle,
    required this.valeur,
    this.sousLibelle,
    this.couleur = CouleursApp.orangePrincipal,
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
            ),
            child: Icon(icone, color: couleur, size: TaillesApp.iconeMoyenne),
          ),
          const SizedBox(width: TaillesApp.espacement12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libelle,
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMoyen,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.textePrincipal,
                  ),
                ),
                if (sousLibelle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sousLibelle!,
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      color: couleur,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
