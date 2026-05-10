import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/donnees/stockage_json.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../shared/widgets/carte_stat_riche.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../../paiements/domaine/entites/paiement.dart';
import '../../../paiements/presentation/providers/paiement_provider.dart';
import '../../../tontines/presentation/providers/tontine_provider.dart';

/// Onglet **Profil** : informations + stats + paramètres + déconnexion.
class ProfilEcran extends StatefulWidget {
  const ProfilEcran({super.key});

  @override
  State<ProfilEcran> createState() => _ProfilEcranState();
}

class _ProfilEcranState extends State<ProfilEcran> {
  @override
  void initState() {
    super.initState();
    // Charge l'historique de paiements pour pouvoir afficher les stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.utilisateur != null) {
        context
            .read<PaiementProvider>()
            .chargerHistoriqueMembre(auth.utilisateur!.id);
      }
    });
  }

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez ressaisir votre numéro pour vous reconnecter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: CouleursApp.erreur),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;
    await context.read<AuthProvider>().seDeconnecter();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      RoutesNoms.connexion,
      (_) => false,
    );
  }

  Future<void> _reinitialiserDonneesDemo(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: CouleursApp.avertissement,
          size: 48,
        ),
        title: const Text('Réinitialiser les données ?'),
        content: const Text(
          'Toutes les tontines, membres, cotisations, paiements et notifications '
          'seront supprimés. Les 3 tontines de démo seront recréées au prochain '
          'lancement.\n\nVotre compte utilisateur restera intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: CouleursApp.erreur),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );

    if (confirme != true || !context.mounted) return;
    await StockageJson().effacerTout();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Données effacées. L\'app va se fermer pour recharger les démos.',
        ),
        backgroundColor: CouleursApp.information,
        duration: Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 2), SystemNavigator.pop);
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;
    final tontineProvider = context.watch<TontineProvider>();
    final paiementProvider = context.watch<PaiementProvider>();

    // Calculs stats
    final tontinesActives = tontineProvider.tontines
        .where((t) => t.tourEnCours != null)
        .length;
    final totalCotise = paiementProvider.historique
        .where((p) => p.statut == StatutPaiement.reussi)
        .fold<num>(0, (acc, p) => acc + p.montant);

    // Total reçu : somme des cagnottes des tours où l'utilisateur est bénéficiaire ET terminés
    num totalRecu = 0;
    if (utilisateur != null) {
      for (final t in tontineProvider.tontines) {
        for (final tour in t.toursTermines) {
          // Le bénéficiaire est-il l'utilisateur courant ?
          final membre = t.membres.firstWhere(
            (m) => m.id == tour.idMembreBeneficiaire,
            orElse: () => t.membres.first,
          );
          if (membre.idUtilisateur == utilisateur.id) {
            totalRecu += tour.montantTotal;
          }
        }
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TaillesApp.espacement20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TaillesApp.espacement16),

            // Avatar et nom
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: CouleursApp.orangeSurface,
                    child: Text(
                      utilisateur?.initiales ?? '?',
                      style: const TextStyle(
                        color: CouleursApp.orangePrincipal,
                        fontWeight: FontWeight.w700,
                        fontSize: TaillesApp.texteTitre,
                      ),
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement12),
                  Text(
                    utilisateur?.nomComplet ?? 'Invité',
                    style: const TextStyle(
                      fontSize: TaillesApp.texteGrand,
                      fontWeight: FontWeight.w700,
                      color: CouleursApp.textePrincipal,
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement4),
                  Text(
                    utilisateur?.numeroTelephone ?? '',
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                  if (utilisateur?.email != null &&
                      utilisateur!.email!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      utilisateur.email!,
                      style: const TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteDesactive,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: TaillesApp.espacement32),

            // Stats personnelles
            const Padding(
              padding: EdgeInsets.only(left: TaillesApp.espacement4),
              child: Text(
                'MES STATISTIQUES',
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteSecondaire,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacement8),
            CarteStatRiche(
              icone: Icons.groups,
              libelle: 'Tontines actives',
              valeur: '$tontinesActives',
              couleur: CouleursApp.orangePrincipal,
            ),
            const SizedBox(height: TaillesApp.espacement8),
            CarteStatRiche(
              icone: Icons.upload,
              libelle: 'Total cotisé via Mobile Money',
              valeur: Formatteurs.formatterFCFA(totalCotise),
              couleur: CouleursApp.information,
            ),
            const SizedBox(height: TaillesApp.espacement8),
            CarteStatRiche(
              icone: Icons.download,
              libelle: 'Total reçu (cagnottes)',
              valeur: Formatteurs.formatterFCFA(totalRecu),
              couleur: CouleursApp.vertPrincipal,
            ),
            const SizedBox(height: TaillesApp.espacement24),

            // Section paramètres
            const Padding(
              padding: EdgeInsets.only(left: TaillesApp.espacement4),
              child: Text(
                'PARAMÈTRES',
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteSecondaire,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacement8),
            _LigneOption(
              icone: Icons.edit_outlined,
              titre: 'Modifier mon profil',
              onTap: () =>
                  Navigator.of(context).pushNamed(RoutesNoms.editionProfil),
            ),
            _LigneOption(
              icone: Icons.notifications_outlined,
              titre: 'Notifications',
              onTap: () =>
                  Navigator.of(context).pushNamed(RoutesNoms.notifications),
            ),
            _LigneOption(
              icone: Icons.security_outlined,
              titre: 'Sécurité',
              onTap: () => _afficherSnack(context, 'Bientôt disponible'),
            ),
            _LigneOption(
              icone: Icons.help_outline,
              titre: 'Aide et support',
              onTap: () => _afficherSnack(context, 'Bientôt disponible'),
            ),

            const SizedBox(height: TaillesApp.espacement24),

            // Section données
            const Padding(
              padding: EdgeInsets.only(left: TaillesApp.espacement4),
              child: Text(
                'DONNÉES',
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.texteSecondaire,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacement8),
            _LigneOption(
              icone: Icons.refresh,
              titre: 'Réinitialiser les données démo',
              couleurIcone: CouleursApp.avertissement,
              onTap: () => _reinitialiserDonneesDemo(context),
            ),

            const SizedBox(height: TaillesApp.espacement24),

            // Déconnexion
            OutlinedButton.icon(
              onPressed: () => _confirmerDeconnexion(context),
              icon: const Icon(Icons.logout, color: CouleursApp.erreur),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: CouleursApp.erreur),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, TaillesApp.hauteurBouton),
                side: const BorderSide(color: CouleursApp.erreur),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                ),
              ),
            ),
            const SizedBox(height: TaillesApp.espacement32),

            const Center(
              child: Text(
                'TontineApp v1.0.0 — Sprint 5',
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  color: CouleursApp.texteDesactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _afficherSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LigneOption extends StatelessWidget {
  final IconData icone;
  final String titre;
  final VoidCallback onTap;
  final Color couleurIcone;

  const _LigneOption({
    required this.icone,
    required this.titre,
    required this.onTap,
    this.couleurIcone = CouleursApp.orangePrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icone, color: couleurIcone),
      title: Text(
        titre,
        style: const TextStyle(
          fontSize: TaillesApp.textePetit,
          color: CouleursApp.textePrincipal,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: CouleursApp.texteDesactive,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
