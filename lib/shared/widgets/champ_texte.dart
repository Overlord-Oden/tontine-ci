import 'package:flutter/material.dart';

import '../../core/constantes/tailles.dart';

/// Champ texte standardisé de la TontineApp.
///
/// Encapsule un [TextFormField] avec le style cohérent et les
/// options usuelles (label, prefix, validateur, type de clavier).
class ChampTexte extends StatelessWidget {
  final TextEditingController controleur;
  final String libelle;
  final String? indication;
  final IconData? iconePrefixe;
  final TextInputType typeClavier;
  final String? Function(String?)? validateur;
  final bool autoCorrect;
  final bool obscureTexte;
  final int? longueurMax;
  final TextCapitalization capitalisation;

  const ChampTexte({
    super.key,
    required this.controleur,
    required this.libelle,
    this.indication,
    this.iconePrefixe,
    this.typeClavier = TextInputType.text,
    this.validateur,
    this.autoCorrect = true,
    this.obscureTexte = false,
    this.longueurMax,
    this.capitalisation = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controleur,
      keyboardType: typeClavier,
      autocorrect: autoCorrect,
      obscureText: obscureTexte,
      maxLength: longueurMax,
      textCapitalization: capitalisation,
      validator: validateur,
      style: const TextStyle(fontSize: TaillesApp.texteMoyen),
      decoration: InputDecoration(
        labelText: libelle,
        hintText: indication,
        prefixIcon: iconePrefixe != null ? Icon(iconePrefixe) : null,
        counterText: '',
      ),
    );
  }
}
