import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/membre.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/entites/tour.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../../cotisations/presentation/ecrans/detail_tour_ecran.dart';
import '../providers/tontine_provider.dart';
import '../widgets/membre_ligne.dart';
import '../widgets/tour_carte.dart';

/// Écran de détail d'une tontine, avec 3 onglets :
/// 1. **Membres** — Liste avec rôles et statuts
/// 2. **Calendrier** — Tours à venir et en cours
/// 3. **Historique** — Tours déjà terminés
///
/// L'argument route est l'`id` de la tontine.
class DetailTontineEcran extends StatefulWidget {
  const DetailTontineEcran({super.key});

  @override
  State<DetailTontineEcran> createState() => _DetailTontineEcranState();
}

class _DetailTontineEcranState extends State<DetailTontineEcran>
    with SingleTickerProviderStateMixin {
  late TabController _controleurOnglets;
  Tontine? _tontine;
  bool _enChargement = true;

  @override
  void initState() {
    super.initState();
    _controleurOnglets = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _charger());
  }

  @override
  void dispose() {
    _controleurOnglets.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) {
      Navigator.of(context).pop();
      return;
    }
    final t = await context.read<TontineProvider>().obtenirTontine(id);
    if (!mounted) return;
    setState(() {
      _tontine = t;
      _enChargement = false;
    });
  }

  Future<void> _inviterMembre() async {
    final resultat = await showDialog<_InvitationResultat>(
      context: context,
      builder: (_) => const _DialogInvitation(),
    );

    if (resultat == null || !mounted) return;

    final membre = await context.read<TontineProvider>().inviterMembre(
          idTontine: _tontine!.id,
          numeroTelephone: resultat.numero,
          nomAffichage: resultat.nom,
        );

    if (!mounted) return;

    if (membre != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${resultat.nom} a été invité(e)'),
          backgroundColor: CouleursApp.succes,
        ),
      );
      await _charger();
    }
  }

  Future<void> _retirerMembre(Membre membre) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer ce membre ?'),
        content: Text(
          '${membre.nomAffichage} sera retiré(e) de la tontine. '
          'Vous pouvez le faire car la tontine n\'est pas encore active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: CouleursApp.erreur),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final ok = await context.read<TontineProvider>().retirerMembre(
          idTontine: _tontine!.id,
          idMembre: membre.id,
        );
    if (!mounted) return;

    if (ok) {
      await _charger();
    }
  }

  Future<void> _activerTontine() async {
    if (_tontine!.membres.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Il faut au moins 2 membres pour activer une tontine',
          ),
          backgroundColor: CouleursApp.avertissement,
        ),
      );
      return;
    }

    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activer la tontine ?'),
        content: Text(
          'Une fois activée, vous ne pourrez plus ajouter ni retirer de membres. '
          'Le calendrier des tours sera généré automatiquement.\n\n'
          'Membres : ${_tontine!.membres.length}\n'
          'Cagnotte par tour : ${Formatteurs.formatterFCFA(_tontine!.cagnotteParTour)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Activer'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    final tontine =
        await context.read<TontineProvider>().activerTontine(_tontine!.id);
    if (!mounted) return;

    if (tontine != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tontine activée ! 🎉'),
          backgroundColor: CouleursApp.succes,
        ),
      );
      await _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_enChargement) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_tontine == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Tontine introuvable')),
      );
    }

    final t = _tontine!;
    final auth = context.read<AuthProvider>();
    final estAdmin =
        auth.utilisateur != null && t.estAdmin(auth.utilisateur!.id);

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      appBar: AppBar(
        title: Text(t.nom),
        bottom: TabBar(
          controller: _controleurOnglets,
          labelColor: CouleursApp.orangePrincipal,
          unselectedLabelColor: CouleursApp.texteSecondaire,
          indicatorColor: CouleursApp.orangePrincipal,
          labelStyle: const TextStyle(
            fontSize: TaillesApp.textePetit,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Membres'),
            Tab(text: 'Calendrier'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: Column(
        children: [
          // En-tête résumé
          _ResumeTontine(tontine: t),

          // Onglets
          Expanded(
            child: TabBarView(
              controller: _controleurOnglets,
              children: [
                _OngletMembres(
                  tontine: t,
                  estAdmin: estAdmin,
                  idUtilisateurCourant: auth.utilisateur?.id,
                  onRetirer: _retirerMembre,
                ),
                _OngletCalendrier(tontine: t),
                _OngletHistorique(tontine: t),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: t.statut == StatutTontine.brouillon && estAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'inviter',
                  onPressed: _inviterMembre,
                  backgroundColor: CouleursApp.orangePrincipal,
                  foregroundColor: CouleursApp.blanc,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Inviter'),
                ),
                if (t.membres.length >= 2) ...[
                  const SizedBox(height: TaillesApp.espacement8),
                  FloatingActionButton.extended(
                    heroTag: 'activer',
                    onPressed: _activerTontine,
                    backgroundColor: CouleursApp.vertPrincipal,
                    foregroundColor: CouleursApp.blanc,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Activer'),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}

// ─── En-tête résumé ─────────────────────────────────────────────────

class _ResumeTontine extends StatelessWidget {
  final Tontine tontine;
  const _ResumeTontine({required this.tontine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TaillesApp.espacement20),
      color: CouleursApp.blanc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tontine.description != null && tontine.description!.isNotEmpty) ...[
            Text(
              tontine.description!,
              style: const TextStyle(
                fontSize: TaillesApp.textePetit,
                color: CouleursApp.texteSecondaire,
              ),
            ),
            const SizedBox(height: TaillesApp.espacement16),
          ],
          Row(
            children: [
              Expanded(
                child: _BlocResume(
                  libelle: 'Cotisation',
                  valeur: Formatteurs.formatterFCFA(tontine.montantCotisation),
                  icone: Icons.payments_outlined,
                ),
              ),
              Expanded(
                child: _BlocResume(
                  libelle: 'Cagnotte',
                  valeur: Formatteurs.formatterFCFA(tontine.cagnotteParTour),
                  icone: Icons.savings_outlined,
                  couleur: CouleursApp.vertPrincipal,
                ),
              ),
              Expanded(
                child: _BlocResume(
                  libelle: 'Fréquence',
                  valeur: tontine.frequence.libelle,
                  icone: Icons.event_repeat_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlocResume extends StatelessWidget {
  final String libelle;
  final String valeur;
  final IconData icone;
  final Color couleur;

  const _BlocResume({
    required this.libelle,
    required this.valeur,
    required this.icone,
    this.couleur = CouleursApp.orangePrincipal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: couleur, size: TaillesApp.iconeMoyenne),
        const SizedBox(height: TaillesApp.espacement4),
        Text(
          valeur,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: TaillesApp.textePetit,
            fontWeight: FontWeight.w700,
            color: CouleursApp.textePrincipal,
          ),
        ),
        Text(
          libelle,
          style: const TextStyle(
            fontSize: TaillesApp.texteMicro,
            color: CouleursApp.texteSecondaire,
          ),
        ),
      ],
    );
  }
}

// ─── Onglet Membres ────────────────────────────────────────────────

class _OngletMembres extends StatelessWidget {
  final Tontine tontine;
  final bool estAdmin;
  final String? idUtilisateurCourant;
  final void Function(Membre) onRetirer;

  const _OngletMembres({
    required this.tontine,
    required this.estAdmin,
    required this.idUtilisateurCourant,
    required this.onRetirer,
  });

  @override
  Widget build(BuildContext context) {
    final peutRetirer = estAdmin && tontine.statut == StatutTontine.brouillon;
    final membres = [...tontine.membres]
      ..sort((a, b) => a.ordrePassage.compareTo(b.ordrePassage));

    return ListView.builder(
      padding: const EdgeInsets.only(top: TaillesApp.espacement8, bottom: 80),
      itemCount: membres.length,
      itemBuilder: (_, i) {
        final m = membres[i];
        return MembreLigne(
          membre: m,
          estUtilisateurCourant: m.idUtilisateur == idUtilisateurCourant,
          onRetirer: peutRetirer && m.role != RoleMembre.admin
              ? () => onRetirer(m)
              : null,
        );
      },
    );
  }
}

// ─── Onglet Calendrier ─────────────────────────────────────────────

class _OngletCalendrier extends StatelessWidget {
  final Tontine tontine;
  const _OngletCalendrier({required this.tontine});

  @override
  Widget build(BuildContext context) {
    if (tontine.statut == StatutTontine.brouillon) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(TaillesApp.espacement32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_outlined,
                  size: 56, color: CouleursApp.texteDesactive),
              SizedBox(height: TaillesApp.espacement16),
              Text(
                'Calendrier non disponible',
                style: TextStyle(
                  fontSize: TaillesApp.texteMoyen,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              SizedBox(height: TaillesApp.espacement4),
              Text(
                'Le calendrier sera généré quand la tontine sera activée.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TaillesApp.textePetit,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final aVenirEtEnCours = tontine.tours
        .where((t) => t.statut != StatutTour.termine)
        .toList()
      ..sort((a, b) => a.dateEcheance.compareTo(b.dateEcheance));

    if (aVenirEtEnCours.isEmpty) {
      return const Center(
        child: Text(
          'Tous les tours sont terminés',
          style: TextStyle(color: CouleursApp.texteSecondaire),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      itemCount: aVenirEtEnCours.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: TaillesApp.espacement8),
      itemBuilder: (_, i) {
        final tour = aVenirEtEnCours[i];
        return TourCarte(
          tour: tour,
          // Cliquable seulement pour les tours en cours ou à venir proche
          onTap: tour.statut == StatutTour.enCours
              ? () => Navigator.of(context).pushNamed(
                    RoutesNoms.detailTour,
                    arguments: ArgumentsDetailTour(
                      idTontine: tontine.id,
                      idTour: tour.id,
                    ),
                  )
              : null,
        );
      },
    );
  }
}

// ─── Onglet Historique ─────────────────────────────────────────────

class _OngletHistorique extends StatelessWidget {
  final Tontine tontine;
  const _OngletHistorique({required this.tontine});

  @override
  Widget build(BuildContext context) {
    final termines = tontine.toursTermines
      ..sort((a, b) => b.dateEcheance.compareTo(a.dateEcheance));

    if (termines.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(TaillesApp.espacement32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history,
                  size: 56, color: CouleursApp.texteDesactive),
              SizedBox(height: TaillesApp.espacement16),
              Text(
                'Aucun tour terminé',
                style: TextStyle(
                  fontSize: TaillesApp.texteMoyen,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              SizedBox(height: TaillesApp.espacement4),
              Text(
                'Les tours apparaîtront ici une fois clôturés.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TaillesApp.textePetit,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(TaillesApp.espacement16),
      itemCount: termines.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: TaillesApp.espacement8),
      itemBuilder: (_, i) {
        final tour = termines[i];
        return TourCarte(
          tour: tour,
          onTap: () => Navigator.of(context).pushNamed(
            RoutesNoms.detailTour,
            arguments: ArgumentsDetailTour(
              idTontine: tontine.id,
              idTour: tour.id,
            ),
          ),
        );
      },
    );
  }
}

// ─── Dialog d'invitation ────────────────────────────────────────────

class _InvitationResultat {
  final String nom;
  final String numero;
  const _InvitationResultat({required this.nom, required this.numero});
}

class _DialogInvitation extends StatefulWidget {
  const _DialogInvitation();

  @override
  State<_DialogInvitation> createState() => _DialogInvitationState();
}

class _DialogInvitationState extends State<_DialogInvitation> {
  final _ctrlNom = TextEditingController();
  final _ctrlNumero = TextEditingController(text: '+225');
  final _cleFormulaire = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrlNom.dispose();
    _ctrlNumero.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_cleFormulaire.currentState!.validate()) return;
    Navigator.of(context).pop(_InvitationResultat(
      nom: _ctrlNom.text.trim(),
      numero: _ctrlNumero.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inviter un membre'),
      content: Form(
        key: _cleFormulaire,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _ctrlNom,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                hintText: 'Ex : Awa Kouassi',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 2) ? 'Nom invalide' : null,
            ),
            const SizedBox(height: TaillesApp.espacement16),
            TextFormField(
              controller: _ctrlNumero,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: '+2250707978218',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Numéro requis';
                final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length < 10) return 'Numéro trop court';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _valider,
          child: const Text('Inviter'),
        ),
      ],
    );
  }
}
