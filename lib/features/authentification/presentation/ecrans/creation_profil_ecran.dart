import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/validateurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../../../../shared/widgets/champ_texte.dart';
import '../providers/auth_provider.dart';

/// Écran final d'inscription : saisie du prénom, nom et email (optionnel).
class CreationProfilEcran extends StatefulWidget {
  const CreationProfilEcran({super.key});

  @override
  State<CreationProfilEcran> createState() => _CreationProfilEcranState();
}

class _CreationProfilEcranState extends State<CreationProfilEcran> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlPrenom = TextEditingController();
  final _ctrlNom = TextEditingController();
  final _ctrlEmail = TextEditingController();

  @override
  void dispose() {
    _ctrlPrenom.dispose();
    _ctrlNom.dispose();
    _ctrlEmail.dispose();
    super.dispose();
  }

  Future<void> _onTerminer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.creerProfil(
      prenom: _ctrlPrenom.text.trim(),
      nom: _ctrlNom.text.trim(),
      email: _ctrlEmail.text.trim().isEmpty ? null : _ctrlEmail.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ChainesApp.succesInscription),
          backgroundColor: CouleursApp.succes,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        RoutesNoms.accueilPrincipal,
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.messageErreur ?? ChainesApp.erreurInconnue),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(ChainesApp.profilTitre),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TaillesApp.espacement24),
          child: Form(
            key: _cleFormulaire,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: TaillesApp.espacement24),

                // Avatar circulaire
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: CouleursApp.orangeSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 56,
                      color: CouleursApp.orangePrincipal,
                    ),
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement24),

                // Sous-titre
                const Text(
                  ChainesApp.profilSousTitre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: TaillesApp.textePetit,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement32),

                // Prénom
                ChampTexte(
                  controleur: _ctrlPrenom,
                  libelle: ChainesApp.champPrenom,
                  iconePrefixe: Icons.person_outline,
                  capitalisation: TextCapitalization.words,
                  validateur: Validateurs.nom,
                ),
                const SizedBox(height: TaillesApp.espacement16),

                // Nom
                ChampTexte(
                  controleur: _ctrlNom,
                  libelle: ChainesApp.champNom,
                  iconePrefixe: Icons.badge_outlined,
                  capitalisation: TextCapitalization.words,
                  validateur: Validateurs.nom,
                ),
                const SizedBox(height: TaillesApp.espacement16),

                // Email (optionnel)
                ChampTexte(
                  controleur: _ctrlEmail,
                  libelle: ChainesApp.champEmail,
                  iconePrefixe: Icons.email_outlined,
                  typeClavier: TextInputType.emailAddress,
                  validateur: Validateurs.emailOptionnel,
                ),

                const Spacer(),

                BoutonPrimaire(
                  libelle: ChainesApp.boutonTerminer,
                  enChargement: auth.enChargement,
                  onPressed: _onTerminer,
                ),
                const SizedBox(height: TaillesApp.espacement16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
