import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/membre.dart';

/// Ligne affichant un membre d'une tontine.
class MembreLigne extends StatelessWidget {
  final Membre membre;
  final bool estUtilisateurCourant;
  final VoidCallback? onRetirer;

  const MembreLigne({
    super.key,
    required this.membre,
    this.estUtilisateurCourant = false,
    this.onRetirer,
  });

  Color get _couleurStatut {
    switch (membre.statut) {
      case StatutMembre.actif:
        return CouleursApp.vertPrincipal;
      case StatutMembre.invite:
        return CouleursApp.avertissement;
      case StatutMembre.retire:
        return CouleursApp.texteSecondaire;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TaillesApp.espacement16,
        vertical: TaillesApp.espacement12,
      ),
      decoration: const BoxDecoration(
        color: CouleursApp.fondCarte,
        border: Border(
          bottom: BorderSide(color: CouleursApp.bordure, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar avec ordre de passage en bulle
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: CouleursApp.orangeSurface,
                child: Text(
                  membre.initiales,
                  style: const TextStyle(
                    color: CouleursApp.orangePrincipal,
                    fontWeight: FontWeight.w700,
                    fontSize: TaillesApp.textePetit,
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: CouleursApp.orangePrincipal,
                    shape: BoxShape.circle,
                    border: Border.all(color: CouleursApp.blanc, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${membre.ordrePassage}',
                      style: const TextStyle(
                        color: CouleursApp.blanc,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: TaillesApp.espacement16),

          // Nom et numéro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        membre.nomAffichage,
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
                Text(
                  membre.numeroTelephone,
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),

          // Badges rôle + statut
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (membre.role == RoleMembre.admin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: CouleursApp.orangeSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.orangePrincipal,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                membre.statut.libelle,
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  color: _couleurStatut,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (onRetirer != null) ...[
            const SizedBox(width: TaillesApp.espacement8),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: CouleursApp.erreur,
                size: TaillesApp.iconeMoyenne,
              ),
              onPressed: onRetirer,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}
