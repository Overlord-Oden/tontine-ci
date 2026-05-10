import 'package:flutter/material.dart';

import '../../../tontines/presentation/ecrans/liste_tontines_ecran.dart';

/// Onglet **Mes groupes** : liste des tontines de l'utilisateur.
///
/// Délègue tout le contenu au [ListeTontinesEcran] du module tontines.
class MesGroupesEcran extends StatelessWidget {
  const MesGroupesEcran({super.key});

  @override
  Widget build(BuildContext context) => const ListeTontinesEcran();
}
