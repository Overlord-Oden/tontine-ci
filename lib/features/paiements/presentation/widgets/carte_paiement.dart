import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../domaine/entites/paiement.dart';

/// Carte affichant un paiement dans l'historique.
class CartePaiement extends StatelessWidget {
  final Paiement paiement;
  final VoidCallback? onTap;

  const CartePaiement({
    super.key,
    required this.paiement,
    this.onTap,
  });

  Color get _couleurStatut {
    switch (paiement.statut) {
      case StatutPaiement.reussi:
        return CouleursApp.vertPrincipal;
      case StatutPaiement.echec:
      case StatutPaiement.annule:
        return CouleursApp.erreur;
      case StatutPaiement.enAttenteOtp:
      case StatutPaiement.enTraitement:
        return CouleursApp.avertissement;
    }
  }

  IconData get _iconeStatut {
    switch (paiement.statut) {
      case StatutPaiement.reussi:
        return Icons.check_circle;
      case StatutPaiement.echec:
        return Icons.error;
      case StatutPaiement.annule:
        return Icons.cancel;
      case StatutPaiement.enAttenteOtp:
      case StatutPaiement.enTraitement:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenu = Container(
      padding: const EdgeInsets.all(TaillesApp.espacement12),
      decoration: BoxDecoration(
        color: CouleursApp.fondCarte,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        border: Border.all(color: CouleursApp.bordure, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: paiement.operateur.couleur,
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
            ),
            child: Center(
              child: Text(
                paiement.operateur.codeCourt,
                style: TextStyle(
                  color: paiement.operateur.couleurTexte,
                  fontWeight: FontWeight.w800,
                  fontSize: paiement.operateur.codeCourt.length > 3 ? 10 : 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: TaillesApp.espacement12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paiement.operateur.libelle,
                  style: const TextStyle(
                    fontSize: TaillesApp.textePetit,
                    fontWeight: FontWeight.w700,
                    color: CouleursApp.textePrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _iconeStatut,
                      size: 12,
                      color: _couleurStatut,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      paiement.statut.libelle,
                      style: TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: _couleurStatut,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${Formatteurs.formatterDateCourte(paiement.dateInitiation)}',
                      style: const TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ),
                  ],
                ),
                if (paiement.referenceOperateur != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Réf. ${paiement.referenceOperateur}',
                    style: const TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      color: CouleursApp.texteDesactive,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatteurs.formatterFCFA(paiement.montant),
                style: const TextStyle(
                  fontSize: TaillesApp.textePetit,
                  fontWeight: FontWeight.w700,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              if (paiement.frais > 0)
                Text(
                  '+${Formatteurs.formatterFCFA(paiement.frais)} frais',
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
            ],
          ),
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
