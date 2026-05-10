import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/tour.dart';
import '../../../../core/utils/formatteurs.dart';

/// Carte affichant les informations d'un tour de tontine.
///
/// Cliquable si [onTap] est fourni, pour naviguer vers le détail du tour.
class TourCarte extends StatelessWidget {
  final Tour tour;
  final VoidCallback? onTap;

  const TourCarte({super.key, required this.tour, this.onTap});

  Color get _couleurStatut {
    switch (tour.statut) {
      case StatutTour.enCours:
        return CouleursApp.orangePrincipal;
      case StatutTour.termine:
        return CouleursApp.vertPrincipal;
      case StatutTour.aVenir:
        return CouleursApp.texteSecondaire;
    }
  }

  Color get _surfaceStatut {
    switch (tour.statut) {
      case StatutTour.enCours:
        return CouleursApp.orangeSurface;
      case StatutTour.termine:
        return CouleursApp.vertSurface;
      case StatutTour.aVenir:
        return CouleursApp.fondSecondaire;
    }
  }

  IconData get _iconeStatut {
    switch (tour.statut) {
      case StatutTour.enCours:
        return Icons.access_time;
      case StatutTour.termine:
        return Icons.check_circle_outline;
      case StatutTour.aVenir:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenu = Container(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      decoration: BoxDecoration(
        color: CouleursApp.fondCarte,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        border: Border.all(color: CouleursApp.bordure, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _surfaceStatut,
                  borderRadius:
                      BorderRadius.circular(TaillesApp.rayonPetit),
                ),
                child: Icon(
                  _iconeStatut,
                  color: _couleurStatut,
                  size: TaillesApp.iconeMoyenne,
                ),
              ),
              const SizedBox(width: TaillesApp.espacement12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tour ${tour.numero}',
                      style: const TextStyle(
                        fontSize: TaillesApp.textePetit,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.textePrincipal,
                      ),
                    ),
                    Text(
                      tour.statut.libelle,
                      style: TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: _couleurStatut,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatteurs.formatterDateCourte(tour.dateEcheance),
                style: const TextStyle(
                  fontSize: TaillesApp.texteTresPetit,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: TaillesApp.espacement4),
                const Icon(
                  Icons.chevron_right,
                  color: CouleursApp.texteDesactive,
                  size: TaillesApp.iconeMoyenne,
                ),
              ],
            ],
          ),
          const SizedBox(height: TaillesApp.espacement12),
          const Divider(height: 1, color: CouleursApp.bordure),
          const SizedBox(height: TaillesApp.espacement12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bénéficiaire',
                      style: TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tour.nomBeneficiaire,
                      style: const TextStyle(
                        fontSize: TaillesApp.textePetit,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.textePrincipal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Cagnotte',
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatteurs.formatterFCFA(tour.montantTotal),
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      fontWeight: FontWeight.w700,
                      color: CouleursApp.vertPrincipal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (tour.statut == StatutTour.enCours) ...[
            const SizedBox(height: TaillesApp.espacement12),
            ClipRRect(
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
              child: LinearProgressIndicator(
                value: tour.progression,
                minHeight: 6,
                backgroundColor: CouleursApp.fondSecondaire,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CouleursApp.orangePrincipal,
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacement4),
            Text(
              '${tour.nombreCotisationsRecues}/'
              '${tour.nombreCotisationsAttendues} cotisations reçues',
              style: const TextStyle(
                fontSize: TaillesApp.texteMicro,
                color: CouleursApp.texteSecondaire,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return contenu;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      child: contenu,
    );
  }
}
