import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../shared/widgets/motif_kente.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';

/// Écran de démarrage de l'application.
///
/// Affiche le logo et un motif kente, puis redirige automatiquement :
/// - vers [RoutesNoms.accueilPrincipal] si une session existe ;
/// - vers [RoutesNoms.connexion] sinon.
class SplashEcran extends StatefulWidget {
  const SplashEcran({super.key});

  @override
  State<SplashEcran> createState() => _SplashEcranState();
}

class _SplashEcranState extends State<SplashEcran> {
  @override
  void initState() {
    super.initState();
    _initialiser();
  }

  Future<void> _initialiser() async {
    // Délai minimum pour que le splash soit perceptible
    final delaiMinimum = Future<void>.delayed(const Duration(seconds: 2));

    final auth = context.read<AuthProvider>();
    await auth.chargerSessionExistante();
    await delaiMinimum;

    if (!mounted) return;

    if (auth.estConnecte) {
      Navigator.of(context).pushReplacementNamed(RoutesNoms.accueilPrincipal);
    } else {
      Navigator.of(context).pushReplacementNamed(RoutesNoms.connexion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.orangePrincipal,
      body: Stack(
        children: [
          // Motif décoratif en fond
          const Positioned.fill(child: MotifKente(opacite: 0.18)),

          // Contenu central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (cercle blanc avec initiales)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'TA',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.orangePrincipal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement32),

                // Nom de l'app
                const Text(
                  ChainesApp.nomApp,
                  style: TextStyle(
                    fontSize: TaillesApp.texteTitreTresGrand,
                    fontWeight: FontWeight.w700,
                    color: CouleursApp.blanc,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement8),

                // Slogan
                const Text(
                  ChainesApp.splashTagline,
                  style: TextStyle(
                    fontSize: TaillesApp.texteMoyen,
                    color: CouleursApp.blanc,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Indicateur de chargement en bas
          Positioned(
            bottom: TaillesApp.espacement48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: CouleursApp.blanc,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement12),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    fontSize: TaillesApp.textePetit,
                    color: CouleursApp.blanc.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
