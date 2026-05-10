import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../../paiements/domaine/entites/paiement.dart';
import '../../../paiements/presentation/providers/paiement_provider.dart';
import '../../../paiements/presentation/widgets/carte_paiement.dart';

/// Onglet **Paiements** : historique de tous les paiements de l'utilisateur.
class PaiementsEcran extends StatefulWidget {
  const PaiementsEcran({super.key});

  @override
  State<PaiementsEcran> createState() => _PaiementsEcranState();
}

class _PaiementsEcranState extends State<PaiementsEcran> {
  bool _premierChargement = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    final auth = context.read<AuthProvider>();
    if (auth.utilisateur == null) return;
    await context
        .read<PaiementProvider>()
        .chargerHistoriqueMembre(auth.utilisateur!.id);
    if (mounted) setState(() => _premierChargement = false);
  }

  @override
  Widget build(BuildContext context) {
    final paiementProvider = context.watch<PaiementProvider>();
    final paiements = paiementProvider.historique;

    if (_premierChargement) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _charger,
        color: CouleursApp.orangePrincipal,
        child: paiements.isEmpty
            ? _ListeVide()
            : _construireListe(paiements),
      ),
    );
  }

  Widget _construireListe(List<Paiement> paiements) {
    final reussis = paiements.where(
      (p) => p.statut == StatutPaiement.reussi,
    );
    final totalEnvoye = reussis.fold<num>(0, (acc, p) => acc + p.montant);
    final totalFrais = reussis.fold<num>(0, (acc, p) => acc + p.frais);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(TaillesApp.espacement20),
      children: [
        // Carte récap
        Container(
          padding: const EdgeInsets.all(TaillesApp.espacement20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                CouleursApp.vertPrincipal,
                CouleursApp.vertFonce,
              ],
            ),
            borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total payé via Mobile Money',
                style: TextStyle(
                  fontSize: TaillesApp.textePetit,
                  color: CouleursApp.blanc,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement4),
              Text(
                Formatteurs.formatterFCFA(totalEnvoye),
                style: const TextStyle(
                  fontSize: TaillesApp.texteTitre,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.blanc,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement4),
              Text(
                'dont ${Formatteurs.formatterFCFA(totalFrais)} de frais',
                style: const TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  color: CouleursApp.blanc,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TaillesApp.espacement24),

        // Liste des transactions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TRANSACTIONS',
              style: TextStyle(
                fontSize: TaillesApp.texteMicro,
                fontWeight: FontWeight.w600,
                color: CouleursApp.texteSecondaire,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${paiements.length}',
              style: const TextStyle(
                fontSize: TaillesApp.texteMicro,
                color: CouleursApp.texteSecondaire,
              ),
            ),
          ],
        ),
        const SizedBox(height: TaillesApp.espacement12),
        ...paiements.map((p) => Padding(
              padding: const EdgeInsets.only(
                bottom: TaillesApp.espacement8,
              ),
              child: CartePaiement(paiement: p),
            )),
      ],
    );
  }
}

class _ListeVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(TaillesApp.espacement32),
      children: [
        const SizedBox(height: TaillesApp.espacement64),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: CouleursApp.vertSurface,
              borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
            ),
            child: const Icon(
              Icons.payments_outlined,
              size: 56,
              color: CouleursApp.vertPrincipal,
            ),
          ),
        ),
        const SizedBox(height: TaillesApp.espacement24),
        const Text(
          'Aucun paiement pour le moment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: TaillesApp.texteGrand,
            fontWeight: FontWeight.w600,
            color: CouleursApp.textePrincipal,
          ),
        ),
        const SizedBox(height: TaillesApp.espacement8),
        const Text(
          'Vos paiements Wave, Orange Money et MTN MoMo\n'
          'apparaîtront ici dès votre première cotisation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: TaillesApp.textePetit,
            color: CouleursApp.texteSecondaire,
          ),
        ),
      ],
    );
  }
}
