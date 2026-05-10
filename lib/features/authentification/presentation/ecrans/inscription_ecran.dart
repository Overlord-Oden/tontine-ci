import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../providers/auth_provider.dart';

/// Écran d'inscription : saisie du numéro de téléphone.
///
/// À la validation, demande l'envoi d'un OTP puis redirige vers
/// l'écran de vérification OTP.
class InscriptionEcran extends StatefulWidget {
  const InscriptionEcran({super.key});

  @override
  State<InscriptionEcran> createState() => _InscriptionEcranState();
}

class _InscriptionEcranState extends State<InscriptionEcran> {
  final _cleFormulaire = GlobalKey<FormState>();
  String _numeroComplet = '';
  bool _numeroValide = false;

  Future<void> _onContinuer() async {
    if (!_numeroValide) return;
    if (!_cleFormulaire.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.demanderOtp(_numeroComplet);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushNamed(RoutesNoms.verificationOtp);
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
        title: const Text(ChainesApp.inscriptionTitre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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

                // Sous-titre
                const Text(
                  ChainesApp.inscriptionSousTitre,
                  style: TextStyle(
                    fontSize: TaillesApp.texteMoyen,
                    color: CouleursApp.texteSecondaire,
                  ),
                ),
                const SizedBox(height: TaillesApp.espacement32),

                // Champ téléphone international (drapeau CI par défaut)
                IntlPhoneField(
                  initialCountryCode: 'CI',
                  decoration: const InputDecoration(
                    labelText: ChainesApp.champTelephone,
                    hintText: '07 07 97 82 18',
                  ),
                  languageCode: 'fr',
                  invalidNumberMessage: ChainesApp.erreurTelephoneInvalide,
                  onChanged: (phone) {
                    setState(() {
                      _numeroComplet = phone.completeNumber;
                      _numeroValide = phone.isValidNumber();
                    });
                  },
                ),
                const SizedBox(height: TaillesApp.espacement12),

                // Note d'information
                Container(
                  padding: const EdgeInsets.all(TaillesApp.espacement12),
                  decoration: BoxDecoration(
                    color: CouleursApp.orangeSurface,
                    borderRadius: BorderRadius.circular(
                      TaillesApp.rayonPetit,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: TaillesApp.iconeMoyenne,
                        color: CouleursApp.orangeFonce,
                      ),
                      SizedBox(width: TaillesApp.espacement8),
                      Expanded(
                        child: Text(
                          'Un code de vérification vous sera envoyé par SMS.',
                          style: TextStyle(
                            fontSize: TaillesApp.textePetit,
                            color: CouleursApp.orangeFonce,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bouton Continuer
                BoutonPrimaire(
                  libelle: ChainesApp.boutonContinuer,
                  enChargement: auth.enChargement,
                  onPressed: _numeroValide ? _onContinuer : null,
                ),
                const SizedBox(height: TaillesApp.espacement16),

                // Lien vers connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      ChainesApp.dejaCompte,
                      style: TextStyle(
                        fontSize: TaillesApp.textePetit,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(RoutesNoms.connexion);
                      },
                      child: const Text(ChainesApp.seConnecter),
                    ),
                  ],
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
