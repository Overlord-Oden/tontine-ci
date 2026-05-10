import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../../../core/entites/tontine.dart';
import '../../../../core/utils/formatteurs.dart';
import '../../../../core/utils/validateurs.dart';
import '../../../../shared/widgets/bouton_primaire.dart';
import '../../../../shared/widgets/champ_texte.dart';
import '../../../authentification/presentation/providers/auth_provider.dart';
import '../providers/tontine_provider.dart';

/// Écran de création d'une nouvelle tontine.
class CreerTontineEcran extends StatefulWidget {
  const CreerTontineEcran({super.key});

  @override
  State<CreerTontineEcran> createState() => _CreerTontineEcranState();
}

class _CreerTontineEcranState extends State<CreerTontineEcran> {
  final _cleFormulaire = GlobalKey<FormState>();
  final _ctrlNom = TextEditingController();
  final _ctrlDescription = TextEditingController();
  final _ctrlMontant = TextEditingController();
  FrequenceCotisation _frequence = FrequenceCotisation.mensuelle;
  DateTime _dateDebut = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _ctrlNom.dispose();
    _ctrlDescription.dispose();
    _ctrlMontant.dispose();
    super.dispose();
  }

  String? _validerMontant(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) {
      return 'Montant obligatoire';
    }
    final n = num.tryParse(valeur.replaceAll(' ', ''));
    if (n == null || n <= 0) return 'Montant invalide';
    if (n < 1000) return 'Minimum 1 000 FCFA';
    return null;
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final choisie = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: maintenant,
      lastDate: maintenant.add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CouleursApp.orangePrincipal,
              onPrimary: CouleursApp.blanc,
              surface: CouleursApp.blanc,
              onSurface: CouleursApp.textePrincipal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (choisie != null) {
      setState(() => _dateDebut = choisie);
    }
  }

  Future<void> _onCreer() async {
    if (!_cleFormulaire.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final utilisateur = auth.utilisateur;
    if (utilisateur == null) return;

    final tontineProvider = context.read<TontineProvider>();
    final montant = num.parse(_ctrlMontant.text.replaceAll(' ', ''));

    final tontine = await tontineProvider.creerTontine(
      nom: _ctrlNom.text.trim(),
      description: _ctrlDescription.text.trim().isEmpty
          ? null
          : _ctrlDescription.text.trim(),
      montantCotisation: montant,
      frequence: _frequence,
      dateDebut: _dateDebut,
      idCreateur: utilisateur.id,
      nomCreateur: utilisateur.nomComplet,
      numeroTelephoneCreateur: utilisateur.numeroTelephone,
    );

    if (!mounted) return;

    if (tontine != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tontine créée ! Invitez maintenant des membres.'),
          backgroundColor: CouleursApp.succes,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tontineProvider.messageErreur ?? 'Erreur'),
          backgroundColor: CouleursApp.erreur,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tontineProvider = context.watch<TontineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle tontine'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _cleFormulaire,
          child: ListView(
            padding: const EdgeInsets.all(TaillesApp.espacement20),
            children: [
              // Nom
              ChampTexte(
                controleur: _ctrlNom,
                libelle: 'Nom de la tontine',
                indication: 'Ex : Famille Yopougon',
                iconePrefixe: Icons.label_outline,
                capitalisation: TextCapitalization.words,
                validateur: Validateurs.obligatoire,
                longueurMax: 60,
              ),
              const SizedBox(height: TaillesApp.espacement16),

              // Description
              ChampTexte(
                controleur: _ctrlDescription,
                libelle: 'Description (optionnelle)',
                indication: 'Quelques mots sur la tontine...',
                iconePrefixe: Icons.notes_outlined,
                capitalisation: TextCapitalization.sentences,
                longueurMax: 200,
              ),
              const SizedBox(height: TaillesApp.espacement24),

              // Montant
              const _SousTitre('Cotisation'),
              const SizedBox(height: TaillesApp.espacement8),
              ChampTexte(
                controleur: _ctrlMontant,
                libelle: 'Montant par tour (FCFA)',
                indication: 'Ex : 25000',
                iconePrefixe: Icons.payments_outlined,
                typeClavier: TextInputType.number,
                validateur: _validerMontant,
              ),
              const SizedBox(height: TaillesApp.espacement24),

              // Fréquence
              const _SousTitre('Fréquence des cotisations'),
              const SizedBox(height: TaillesApp.espacement8),
              ...FrequenceCotisation.values.map((f) {
                return RadioListTile<FrequenceCotisation>(
                  value: f,
                  groupValue: _frequence,
                  onChanged: (v) {
                    if (v != null) setState(() => _frequence = v);
                  },
                  activeColor: CouleursApp.orangePrincipal,
                  title: Text(
                    f.libelle,
                    style: const TextStyle(
                      fontSize: TaillesApp.textePetit,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Tous les ${f.joursEntreTours} jours',
                    style: const TextStyle(
                      fontSize: TaillesApp.texteMicro,
                      color: CouleursApp.texteSecondaire,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const SizedBox(height: TaillesApp.espacement24),

              // Date de début
              const _SousTitre('Date de début'),
              const SizedBox(height: TaillesApp.espacement8),
              InkWell(
                onTap: _choisirDate,
                borderRadius: BorderRadius.circular(TaillesApp.rayonMoyen),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TaillesApp.espacement16,
                    vertical: TaillesApp.espacement16,
                  ),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius:
                        BorderRadius.circular(TaillesApp.rayonMoyen),
                    border: Border.all(color: CouleursApp.bordure),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: CouleursApp.texteSecondaire,
                      ),
                      const SizedBox(width: TaillesApp.espacement12),
                      Text(
                        Formatteurs.formatterDateLongue(_dateDebut),
                        style: const TextStyle(
                          fontSize: TaillesApp.texteMoyen,
                          color: CouleursApp.textePrincipal,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: CouleursApp.texteSecondaire,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TaillesApp.espacement32),

              BoutonPrimaire(
                libelle: 'Créer la tontine',
                icone: Icons.check,
                enChargement: tontineProvider.enChargement,
                onPressed: _onCreer,
              ),
              const SizedBox(height: TaillesApp.espacement16),
              const Text(
                'Vous pourrez inviter les membres à l\'étape suivante. '
                'La tontine ne démarrera qu\'une fois activée.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: TaillesApp.texteMicro,
                  color: CouleursApp.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SousTitre extends StatelessWidget {
  final String texte;
  const _SousTitre(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte.toUpperCase(),
      style: const TextStyle(
        fontSize: TaillesApp.texteMicro,
        fontWeight: FontWeight.w600,
        color: CouleursApp.texteSecondaire,
        letterSpacing: 1.2,
      ),
    );
  }
}
