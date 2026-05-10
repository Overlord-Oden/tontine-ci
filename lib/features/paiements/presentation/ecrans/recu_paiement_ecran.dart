import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../providers/paiement_provider.dart';

/// Écran 3 du flux : reçu de paiement réussi.
///
/// Affiche un check animé, les détails de la transaction, et un bouton
/// pour revenir au tour.
class RecuPaiementEcran extends StatefulWidget {
  const RecuPaiementEcran({super.key});

  @override
  State<RecuPaiementEcran> createState() => _RecuPaiementEcranState();
}

class _RecuPaiementEcranState extends State<RecuPaiementEcran>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animScale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animScale = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paiement = context.watch<PaiementProvider>().paiementCourant;

    if (paiement == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Aucun paiement')),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      // Pas d'AppBar : retour forcé via le bouton
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TaillesApp.espacement24),
                child: Column(
                  children: [
                    const SizedBox(height: TaillesApp.espacement32),

                    // Animation check
                    ScaleTransition(
                      scale: _animScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: CouleursApp.vertPrincipal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: CouleursApp.blanc,
                          size: 72,
                        ),
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement24),

                    const Text(
                      'Paiement réussi !',
                      style: TextStyle(
                        fontSize: TaillesApp.texteTitre,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.textePrincipal,
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement8),
                    Text(
                      Formatteurs.formatterFCFA(paiement.montant),
                      style: const TextStyle(
                        fontSize: TaillesApp.texteTitreTresGrand,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.vertPrincipal,
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement4),
                    Text(
                      'envoyés via ${paiement.operateur.libelle}',
                      style: const TextStyle(
                        fontSize: TaillesApp.textePetit,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacement32),

                    // Détails de la transaction
                    Container(
                      padding: const EdgeInsets.all(TaillesApp.espacement16),
                      decoration: BoxDecoration(
                        color: CouleursApp.fondCarte,
                        borderRadius:
                            BorderRadius.circular(TaillesApp.rayonGrand),
                        border: Border.all(
                          color: CouleursApp.bordure,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _ligne('Référence', paiement.referenceOperateur ?? '—'),
                          const Divider(height: 24),
                          _ligne(
                            'Montant',
                            Formatteurs.formatterFCFA(paiement.montant),
                          ),
                          const SizedBox(height: TaillesApp.espacement8),
                          _ligne(
                            'Frais ${paiement.operateur.libelle}',
                            Formatteurs.formatterFCFA(paiement.frais),
                          ),
                          const Divider(height: 24),
                          _ligne(
                            'Total débité',
                            Formatteurs.formatterFCFA(paiement.montantTotal),
                            gras: true,
                          ),
                          const Divider(height: 24),
                          _ligne(
                            'Numéro débité',
                            paiement.numeroTelephoneMM,
                          ),
                          const SizedBox(height: TaillesApp.espacement8),
                          _ligne(
                            'Date',
                            paiement.dateConfirmation != null
                                ? Formatteurs.formatterDateLongue(
                                    paiement.dateConfirmation!,
                                  )
                                : '—',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: TaillesApp.espacement16),

                    // Note
                    Container(
                      padding: const EdgeInsets.all(TaillesApp.espacement12),
                      decoration: BoxDecoration(
                        color: CouleursApp.vertSurface,
                        borderRadius:
                            BorderRadius.circular(TaillesApp.rayonPetit),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: CouleursApp.vertFonce,
                            size: TaillesApp.iconeMoyenne,
                          ),
                          SizedBox(width: TaillesApp.espacement8),
                          Expanded(
                            child: Text(
                              'Votre cotisation a été automatiquement validée. '
                              'Aucune action de l\'admin n\'est nécessaire.',
                              style: TextStyle(
                                fontSize: TaillesApp.textePetit,
                                color: CouleursApp.vertFonce,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(TaillesApp.espacement20),
              child: BoutonPrimaire(
                libelle: 'Retour à la tontine',
                icone: Icons.check,
                onPressed: () {
                  // Pop jusqu'au détail tour
                  Navigator.of(context).popUntil((r) => r.isFirst ||
                      r.settings.name?.contains('tours/detail') == true);
                  // Réinitialise l'état du provider
                  context.read<PaiementProvider>().reinitialiser();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ligne(String libelle, String valeur, {bool gras = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          libelle,
          style: const TextStyle(
            fontSize: TaillesApp.textePetit,
            color: CouleursApp.texteSecondaire,
          ),
        ),
        Flexible(
          child: Text(
            valeur,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: TaillesApp.textePetit,
              fontWeight: gras ? FontWeight.w700 : FontWeight.w600,
              color: CouleursApp.textePrincipal,
            ),
          ),
        ),
      ],
    );
  }
}
