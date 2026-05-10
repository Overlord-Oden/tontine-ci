import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/utils/validateurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../../../../shared/widgets/champ_texte.dart';
import '../providers/auth_provider.dart';

/// Écran d'édition du profil de l'utilisateur courant.
class EditionProfilEcran extends StatefulWidget {
  const EditionProfilEcran({super.key});

  @override
  State<EditionProfilEcran> createState() => _EditionProfilEcranState();
}

class _EditionProfilEcranState extends State<EditionProfilEcran> {
  final _cleFormulaire = GlobalKey<FormState>();
  late final TextEditingController _ctrlPrenom;
  late final TextEditingController _ctrlNom;
  late final TextEditingController _ctrlEmail;
  bool _enChargement = false;

  @override
  void initState() {
    super.initState();
    final utilisateur = context.read<AuthProvider>().utilisateur;
    _ctrlPrenom = TextEditingController(text: utilisateur?.prenom ?? '');
    _ctrlNom = TextEditingController(text: utilisateur?.nom ?? '');
    _ctrlEmail = TextEditingController(text: utilisateur?.email ?? '');
  }

  @override
  void dispose() {
    _ctrlPrenom.dispose();
    _ctrlNom.dispose();
    _ctrlEmail.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_cleFormulaire.currentState!.validate()) return;
    setState(() => _enChargement = true);

    final auth = context.read<AuthProvider>();
    final ok = await auth.modifierProfil(
      prenom: _ctrlPrenom.text.trim(),
      nom: _ctrlNom.text.trim(),
      email: _ctrlEmail.text.trim().isEmpty
          ? null
          : _ctrlEmail.text.trim(),
    );

    if (!mounted) return;
    setState(() => _enChargement = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour ✅'),
          backgroundColor: CouleursApp.succes,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.messageErreur ?? 'Erreur'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = context.watch<AuthProvider>().utilisateur;

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
      ),
      body: SafeArea(
        child: Form(
          key: _cleFormulaire,
          child: ListView(
            padding: const EdgeInsets.all(TaillesApp.espacement20),
            children: [
              const SizedBox(height: TaillesApp.espacement16),

              // Avatar (non modifiable pour l'instant)
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: CouleursApp.orangeSurface,
                      child: Text(
                        utilisateur?.initiales ?? '?',
                        style: const TextStyle(
                          color: CouleursApp.orangePrincipal,
                          fontWeight: FontWeight.w700,
                          fontSize: TaillesApp.texteTitre,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: CouleursApp.texteDesactive,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: CouleursApp.blanc,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TaillesApp.espacement8),
              const Center(
                child: Text(
                  'Photo non modifiable pour le moment',
                  style: TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.texteDesactive,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: TaillesApp.espacement32),

              // Téléphone (read-only)
              ChampTexte(
                controleur: TextEditingController(
                  text: utilisateur?.numeroTelephone ?? '',
                ),
                libelle: 'Numéro de téléphone',
                iconePrefixe: Icons.phone_outlined,
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: TaillesApp.espacement8),
                child: Text(
                  'Le numéro ne peut pas être modifié',
                  style: TextStyle(
                    fontSize: TaillesApp.texteMicro,
                    color: CouleursApp.texteDesactive,
                  ),
                ),
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Prénom
              ChampTexte(
                controleur: _ctrlPrenom,
                libelle: 'Prénom',
                iconePrefixe: Icons.person_outline,
                capitalisation: TextCapitalization.words,
                validateur: Validateurs.nom,
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Nom
              ChampTexte(
                controleur: _ctrlNom,
                libelle: 'Nom',
                iconePrefixe: Icons.badge_outlined,
                capitalisation: TextCapitalization.words,
                validateur: Validateurs.nom,
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Email
              ChampTexte(
                controleur: _ctrlEmail,
                libelle: 'Email (optionnel)',
                iconePrefixe: Icons.email_outlined,
                typeClavier: TextInputType.emailAddress,
                validateur: Validateurs.emailOptionnel,
              ),

              const SizedBox(height: TaillesApp.espacement32),

              BoutonPrimaire(
                libelle: 'Enregistrer les modifications',
                icone: Icons.check,
                enChargement: _enChargement,
                onPressed: _enregistrer,
              ),
              const SizedBox(height: TaillesApp.espacement12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, TaillesApp.hauteurBouton),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(TaillesApp.rayonMoyen),
                  ),
                ),
                child: const Text('Annuler'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
