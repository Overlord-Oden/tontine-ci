import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/utils/formatteurs.dart';

/// Carte affichant les informations principales d'une tontine
/// dans la liste des tontines de l'utilisateur.
class TontineCarte extends StatelessWidget {
  final Tontine tontine;
  final VoidCallback onTap;

  const TontineCarte({
    super.key,
    required this.tontine,
    required this.onTap,
  });

  Color get _couleurStatut {
    switch (tontine.statut) {
      case StatutTontine.active:
        return CouleursApp.vertPrincipal;
      case StatutTontine.brouillon:
        return CouleursApp.avertissement;
      case StatutTontine.terminee:
        return CouleursApp.texteSecondaire;
    }
  }

  Color get _surfaceStatut {
    switch (tontine.statut) {
      case StatutTontine.active:
        return CouleursApp.vertSurface;
      case StatutTontine.brouillon:
        return const Color(0xFFFFF4E5);
      case StatutTontine.terminee:
        return CouleursApp.fondSecondaire;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourEnCours = tontine.tourEnCours;
    final prochainTour = tontine.prochainTour;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
      child: Container(
        padding: const EdgeInsets.all(TaillesApp.espacement16),
        decoration: BoxDecoration(
          color: CouleursApp.fondCarte,
          borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
          border: Border.all(color: CouleursApp.bordure, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : nom + statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tontine.nom,
                        style: const TextStyle(
                          fontSize: TaillesApp.texteMoyen,
                          fontWeight: FontWeight.w700,
                          color: CouleursApp.textePrincipal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: TaillesApp.espacement4),
                      Text(
                        tontine.frequence.libelle,
                        style: const TextStyle(
                          fontSize: TaillesApp.texteTresPetit,
                          color: CouleursApp.texteSecondaire,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TaillesApp.espacement8,
                    vertical: TaillesApp.espacement4,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceStatut,
                    borderRadius:
                        BorderRadius.circular(TaillesApp.rayonPetit),
                  ),
                  child: Text(
                    tontine.statut.libelle,
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      fontWeight: FontWeight.w600,
                      color: _couleurStatut,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TaillesApp.espacement16),

            // Montants
            Row(
              children: [
                Expanded(
                  child: _BlocInfo(
                    libelle: 'Cotisation',
                    valeur: Formatteurs.formatterFCFA(
                      tontine.montantCotisation,
                    ),
                  ),
                ),
                Expanded(
                  child: _BlocInfo(
                    libelle: 'Cagnotte / tour',
                    valeur: Formatteurs.formatterFCFA(
                      tontine.cagnotteParTour,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TaillesApp.espacement12),

            // Pied : membres + prochain tour
            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: TaillesApp.iconePetite,
                  color: CouleursApp.texteSecondaire,
                ),
                const SizedBox(width: TaillesApp.espacement4),
                Text(
                  '${tontine.membres.length} membre'
                  '${tontine.membres.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: TaillesApp.texteTresPetit,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
                const SizedBox(width: TaillesApp.espacement16),
                if (tourEnCours != null) ...[
                  const Icon(
                    Icons.access_time,
                    size: TaillesApp.iconePetite,
                    color: CouleursApp.orangePrincipal,
                  ),
                  const SizedBox(width: TaillesApp.espacement4),
                  Text(
                    'Tour ${tourEnCours.numero} en cours',
                    style: const TextStyle(
                      fontSize: TaillesApp.texteTresPetit,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.orangePrincipal,
                    ),
                  ),
                ] else if (prochainTour != null) ...[
                  const Icon(
                    Icons.event_outlined,
                    size: TaillesApp.iconePetite,
                    color: CouleursApp.texteSecondaire,
                  ),
                  const SizedBox(width: TaillesApp.espacement4),
                  Text(
                    Formatteurs.formatterDateCourte(prochainTour.dateEcheance),
                    style: const TextStyle(
                      fontSize: TaillesApp.texteTresPetit,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlocInfo extends StatelessWidget {
  final String libelle;
  final String valeur;

  const _BlocInfo({required this.libelle, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: TaillesApp.textePetit,
            fontWeight: FontWeight.w700,
            color: CouleursApp.textePrincipal,
          ),
        ),
      ],
    );
  }
}
