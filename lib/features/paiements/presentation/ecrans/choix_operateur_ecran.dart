import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/routes_noms.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../../domaine/entites/operateur_mm.dart';
import '../widgets/carte_operateur.dart';

/// Arguments passés à l'écran de paiement.
class ArgumentsPaiement {
  final String idCotisation;
  final String idTontine;
  final String idMembre;
  final String nomMembre;
  final num montant;

  const ArgumentsPaiement({
    required this.idCotisation,
    required this.idTontine,
    required this.idMembre,
    required this.nomMembre,
    required this.montant,
  });
}

/// Écran 1 du flux : choix de l'opérateur + saisie du numéro.
class ChoixOperateurEcran extends StatefulWidget {
  const ChoixOperateurEcran({super.key});

  @override
  State<ChoixOperateurEcran> createState() => _ChoixOperateurEcranState();
}

class _ChoixOperateurEcranState extends State<ChoixOperateurEcran> {
  OperateurMM? _operateurSelectionne;
  late TextEditingController _ctrlNumero;
  ArgumentsPaiement? _args;

  @override
  void initState() {
    super.initState();
    _ctrlNumero = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pré-remplit avec le numéro de l'utilisateur courant
      final auth = context.read<AuthProvider>();
      if (auth.utilisateur != null) {
        _ctrlNumero.text = auth.utilisateur!.numeroTelephone;
      }
    });
  }

  @override
  void dispose() {
    _ctrlNumero.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args ??= ModalRoute.of(context)?.settings.arguments as ArgumentsPaiement?;
  }

  void _continuer() {
    if (_operateurSelectionne == null || _args == null) return;
    if (_ctrlNumero.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro Mobile Money invalide'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      RoutesNoms.confirmationPaiement,
      arguments: ConfirmationArgs(
        argsPaiement: _args!,
        operateur: _operateurSelectionne!,
        numeroMM: _ctrlNumero.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_args == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Aucun paiement à effectuer')),
      );
    }

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      appBar: AppBar(
        title: const Text('Payer ma cotisation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(TaillesApp.espacement20),
                children: [
                  // Récapitulatif du montant
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TaillesApp.espacement20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          CouleursApp.orangePrincipal,
                          CouleursApp.orangeFonce,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(TaillesApp.rayonGrand),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Montant à payer',
                          style: TextStyle(
                            fontSize: TaillesApp.textePetit,
                            color: CouleursApp.blanc,
                          ),
                        ),
                        const SizedBox(height: TaillesApp.espacement4),
                        Text(
                          Formatteurs.formatterFCFA(_args!.montant),
                          style: const TextStyle(
                            fontSize: TaillesApp.texteTitre,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.blanc,
                          ),
                        ),
                        const SizedBox(height: TaillesApp.espacement4),
                        Text(
                          'Pour : ${_args!.nomMembre}',
                          style: const TextStyle(
                            fontSize: TaillesApp.textePetit,
                            color: CouleursApp.blanc,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement24),

                  // Sélection de l'opérateur
                  const Text(
                    'CHOISIR L\'OPÉRATEUR',
                    style: TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.texteSecondaire,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: TaillesApp.espacement12),
                  ...OperateurMM.values.map((op) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: TaillesApp.espacement12,
                        ),
                        child: CarteOperateur(
                          operateur: op,
                          selectionne: _operateurSelectionne == op,
                          onTap: () =>
                              setState(() => _operateurSelectionne = op),
                        ),
                      )),

                  const SizedBox(height: TaillesApp.espacement16),

                  // Numéro Mobile Money
                  if (_operateurSelectionne != null) ...[
                    Text(
                      'NUMÉRO ${_operateurSelectionne!.libelle.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.texteSecondaire,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement8),
                    TextFormField(
                      controller: _ctrlNumero,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_android,
                          color: _operateurSelectionne!.couleur,
                        ),
                        hintText: 'Ex : +2250707978218',
                      ),
                    ),
                    const SizedBox(height: TaillesApp.espacement8),
                    const Text(
                      'Le code OTP sera envoyé à ce numéro.',
                      style: TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TaillesApp.espacement20),
              child: BoutonPrimaire(
                libelle: 'Continuer',
                icone: Icons.arrow_forward,
                onPressed: _operateurSelectionne != null ? _continuer : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arguments passés à l'écran suivant (confirmation).
class ConfirmationArgs {
  final ArgumentsPaiement argsPaiement;
  final OperateurMM operateur;
  final String numeroMM;

  const ConfirmationArgs({
    required this.argsPaiement,
    required this.operateur,
    required this.numeroMM,
  });
}
