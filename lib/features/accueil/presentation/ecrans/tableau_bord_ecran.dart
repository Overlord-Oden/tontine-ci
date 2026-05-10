import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../../cotisations/presentation/ecrans/detail_tour_ecran.dart';
import '../../../notifications/presentation/widgets/icone_cloche.dart';
import '../../../tontines/presentation/providers/tontine_provider.dart';
import '../widgets/carte_statistique.dart';

/// Onglet **Accueil** : salutation + statistiques + tontines actives.
class TableauBordEcran extends StatefulWidget {
  const TableauBordEcran({super.key});

  @override
  State<TableauBordEcran> createState() => _TableauBordEcranState();
}

class _TableauBordEcranState extends State<TableauBordEcran> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final tp = context.read<TontineProvider>();
      if (auth.utilisateur != null && tp.tontines.isEmpty) {
        tp.chargerMesTontines(auth.utilisateur!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final tontineProvider = context.watch<TontineProvider>();
    final tontinesActives =
        tontineProvider.tontinesParStatut(StatutTontine.active);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TaillesApp.espacement20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salutation
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: CouleursApp.orangeSurface,
                  child: Text(
                    utilisateur?.initiales ?? '?',
                    style: const TextStyle(
                      color: CouleursApp.orangePrincipal,
                      fontWeight: FontWeight.w700,
                      fontSize: TaillesApp.texteMoyen,
                    ),
                  ),
                ),
                const SizedBox(width: TaillesApp.espacement12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ChainesApp.accueilSalutation,
                        style: TextStyle(
                          fontSize: TaillesApp.textePetit,
                          color: CouleursApp.texteSecondaire,
                        ),
                      ),
                      Text(
                        utilisateur?.prenom ?? 'Invité',
                        style: const TextStyle(
                          fontSize: TaillesApp.texteGrand,
                          fontWeight: FontWeight.w700,
                          color: CouleursApp.textePrincipal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconeCloche(
                  onTap: () {
                    Navigator.of(context).pushNamed(RoutesNoms.notifications);
                  },
                ),
              ],
            ),
            const SizedBox(height: TaillesApp.espacement32),

            // Bannière dynamique
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TaillesApp.espacement20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CouleursApp.orangePrincipal,
                    CouleursApp.orangeFonce,
                  ],
                ),
                borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tontinesActives.isEmpty
                        ? 'Bienvenue sur TontineApp 🎉'
                        : 'Bonjour ${utilisateur?.prenom ?? ""} 👋',
                    style: const TextStyle(
                      fontSize: TaillesApp.texteGrand,
                      fontWeight: FontWeight.w700,
                      color: CouleursApp.blanc,
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement8),
                  Text(
                    tontinesActives.isEmpty
                        ? 'Vos prochaines tontines apparaîtront ici. Créez ou rejoignez un groupe pour commencer.'
                        : 'Vous avez ${tontinesActives.length} tontine'
                            '${tontinesActives.length > 1 ? "s" : ""} active'
                            '${tontinesActives.length > 1 ? "s" : ""}.',
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      color: CouleursApp.blanc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TaillesApp.espacement24),

            // Statistiques (vraies données maintenant)
            Row(
              children: [
                Expanded(
                  child: CarteStatistique(
                    libelle: ChainesApp.accueilTontinesActives,
                    valeur: '${tontinesActives.length}',
                    icone: Icons.groups_outlined,
                  ),
                ),
                const SizedBox(width: TaillesApp.espacement12),
                Expanded(
                  child: CarteStatistique(
                    libelle: ChainesApp.accueilCotisationsEnAttente,
                    valeur: '${tontineProvider.cotisationsEnAttente}',
                    icone: Icons.pending_actions_outlined,
                    couleurAccent: CouleursApp.avertissement,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TaillesApp.espacement12),
            CarteStatistique(
              libelle: ChainesApp.accueilTotalEpargne,
              valeur: Formatteurs.formatterFCFA(tontineProvider.totalEpargne),
              icone: Icons.savings_outlined,
              couleurAccent: CouleursApp.vertPrincipal,
            ),
            const SizedBox(height: TaillesApp.espacement32),

            // Section tontines actives
            if (tontinesActives.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes tontines actives',
                    style: TextStyle(
                      fontSize: TaillesApp.texteMoyen,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.textePrincipal,
                    ),
                  ),
                  Text(
                    '${tontinesActives.length}',
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TaillesApp.espacement12),
              ...tontinesActives.take(3).map((t) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: TaillesApp.espacement8,
                    ),
                    child: _MiniTontineCarte(
                      tontine: t,
                      onTap: () {
                        final tour = t.tourEnCours;
                        if (tour != null) {
                          Navigator.of(context).pushNamed(
                            RoutesNoms.detailTour,
                            arguments: ArgumentsDetailTour(
                              idTontine: t.id,
                              idTour: tour.id,
                            ),
                          );
                        } else {
                          Navigator.of(context).pushNamed(
                            RoutesNoms.detailTontine,
                            arguments: t.id,
                          );
                        }
                      },
                    ),
                  )),
            ] else ...[
              const Text(
                'Prochaines étapes',
                style: TextStyle(
                  fontSize: TaillesApp.texteMoyen,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement12),
              const _CarteEtape(
                numero: '1',
                titre: 'Créer une tontine',
                description: 'Disponible — Sprint 2 ✅',
                icone: Icons.add_circle_outline,
              ),
              const SizedBox(height: TaillesApp.espacement8),
              const _CarteEtape(
                numero: '2',
                titre: 'Inviter des membres',
                description: 'Disponible — Sprint 2 ✅',
                icone: Icons.person_add_outlined,
              ),
              const SizedBox(height: TaillesApp.espacement8),
              const _CarteEtape(
                numero: '3',
                titre: 'Cotiser via Mobile Money',
                description: 'Disponible au Sprint 4',
                icone: Icons.phone_android_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTontineCarte extends StatelessWidget {
  final Tontine tontine;
  final VoidCallback onTap;

  const _MiniTontineCarte({required this.tontine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tourEnCours = tontine.tourEnCours;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
      child: Container(
        padding: const EdgeInsets.all(TaillesApp.espacement12),
        decoration: BoxDecoration(
          color: CouleursApp.fondCarte,
          borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
          border: Border.all(color: CouleursApp.bordure, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CouleursApp.orangeSurface,
                borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
              ),
              child: const Icon(
                Icons.groups,
                color: CouleursApp.orangePrincipal,
              ),
            ),
            const SizedBox(width: TaillesApp.espacement12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tontine.nom,
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.textePrincipal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tourEnCours != null)
                    Text(
                      'Tour ${tourEnCours.numero} — '
                      '${tourEnCours.nomBeneficiaire}',
                      style: const TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteSecondaire,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Text(
              Formatteurs.formatterFCFA(tontine.montantCotisation),
              style: const TextStyle(
                fontSize: TaillesApp.texteTresPetit,
                fontWeight: FontWeight.w700,
                color: CouleursApp.vertPrincipal,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: CouleursApp.texteDesactive,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteEtape extends StatelessWidget {
  final String numero;
  final String titre;
  final String description;
  final IconData icone;

  const _CarteEtape({
    required this.numero,
    required this.titre,
    required this.description,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      decoration: BoxDecoration(
        color: CouleursApp.fondCarte,
        borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
        border: Border.all(color: CouleursApp.bordure, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: CouleursApp.orangeSurface,
            child: Text(
              numero,
              style: const TextStyle(
                color: CouleursApp.orangePrincipal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: TaillesApp.espacement12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: TaillesApp.textePetit,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.textePrincipal,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: TaillesApp.texteTresPetit,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icone,
            size: TaillesApp.iconeMoyenne,
            color: CouleursApp.texteDesactive,
          ),
        ],
      ),
    );
  }
}
