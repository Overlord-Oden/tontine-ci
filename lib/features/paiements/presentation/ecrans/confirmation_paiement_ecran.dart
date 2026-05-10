import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../../domaine/entites/operateur_mm.dart';
import '../../domaine/entites/paiement.dart';
import '../providers/paiement_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import 'choix_operateur_ecran.dart';

/// Écran 2 du flux : initiation du paiement + saisie OTP.
///
/// L'habillage (couleur de fond, en-tête) reflète l'opérateur choisi.
class ConfirmationPaiementEcran extends StatefulWidget {
  const ConfirmationPaiementEcran({super.key});

  @override
  State<ConfirmationPaiementEcran> createState() =>
      _ConfirmationPaiementEcranState();
}

class _ConfirmationPaiementEcranState
    extends State<ConfirmationPaiementEcran> {
  ConfirmationArgs? _args;
  bool _initiationEnCours = false;
  bool _initiationFaite = false;
  final _ctrlOtp = TextEditingController();
  Timer? _timer;
  int _secondesRestantes = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)?.settings.arguments as ConfirmationArgs?;
    if (_args != null && !_initiationFaite && !_initiationEnCours) {
      _initierPaiement();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrlOtp.dispose();
    super.dispose();
  }

  Future<void> _initierPaiement() async {
    if (_args == null) return;
    setState(() => _initiationEnCours = true);

    final paiementProvider = context.read<PaiementProvider>();
    paiementProvider.reinitialiser();

    final ok = await paiementProvider.initierPaiement(
      idCotisation: _args!.argsPaiement.idCotisation,
      idTontine: _args!.argsPaiement.idTontine,
      idMembre: _args!.argsPaiement.idMembre,
      nomMembre: _args!.argsPaiement.nomMembre,
      operateur: _args!.operateur,
      numeroTelephoneMM: _args!.numeroMM,
      montant: _args!.argsPaiement.montant,
    );

    if (!mounted) return;

    setState(() {
      _initiationEnCours = false;
      _initiationFaite = ok;
    });

    if (ok) {
      _demarrerTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paiementProvider.messageErreur ?? 'Erreur'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  void _demarrerTimer() {
    final paiement = context.read<PaiementProvider>().paiementCourant;
    setState(() => _secondesRestantes = 90);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondesRestantes <= 0) {
        t.cancel();
      } else {
        setState(() => _secondesRestantes--);
      }
    });
    // Si on connaît la durée vraie via le provider
    if (paiement != null) {
      // _secondesRestantes initialement à 90, déjà OK
    }
  }

  Future<void> _confirmer(String code) async {
    final paiementProvider = context.read<PaiementProvider>();
    final ok = await paiementProvider.confirmerOtp(code);

    if (!mounted) return;

    if (ok) {
      // Succès → écran de reçu
      _timer?.cancel();
      // Crée une notification (best-effort, ne bloque pas la nav)
      // ignore: unawaited_futures
      _creerNotificationPaiement();
      Navigator.of(context).pushReplacementNamed(RoutesNoms.recuPaiement);
    } else {
      // Échec OTP → on efface et on affiche l'erreur
      _ctrlOtp.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paiementProvider.messageErreur ?? 'Code OTP incorrect',
          ),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  Future<void> _creerNotificationPaiement() async {
    final paiement = context.read<PaiementProvider>().paiementCourant;
    if (paiement == null) return;
    await context.read<NotificationProvider>().notifierPaiementReussi(
          operateur: paiement.operateur.libelle,
          montant: paiement.montant,
          nomTontine: 'votre tontine',
        );
  }

  Future<void> _annuler() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text(
          'Le paiement en cours sera annulé. Vous pourrez le relancer plus tard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer le paiement'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: CouleursApp.erreur),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (confirme != true || !mounted) return;

    await context.read<PaiementProvider>().annulerPaiementCourant();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Aucune info de paiement')),
      );
    }

    final operateur = _args!.operateur;
    final paiementProvider = context.watch<PaiementProvider>();
    final paiement = paiementProvider.paiementCourant;

    return Scaffold(
      backgroundColor: operateur.couleur,
      appBar: AppBar(
        backgroundColor: operateur.couleur,
        foregroundColor: operateur.couleurTexte,
        title: Text(operateur.libelle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _annuler,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // En-tête opérateur
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TaillesApp.espacement24,
                vertical: TaillesApp.espacement16,
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: operateur.couleurTexte.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(TaillesApp.rayonGrand),
                    ),
                    child: Center(
                      child: Text(
                        operateur.codeCourt,
                        style: TextStyle(
                          color: operateur.couleurTexte,
                          fontSize: operateur.codeCourt.length > 3 ? 18 : 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement12),
                  Text(
                    operateur.libelle,
                    style: TextStyle(
                      fontSize: TaillesApp.texteGrand,
                      fontWeight: FontWeight.w800,
                      color: operateur.couleurTexte,
                    ),
                  ),
                  Text(
                    operateur.baseline,
                    style: TextStyle(
                      fontSize: TaillesApp.textePetit,
                      color: operateur.couleurTexte.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Carte blanche avec OTP
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: CouleursApp.blanc,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(TaillesApp.rayonTresGrand),
                  ),
                ),
                child: _initiationEnCours
                    ? _Chargement(operateur: operateur)
                    : _ContenuOtp(
                        paiement: paiement,
                        operateur: operateur,
                        controleurOtp: _ctrlOtp,
                        secondesRestantes: _secondesRestantes,
                        enChargement: paiementProvider.enChargement,
                        onComplete: _confirmer,
                        onConfirmer: () =>
                            _ctrlOtp.text.length == 4 ? _confirmer(_ctrlOtp.text) : null,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phase d'initiation : "Connexion à <opérateur>..."
class _Chargement extends StatelessWidget {
  final OperateurMM operateur;
  const _Chargement({required this.operateur});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: operateur.couleur,
            strokeWidth: 3,
          ),
          const SizedBox(height: TaillesApp.espacement16),
          Text(
            'Connexion à ${operateur.libelle}...',
            style: const TextStyle(
              fontSize: TaillesApp.textePetit,
              color: CouleursApp.texteSecondaire,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenu de l'écran OTP une fois le paiement initié.
class _ContenuOtp extends StatelessWidget {
  final Paiement? paiement;
  final OperateurMM operateur;
  final TextEditingController controleurOtp;
  final int secondesRestantes;
  final bool enChargement;
  final void Function(String) onComplete;
  final VoidCallback? onConfirmer;

  const _ContenuOtp({
    required this.paiement,
    required this.operateur,
    required this.controleurOtp,
    required this.secondesRestantes,
    required this.enChargement,
    required this.onComplete,
    required this.onConfirmer,
  });

  @override
  Widget build(BuildContext context) {
    final p = paiement;
    if (p == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TaillesApp.espacement24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: TaillesApp.espacement16),

          // Récap des infos
          Container(
            padding: const EdgeInsets.all(TaillesApp.espacement16),
            decoration: BoxDecoration(
              color: CouleursApp.fondSecondaire,
              borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
            ),
            child: Column(
              children: [
                _ligne('Montant', Formatteurs.formatterFCFA(p.montant)),
                const SizedBox(height: 6),
                _ligne(
                  'Frais',
                  Formatteurs.formatterFCFA(p.frais),
                  petit: true,
                ),
                const Divider(height: 16),
                _ligne(
                  'Total',
                  Formatteurs.formatterFCFA(p.montantTotal),
                  gras: true,
                ),
                const SizedBox(height: 6),
                _ligne(
                  'Numéro',
                  p.numeroTelephoneMM,
                  petit: true,
                ),
                const SizedBox(height: 6),
                _ligne(
                  'Référence',
                  p.referenceOperateur ?? '—',
                  petit: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: TaillesApp.espacement32),

          // Titre OTP
          Text(
            'Saisissez votre code ${operateur.libelle}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: TaillesApp.texteMoyen,
              fontWeight: FontWeight.w700,
              color: CouleursApp.textePrincipal,
            ),
          ),
          const SizedBox(height: TaillesApp.espacement4),
          Text(
            'Un code à 4 chiffres a été envoyé au\n${p.numeroTelephoneMM}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: TaillesApp.textePetit,
              color: CouleursApp.texteSecondaire,
            ),
          ),
          const SizedBox(height: TaillesApp.espacement24),

          // Champs PIN OTP (4 chiffres pour Mobile Money)
          PinCodeTextField(
            appContext: context,
            length: 4,
            controller: controleurOtp,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius:
                  BorderRadius.circular(TaillesApp.rayonMoyen),
              fieldHeight: 64,
              fieldWidth: 56,
              activeColor: operateur.couleur,
              selectedColor: operateur.couleur,
              inactiveColor: CouleursApp.bordure,
              activeFillColor: CouleursApp.blanc,
              selectedFillColor: CouleursApp.blanc,
              inactiveFillColor: CouleursApp.blanc,
            ),
            enableActiveFill: true,
            cursorColor: operateur.couleur,
            textStyle: const TextStyle(
              fontSize: TaillesApp.texteTitre,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (_) {},
            onCompleted: onComplete,
          ),
          const SizedBox(height: TaillesApp.espacement8),

          // Note démo
          Container(
            padding: const EdgeInsets.all(TaillesApp.espacement8),
            decoration: BoxDecoration(
              color: CouleursApp.vertSurface,
              borderRadius: BorderRadius.circular(TaillesApp.rayonPetit),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: TaillesApp.iconePetite,
                  color: CouleursApp.vertFonce,
                ),
                SizedBox(width: TaillesApp.espacement4),
                Text(
                  'Mode démo : utilisez 1234',
                  style: TextStyle(
                    fontSize: TaillesApp.textePetit,
                    color: CouleursApp.vertFonce,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TaillesApp.espacement24),

          // Timer
          if (secondesRestantes > 0)
            Center(
              child: Text(
                'Code expiré dans ${secondesRestantes}s',
                style: const TextStyle(
                  fontSize: TaillesApp.textePetit,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
            ),

          const SizedBox(height: TaillesApp.espacement24),

          BoutonPrimaire(
            libelle: 'Confirmer le paiement',
            icone: Icons.lock_outline,
            enChargement: enChargement,
            onPressed: onConfirmer,
          ),
        ],
      ),
    );
  }

  Widget _ligne(String libelle, String valeur,
      {bool gras = false, bool petit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          libelle,
          style: TextStyle(
            fontSize:
                petit ? TaillesApp.texteMicro : TaillesApp.textePetit,
            color: CouleursApp.texteSecondaire,
          ),
        ),
        Text(
          valeur,
          style: TextStyle(
            fontSize:
                petit ? TaillesApp.textePetit : TaillesApp.texteMoyen,
            fontWeight: gras ? FontWeight.w700 : FontWeight.w500,
            color: CouleursApp.textePrincipal,
          ),
        ),
      ],
    );
  }
}
