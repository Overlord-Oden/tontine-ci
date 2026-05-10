import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/cotisation.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/entites/tour.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../../paiements/presentation/ecrans/choix_operateur_ecran.dart';
import '../../../tontines/presentation/providers/tontine_provider.dart';
import '../providers/cotisation_provider.dart';
import '../widgets/cotisation_carte.dart';

/// Arguments passés à l'écran détail d'un tour.
class ArgumentsDetailTour {
  final String idTontine;
  final String idTour;

  const ArgumentsDetailTour({
    required this.idTontine,
    required this.idTour,
  });
}

/// Écran de détail d'un tour : liste des cotisations + actions.
class DetailTourEcran extends StatefulWidget {
  const DetailTourEcran({super.key});

  @override
  State<DetailTourEcran> createState() => _DetailTourEcranState();
}

class _DetailTourEcranState extends State<DetailTourEcran> {
  Tontine? _tontine;
  Tour? _tour;
  bool _enChargement = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  Future<void> _charger() async {
    final args = ModalRoute.of(context)?.settings.arguments
        as ArgumentsDetailTour?;
    if (args == null) {
      Navigator.of(context).pop();
      return;
    }

    final tontineProvider = context.read<TontineProvider>();
    final cotisationProvider = context.read<CotisationProvider>();

    final tontine = await tontineProvider.obtenirTontine(args.idTontine);
    if (tontine == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    Tour? tour;
    try {
      tour = tontine.tours.firstWhere((t) => t.id == args.idTour);
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    await cotisationProvider.chargerCotisationsTour(tour.id);
    if (!mounted) return;

    setState(() {
      _tontine = tontine;
      _tour = tour;
      _enChargement = false;
    });
  }

  Future<void> _onMarquerPayee(Cotisation c) async {
    // Ouvre le flux de paiement Mobile Money
    final auth = context.read<AuthProvider>();
    if (auth.utilisateur == null) return;

    // L'id du membre courant dans la tontine
    String? idMembreCourant;
    try {
      idMembreCourant = _tontine!.membres
          .firstWhere((m) => m.idUtilisateur == auth.utilisateur!.id)
          .id;
    } catch (_) {
      idMembreCourant = null;
    }
    if (idMembreCourant == null) return;

    final resultat = await Navigator.of(context).pushNamed(
      RoutesNoms.choixOperateur,
      arguments: ArgumentsPaiement(
        idCotisation: c.id,
        idTontine: _tontine!.id,
        idMembre: idMembreCourant,
        nomMembre: auth.utilisateur!.nomComplet,
        montant: c.montant,
      ),
    );

    if (!mounted) return;

    // Si on revient avec un succès, on rafraîchit les cotisations
    // (la cotisation a été auto-validée par le repo paiement)
    await context.read<CotisationProvider>().chargerCotisationsTour(_tour!.id);
    if (!mounted) return;

    // Et on vérifie la clôture du tour
    await _verifierCloture();
  }

  Future<void> _onValider(Cotisation c) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider cette cotisation ?'),
        content: Text(
          'Vous confirmez avoir reçu ${Formatteurs.formatterFCFA(c.montant)} '
          'de la part de ${c.nomMembre}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final ok =
        await context.read<CotisationProvider>().validerCotisation(c.id);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cotisation de ${c.nomMembre} validée ✅'),
          backgroundColor: CouleursApp.succes,
        ),
      );
      await _verifierCloture();
    } else {
      _afficherErreur();
    }
  }

  Future<void> _onAnnuler(Cotisation c) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser ce paiement ?'),
        content: Text(
          'La cotisation de ${c.nomMembre} sera remise en attente. '
          'Le membre devra la marquer à nouveau comme payée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: CouleursApp.erreur),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final ok =
        await context.read<CotisationProvider>().annulerPaiement(c.id);
    if (!mounted || !ok) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement remis en attente')),
    );
  }

  /// Si toutes les cotisations sont validées, affiche un message de clôture.
  Future<void> _verifierCloture() async {
    final complet =
        await context.read<CotisationProvider>().tourEstComplet();
    if (!mounted || !complet) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.celebration,
          size: 48,
          color: CouleursApp.vertPrincipal,
        ),
        title: const Text('Tour complet ! 🎉'),
        content: Text(
          'Toutes les cotisations du Tour ${_tour!.numero} sont validées.\n\n'
          '${_tour!.nomBeneficiaire} peut maintenant recevoir la cagnotte de '
          '${Formatteurs.formatterFCFA(_tour!.montantTotal)}.\n\n'
          'Le tour suivant démarrera automatiquement (Sprint 4).',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Super !'),
          ),
        ],
      ),
    );
  }

  void _afficherErreur() {
    final cp = context.read<CotisationProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cp.messageErreur ?? 'Une erreur est survenue'),
        backgroundColor: CouleursApp.erreur,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_enChargement) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_tontine == null || _tour == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Tour introuvable')),
      );
    }

    final tontine = _tontine!;
    final tour = _tour!;
    final auth = context.read<AuthProvider>();
    final idUtilisateurCourant = auth.utilisateur?.id;
    final estAdmin = idUtilisateurCourant != null &&
        tontine.estAdmin(idUtilisateurCourant);

    final cotisationProvider = context.watch<CotisationProvider>();
    final cotisations = cotisationProvider.cotisations;

    // L'id du membre courant dans cette tontine (peut différer de userId)
    String? idMembreCourant;
    try {
      idMembreCourant = tontine.membres
          .firstWhere((m) => m.idUtilisateur == idUtilisateurCourant)
          .id;
    } catch (_) {
      idMembreCourant = null;
    }

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      appBar: AppBar(
        title: Text('Tour ${tour.numero}'),
      ),
      body: cotisationProvider.enChargement && cotisations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(TaillesApp.espacement16),
              children: [
                _CarteResumeTour(
                  tour: tour,
                  tontine: tontine,
                  progression: cotisationProvider.progression,
                ),
                const SizedBox(height: TaillesApp.espacement24),

                // Bénéficiaire en évidence
                _SectionTitre(
                  titre: 'Bénéficiaire',
                  badge: '1',
                ),
                const SizedBox(height: TaillesApp.espacement8),
                ...cotisations
                    .where((c) => c.estBeneficiaire)
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: TaillesApp.espacement8,
                          ),
                          child: CotisationCarte(
                            cotisation: c,
                            estUtilisateurCourant: c.idMembre == idMembreCourant,
                          ),
                        )),
                const SizedBox(height: TaillesApp.espacement16),

                // Cotisations à payer (en attente)
                if (cotisationProvider.aPayer.isNotEmpty) ...[
                  _SectionTitre(
                    titre: 'À cotiser',
                    badge: '${cotisationProvider.aPayer.length}',
                    couleur: CouleursApp.avertissement,
                  ),
                  const SizedBox(height: TaillesApp.espacement8),
                  ...cotisationProvider.aPayer.map((c) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: TaillesApp.espacement8,
                        ),
                        child: CotisationCarte(
                          cotisation: c,
                          estUtilisateurCourant:
                              c.idMembre == idMembreCourant,
                          peutValider: estAdmin,
                          onMarquerPayee: c.idMembre == idMembreCourant
                              ? () => _onMarquerPayee(c)
                              : null,
                          onValider:
                              estAdmin ? () => _onValider(c) : null,
                        ),
                      )),
                  const SizedBox(height: TaillesApp.espacement16),
                ],

                // Cotisations en attente de validation admin
                if (cotisationProvider.enAttenteValidation.isNotEmpty) ...[
                  _SectionTitre(
                    titre: 'À valider par l\'admin',
                    badge: '${cotisationProvider.enAttenteValidation.length}',
                    couleur: CouleursApp.information,
                  ),
                  const SizedBox(height: TaillesApp.espacement8),
                  ...cotisationProvider.enAttenteValidation
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: TaillesApp.espacement8,
                            ),
                            child: CotisationCarte(
                              cotisation: c,
                              estUtilisateurCourant:
                                  c.idMembre == idMembreCourant,
                              peutValider: estAdmin,
                              onValider:
                                  estAdmin ? () => _onValider(c) : null,
                              onAnnuler:
                                  estAdmin ? () => _onAnnuler(c) : null,
                            ),
                          )),
                  const SizedBox(height: TaillesApp.espacement16),
                ],

                // Cotisations validées
                if (cotisationProvider.validees.isNotEmpty) ...[
                  _SectionTitre(
                    titre: 'Cotisations reçues',
                    badge: '${cotisationProvider.validees.length}',
                    couleur: CouleursApp.vertPrincipal,
                  ),
                  const SizedBox(height: TaillesApp.espacement8),
                  ...cotisationProvider.validees.map((c) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: TaillesApp.espacement8,
                        ),
                        child: CotisationCarte(
                          cotisation: c,
                          estUtilisateurCourant:
                              c.idMembre == idMembreCourant,
                        ),
                      )),
                ],

                const SizedBox(height: TaillesApp.espacement32),
              ],
            ),
    );
  }
}

class _SectionTitre extends StatelessWidget {
  final String titre;
  final String badge;
  final Color couleur;

  const _SectionTitre({
    required this.titre,
    required this.badge,
    this.couleur = CouleursApp.texteSecondaire,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          titre.toUpperCase(),
          style: const TextStyle(
            fontSize: TaillesApp.texteMicro,
            fontWeight: FontWeight.w600,
            color: CouleursApp.texteSecondaire,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: TaillesApp.espacement8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: couleur.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: TaillesApp.texteMicro,
              fontWeight: FontWeight.w700,
              color: couleur,
            ),
          ),
        ),
      ],
    );
  }
}

class _CarteResumeTour extends StatelessWidget {
  final Tour tour;
  final Tontine tontine;
  final double progression;

  const _CarteResumeTour({
    required this.tour,
    required this.tontine,
    required this.progression,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tontine.nom,
                      style: const TextStyle(
                        fontSize: TaillesApp.textePetit,
                        color: CouleursApp.blanc,
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement4),
                    Text(
                      'Tour ${tour.numero} — ${tour.statut.libelle}',
                      style: const TextStyle(
                        fontSize: TaillesApp.texteGrand,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.blanc,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TaillesApp.espacement8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(TaillesApp.rayonPetit),
                ),
                child: Text(
                  Formatteurs.formatterDateCourte(tour.dateEcheance),
                  style: const TextStyle(
                    color: CouleursApp.blanc,
                    fontSize: TaillesApp.texteMicro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TaillesApp.espacement20),

          // Bénéficiaire
          Container(
            padding: const EdgeInsets.all(TaillesApp.espacement12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: CouleursApp.blanc,
                  size: TaillesApp.iconeMoyenne,
                ),
                const SizedBox(width: TaillesApp.espacement8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bénéficiaire',
                        style: TextStyle(
                          fontSize: TaillesApp.texteMicro,
                          color: CouleursApp.blanc,
                        ),
                      ),
                      Text(
                        tour.nomBeneficiaire,
                        style: const TextStyle(
                          fontSize: TaillesApp.textePetit,
                          fontWeight: FontWeight.w700,
                          color: CouleursApp.blanc,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatteurs.formatterFCFA(tour.montantTotal),
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMoyen,
                    fontWeight: FontWeight.w700,
                    color: CouleursApp.blanc,
                  ),
                ),
              ],
            ),
          ),

          // Barre de progression si en cours
          if (tour.statut == StatutTour.enCours) ...[
            const SizedBox(height: TaillesApp.espacement16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression du tour',
                  style: TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.blanc,
                  ),
                ),
                Text(
                  '${(progression * 100).round()}%',
                  style: const TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    fontWeight: FontWeight.w700,
                    color: CouleursApp.blanc,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TaillesApp.espacement8),
            ClipRRect(
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
              child: LinearProgressIndicator(
                value: progression,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CouleursApp.blanc,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
