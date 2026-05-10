import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../domaine/entites/operateur_mm.dart';

/// Carte pour sélectionner un opérateur Mobile Money.
///
/// Affiche le logo simulé (initiales sur fond couleur), le nom et le baseline.
/// Tappable, avec effet de surbrillance si sélectionné.
class CarteOperateur extends StatelessWidget {
  final OperateurMM operateur;
  final bool selectionne;
  final VoidCallback onTap;

  const CarteOperateur({
    super.key,
    required this.operateur,
    required this.selectionne,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(TaillesApp.espacement16),
        decoration: BoxDecoration(
          color: selectionne ? operateur.couleur : CouleursApp.fondCarte,
          borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
          border: Border.all(
            color: selectionne ? operateur.couleur : CouleursApp.bordure,
            width: selectionne ? 2 : 1,
          ),
          boxShadow: selectionne
              ? [
                  BoxShadow(
                    color: operateur.couleur.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Logo carré simulé
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selectionne
                    ? operateur.couleurTexte.withValues(alpha: 0.2)
                    : operateur.couleur,
                borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
              ),
              child: Center(
                child: Text(
                  operateur.codeCourt,
                  style: TextStyle(
                    color: selectionne
                        ? operateur.couleurTexte
                        : operateur.couleurTexte,
                    fontWeight: FontWeight.w800,
                    fontSize: operateur.codeCourt.length > 3 ? 11 : 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: TaillesApp.espacement16),

            // Nom et baseline
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operateur.libelle,
                    style: TextStyle(
                      fontSize: TaillesApp.texteMoyen,
                      fontWeight: FontWeight.w700,
                      color: selectionne
                          ? operateur.couleurTexte
                          : CouleursApp.textePrincipal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    operateur.baseline,
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      color: selectionne
                          ? operateur.couleurTexte.withValues(alpha: 0.85)
                          : CouleursApp.texteSecondaire,
                    ),
                  ),
                ],
              ),
            ),

            // Frais
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Frais',
                  style: TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: selectionne
                        ? operateur.couleurTexte.withValues(alpha: 0.7)
                        : CouleursApp.texteSecondaire,
                  ),
                ),
                Text(
                  '${(operateur.tauxFrais * 100).toStringAsFixed(1)} %',
                  style: TextStyle(
                    fontSize: TaillesApp.textePetit,
                    fontWeight: FontWeight.w700,
                    color: selectionne
                        ? operateur.couleurTexte
                        : CouleursApp.textePrincipal,
                  ),
                ),
              ],
            ),

            const SizedBox(width: TaillesApp.espacement8),
            Icon(
              selectionne
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selectionne
                  ? operateur.couleurTexte
                  : CouleursApp.texteDesactive,
            ),
          ],
        ),
      ),
    );
  }
}
