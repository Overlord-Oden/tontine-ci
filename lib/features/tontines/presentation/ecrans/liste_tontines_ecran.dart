import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../providers/tontine_provider.dart';
import '../widgets/tontine_carte.dart';

/// Écran listant toutes les tontines de l'utilisateur courant.
///
/// Remplace le placeholder de l'onglet "Mes groupes".
/// Permet de créer une nouvelle tontine via le bouton flottant.
class ListeTontinesEcran extends StatefulWidget {
  const ListeTontinesEcran({super.key});

  @override
  State<ListeTontinesEcran> createState() => _ListeTontinesEcranState();
}

class _ListeTontinesEcranState extends State<ListeTontinesEcran> {
  @override
  void initState() {
    super.initState();
    // Charge les tontines au premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final tontineProvider = context.read<TontineProvider>();
      if (auth.utilisateur != null && tontineProvider.tontines.isEmpty) {
        tontineProvider.chargerMesTontines(auth.utilisateur!.id);
      }
    });
  }

  Future<void> _rafraichir() async {
    final auth = context.read<AuthProvider>();
    if (auth.utilisateur == null) return;
    await context
        .read<TontineProvider>()
        .chargerMesTontines(auth.utilisateur!.id);
  }

  Future<void> _ouvrirCreation() async {
    final cree = await Navigator.of(context).pushNamed(RoutesNoms.creerTontine);
    if (cree == true) {
      // Une tontine vient d'être créée → on rafraîchit
      await _rafraichir();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tontineProvider = context.watch<TontineProvider>();

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _rafraichir,
          color: CouleursApp.orangePrincipal,
          child: tontineProvider.enChargement && tontineProvider.tontines.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : tontineProvider.tontines.isEmpty
                  ? _ListeVide(onCreer: _ouvrirCreation)
                  : ListView.separated(
                      padding: const EdgeInsets.all(TaillesApp.espacement20),
                      itemCount: tontineProvider.tontines.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: TaillesApp.espacement12),
                      itemBuilder: (_, i) {
                        final tontine = tontineProvider.tontines[i];
                        return TontineCarte(
                          tontine: tontine,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              RoutesNoms.detailTontine,
                              arguments: tontine.id,
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirCreation,
        backgroundColor: CouleursApp.orangePrincipal,
        foregroundColor: CouleursApp.blanc,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tontine'),
      ),
    );
  }
}

class _ListeVide extends StatelessWidget {
  final VoidCallback onCreer;
  const _ListeVide({required this.onCreer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // pour que le pull-to-refresh fonctionne même avec liste vide
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(TaillesApp.espacement32),
      children: [
        const SizedBox(height: TaillesApp.espacement64),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: CouleursApp.orangeSurface,
              borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 56,
              color: CouleursApp.orangePrincipal,
            ),
          ),
        ),
        const SizedBox(height: TaillesApp.espacement24),
        const Text(
          'Aucune tontine pour le moment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: TaillesApp.texteGrand,
            fontWeight: FontWeight.w600,
            color: CouleursApp.textePrincipal,
          ),
        ),
        const SizedBox(height: TaillesApp.espacement8),
        const Text(
          'Créez votre première tontine et invitez\n'
          'vos proches à la rejoindre.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: TaillesApp.textePetit,
            color: CouleursApp.texteSecondaire,
          ),
        ),
        const SizedBox(height: TaillesApp.espacement32),
        ElevatedButton.icon(
          onPressed: onCreer,
          icon: const Icon(Icons.add),
          label: const Text('Créer ma première tontine'),
        ),
      ],
    );
  }
}
