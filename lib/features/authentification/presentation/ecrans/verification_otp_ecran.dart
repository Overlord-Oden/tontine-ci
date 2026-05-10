import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/chaines.dart';
import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../providers/auth_provider.dart';

/// Écran de saisie du code OTP à 6 chiffres.
///
/// En mode démo, le code valide est **123456** (affiché dans une note).
class VerificationOtpEcran extends StatefulWidget {
  const VerificationOtpEcran({super.key});

  @override
  State<VerificationOtpEcran> createState() => _VerificationOtpEcranState();
}

class _VerificationOtpEcranState extends State<VerificationOtpEcran> {
  final _controleurOtp = TextEditingController();
  Timer? _timer;
  int _secondesRestantes = 60;

  @override
  void initState() {
    super.initState();
    _demarrerTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controleurOtp.dispose();
    super.dispose();
  }

  void _demarrerTimer() {
    setState(() => _secondesRestantes = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondesRestantes <= 0) {
        t.cancel();
      } else {
        setState(() => _secondesRestantes--);
      }
    });
  }

  Future<void> _onValider(String code) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifierOtp(code);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacementNamed(RoutesNoms.creationProfil);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.messageErreur ?? ChainesApp.erreurOtpInvalide),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      _controleurOtp.clear();
    }
  }

  Future<void> _renvoyerCode() async {
    final auth = context.read<AuthProvider>();
    final numero = auth.numeroTelephoneEnCours;
    if (numero == null) return;

    final ok = await auth.demanderOtp(numero);
    if (!mounted) return;

    if (ok) {
      _demarrerTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouveau code envoyé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final numero = auth.numeroTelephoneEnCours ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(ChainesApp.otpTitre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TaillesApp.espacement24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TaillesApp.espacement24),

              // Sous-titre + numéro
              const Text(
                ChainesApp.otpSousTitre,
                style: TextStyle(
                  fontSize: TaillesApp.texteMoyen,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement4),
              Text(
                Formatteurs.masquerTelephone(numero),
                style: const TextStyle(
                  fontSize: TaillesApp.texteMoyen,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.textePrincipal,
                ),
              ),
              const SizedBox(height: TaillesApp.espacement32),

              // Champs PIN OTP
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _controleurOtp,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius:
                      BorderRadius.circular(TaillesApp.rayonMoyen),
                  fieldHeight: 56,
                  fieldWidth: 44,
                  activeColor: CouleursApp.orangePrincipal,
                  selectedColor: CouleursApp.orangePrincipal,
                  inactiveColor: CouleursApp.bordure,
                  activeFillColor: CouleursApp.blanc,
                  selectedFillColor: CouleursApp.blanc,
                  inactiveFillColor: CouleursApp.blanc,
                ),
                enableActiveFill: true,
                cursorColor: CouleursApp.orangePrincipal,
                textStyle: const TextStyle(
                  fontSize: TaillesApp.texteGrand,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (_) {},
                onCompleted: _onValider,
              ),

              const SizedBox(height: TaillesApp.espacement8),

              // Note démo
              Container(
                padding: const EdgeInsets.all(TaillesApp.espacement12),
                decoration: BoxDecoration(
                  color: CouleursApp.vertSurface,
                  borderRadius:
                      BorderRadius.circular(TaillesApp.rayonPetit),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: TaillesApp.iconeMoyenne,
                      color: CouleursApp.vertFonce,
                    ),
                    SizedBox(width: TaillesApp.espacement8),
                    Expanded(
                      child: Text(
                        ChainesApp.otpAideDemo,
                        style: TextStyle(
                          fontSize: TaillesApp.textePetit,
                          color: CouleursApp.vertFonce,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Renvoyer le code
              Center(
                child: _secondesRestantes > 0
                    ? Text(
                        'Renvoyer le code dans $_secondesRestantes s',
                        style: const TextStyle(
                          fontSize: TaillesApp.textePetit,
                          color: CouleursApp.texteSecondaire,
                        ),
                      )
                    : TextButton(
                        onPressed: _renvoyerCode,
                        child: const Text(ChainesApp.renvoyerCode),
                      ),
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Bouton Vérifier (en plus de la complétion auto)
              BoutonPrimaire(
                libelle: 'Vérifier',
                enChargement: auth.enChargement,
                onPressed: _controleurOtp.text.length == 6
                    ? () => _onValider(_controleurOtp.text)
                    : null,
              ),
              const SizedBox(height: TaillesApp.espacement16),
            ],
          ),
        ),
      ),
    );
  }
}
