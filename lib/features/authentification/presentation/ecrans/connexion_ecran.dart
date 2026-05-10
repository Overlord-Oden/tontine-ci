import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../providers/auth_provider.dart';

/// Écran de connexion d'un utilisateur existant.
///
/// Saisie du numéro → envoi OTP → vérification → accueil.
class ConnexionEcran extends StatefulWidget {
  const ConnexionEcran({super.key});

  @override
  State<ConnexionEcran> createState() => _ConnexionEcranState();
}

class _ConnexionEcranState extends State<ConnexionEcran> {
  String _numeroComplet = '';
  bool _numeroValide = false;

  Future<void> _onSeConnecter() async {
    if (!_numeroValide) return;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TaillesApp.espacement24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TaillesApp.espacement48),

              // Logo en haut
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: CouleursApp.orangeSurface,
                    borderRadius:
                        BorderRadius.circular(TaillesApp.rayonGrand),
                  ),
                  child: const Center(
                    child: Text(
                      'TA',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.orangePrincipal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TaillesApp.espacement32),

              // Titre
              const Text(
                ChainesApp.connexionTitre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TaillesApp.texteTitre,
                  fontWeight: FontWeight.w700,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement8),

              // Sous-titre
              const Text(
                ChainesApp.connexionSousTitre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TaillesApp.textePetit,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement32),

              // Champ téléphone
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

              const Spacer(),

              BoutonPrimaire(
                libelle: ChainesApp.seConnecter,
                enChargement: auth.enChargement,
                onPressed: _numeroValide ? _onSeConnecter : null,
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Lien vers inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    ChainesApp.pasDeCompte,
                    style: TextStyle(
                      fontSize: TaillesApp.textePetit,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(RoutesNoms.inscription);
                    },
                    child: const Text(ChainesApp.creerCompte),
                  ),
                ],
              ),
              const SizedBox(height: TaillesApp.espacement16),
            ],
          ),
        ),
      ),
    );
  }
}
