import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/cotisation.dart';
import '../../../../core/utils/formatteurs.dart';

/// Carte affichant la cotisation d'un membre pour un tour.
///
/// Affiche : nom, montant, statut, et action contextuelle (Payer / Valider).
class CotisationCarte extends StatelessWidget {
  final Cotisation cotisation;
  final bool estUtilisateurCourant;
  final bool peutValider; // l'utilisateur courant est admin
  final VoidCallback? onMarquerPayee;
  final VoidCallback? onValider;
  final VoidCallback? onAnnuler;

  const CotisationCarte({
    super.key,
    required this.cotisation,
    this.estUtilisateurCourant = false,
    this.peutValider = false,
    this.onMarquerPayee,
    this.onValider,
    this.onAnnuler,
  });

  Color get _couleurStatut {
    switch (cotisation.statut) {
      case StatutCotisation.beneficiaire:
        return CouleursApp.orangePrincipal;
      case StatutCotisation.attendue:
        return CouleursApp.avertissement;
      case StatutCotisation.payee:
        return CouleursApp.information;
      case StatutCotisation.validee:
        return CouleursApp.vertPrincipal;
    }
  }

  Color get _surfaceStatut {
    switch (cotisation.statut) {
      case StatutCotisation.beneficiaire:
        return CouleursApp.orangeSurface;
      case StatutCotisation.attendue:
        return const Color(0xFFFFF4E5);
      case StatutCotisation.payee:
        return const Color(0xFFE3F2FD);
      case StatutCotisation.validee:
        return CouleursApp.vertSurface;
    }
  }

  IconData get _iconeStatut {
    switch (cotisation.statut) {
      case StatutCotisation.beneficiaire:
        return Icons.star_rounded;
      case StatutCotisation.attendue:
        return Icons.schedule;
      case StatutCotisation.payee:
        return Icons.hourglass_top;
      case StatutCotisation.validee:
        return Icons.check_circle;
    }
  }

  String get _initiales {
    final parties = cotisation.nomMembre.trim().split(RegExp(r'\s+'));
    if (parties.isEmpty) return '?';
    if (parties.length == 1) {
      return parties.first.substring(0, 1).toUpperCase();
    }
    return (parties.first.substring(0, 1) + parties.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      decoration: BoxDecoration(
        color: CouleursApp.fondCarte,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        border: Border.all(
          color: estUtilisateurCourant
              ? CouleursApp.orangePrincipal.withValues(alpha: 0.5)
              : CouleursApp.bordure,
          width: estUtilisateurCourant ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: _surfaceStatut,
                child: Text(
                  _initiales,
                  style: TextStyle(
                    color: _couleurStatut,
                    fontWeight: FontWeight.w700,
                    fontSize: TaillesApp.textePetit,
                  ),
                ),
              ),
              const SizedBox(width: TaillesApp.espacement12),

              // Nom et statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            cotisation.nomMembre,
                            style: const TextStyle(
                              fontSize: TaillesApp.textePetit,
                              fontWeight: FontWeight.w600,
                              color: CouleursApp.textePrincipal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (estUtilisateurCourant) ...[
                          const SizedBox(width: TaillesApp.espacement4),
                          const Text(
                            '(vous)',
                            style: TextStyle(
                              fontSize: TaillesApp.texteMicro,
                              color: CouleursApp.texteSecondaire,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          _iconeStatut,
                          size: TaillesApp.iconePetite,
                          color: _couleurStatut,
                        ),
                        const SizedBox(width: TaillesApp.espacement4),
                        Text(
                          cotisation.statut.libelle,
                          style: TextStyle(
                            fontSize: TaillesApp.texteMicro,
                            color: _couleurStatut,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (cotisation.dateValidation != null) ...[
                          const SizedBox(width: TaillesApp.espacement8),
                          Text(
                            '· ${Formatteurs.formatterDateCourte(cotisation.dateValidation!)}',
                            style: const TextStyle(
                              fontSize: TaillesApp.texteMicro,
                              color: CouleursApp.texteSecondaire,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Montant
              Text(
                cotisation.estBeneficiaire
                    ? '—'
                    : Formatteurs.formatterFCFA(cotisation.montant),
                style: TextStyle(
                  fontSize: TaillesApp.textePetit,
                  fontWeight: FontWeight.w700,
                  color: cotisation.estBeneficiaire
                      ? CouleursApp.texteDesactive
                      : CouleursApp.textePrincipal,
                ),
              ),
            ],
          ),

          // Boutons d'action contextuels
          if (_doitAfficherActions) ...[
            const SizedBox(height: TaillesApp.espacement12),
            const Divider(height: 1, color: CouleursApp.bordure),
            const SizedBox(height: TaillesApp.espacement8),
            _construireActions(),
          ],
        ],
      ),
    );
  }

  bool get _doitAfficherActions {
    if (cotisation.estBeneficiaire) return false;
    // Bouton "Marquer payée" disponible si c'est ma cotisation et qu'elle est attendue
    if (estUtilisateurCourant && cotisation.statut == StatutCotisation.attendue) {
      return onMarquerPayee != null;
    }
    // Boutons admin : valider une cotisation payée, ou annuler
    if (peutValider && cotisation.statut == StatutCotisation.payee) {
      return onValider != null || onAnnuler != null;
    }
    if (peutValider &&
        cotisation.statut == StatutCotisation.attendue &&
        !estUtilisateurCourant) {
      return onValider != null;
    }
    return false;
  }

  Widget _construireActions() {
    // Action utilisateur : payer via Mobile Money
    if (estUtilisateurCourant &&
        cotisation.statut == StatutCotisation.attendue &&
        onMarquerPayee != null) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarquerPayee,
              icon: const Icon(Icons.phone_android,
                  size: TaillesApp.iconePetite),
              label: const Text('Payer via Mobile Money'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                textStyle: const TextStyle(
                  fontSize: TaillesApp.textePetit,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Actions admin
    if (peutValider) {
      if (cotisation.statut == StatutCotisation.payee) {
        return Row(
          children: [
            if (onAnnuler != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: onAnnuler,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    foregroundColor: CouleursApp.erreur,
                    side: const BorderSide(color: CouleursApp.erreur),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
            if (onAnnuler != null && onValider != null)
              const SizedBox(width: TaillesApp.espacement8),
            if (onValider != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onValider,
                  icon: const Icon(Icons.verified,
                      size: TaillesApp.iconePetite),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vertPrincipal,
                    minimumSize: const Size(double.infinity, 40),
                    textStyle: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                    ),
                  ),
                ),
              ),
          ],
        );
      }
      // Cotisation attendue d'un autre membre : option de marquer reçue directement
      if (cotisation.statut == StatutCotisation.attendue && onValider != null) {
        return OutlinedButton.icon(
          onPressed: onValider,
          icon: const Icon(Icons.payment, size: TaillesApp.iconePetite),
          label: const Text('Marquer reçue (admin)'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            foregroundColor: CouleursApp.vertPrincipal,
            side: const BorderSide(color: CouleursApp.vertPrincipal),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}
