import 'package:flutter/material.dart';

import '../../../../core/constantes/chaines.dart';
import 'mes_groupes_ecran.dart';
import 'paiements_ecran.dart';
import 'profil_ecran.dart';
import 'tableau_bord_ecran.dart';

/// Écran principal après authentification.
///
/// Hôte les 4 onglets de navigation : Accueil, Mes groupes, Paiements, Profil.
class AccueilPrincipalEcran extends StatefulWidget {
  const AccueilPrincipalEcran({super.key});

  @override
  State<AccueilPrincipalEcran> createState() => _AccueilPrincipalEcranState();
}

class _AccueilPrincipalEcranState extends State<AccueilPrincipalEcran> {
  int _ongletSelectionne = 0;

  static const List<Widget> _ecrans = <Widget>[
    TableauBordEcran(),
    MesGroupesEcran(),
    PaiementsEcran(),
    ProfilEcran(),
  ];

  static const List<String> _titres = <String>[
    ChainesApp.navAccueil,
    ChainesApp.navMesGroupes,
    ChainesApp.navPaiements,
    ChainesApp.navProfil,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titres[_ongletSelectionne]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _ongletSelectionne,
        children: _ecrans,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _ongletSelectionne,
        onDestinationSelected: (i) =>
            setState(() => _ongletSelectionne = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: ChainesApp.navAccueil,
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: ChainesApp.navMesGroupes,
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: ChainesApp.navPaiements,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: ChainesApp.navProfil,
          ),
        ],
      ),
    );
  }
}
