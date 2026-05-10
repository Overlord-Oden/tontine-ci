import 'package:flutter/material.dart';

import '../../core/constantes/couleurs.dart';
import '../../core/constantes/tailles.dart';

/// Bouton primaire orange réutilisable de la TontineApp.
///
/// Affiche un indicateur de chargement quand [enChargement] est `true`.
class BoutonPrimaire extends StatelessWidget {
  final String libelle;
  final VoidCallback? onPressed;
  final bool enChargement;
  final IconData? icone;

  const BoutonPrimaire({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.enChargement = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enChargement ? null : onPressed,
      child: enChargement
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CouleursApp.blanc,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: TaillesApp.iconeMoyenne),
                  const SizedBox(width: TaillesApp.espacement8),
                ],
                Text(libelle),
              ],
            ),
    );
  }
}
