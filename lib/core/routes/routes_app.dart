import 'package:flutter/material.dart';

import '../constantes/routes_noms.dart';
import '../../features/accueil/presentation/ecrans/accueil_principal_ecran.dart';
import '../../features/authentification/presentation/ecrans/connexion_ecran.dart';
import '../../features/authentification/presentation/ecrans/creation_profil_ecran.dart';
import '../../features/authentification/presentation/ecrans/edition_profil_ecran.dart';
import '../../features/authentification/presentation/ecrans/inscription_ecran.dart';
import '../../features/authentification/presentation/ecrans/verification_otp_ecran.dart';
import '../../features/cotisations/presentation/ecrans/detail_tour_ecran.dart';
import '../../features/notifications/presentation/ecrans/notifications_ecran.dart';
import '../../features/paiements/presentation/ecrans/choix_operateur_ecran.dart';
import '../../features/paiements/presentation/ecrans/confirmation_paiement_ecran.dart';
import '../../features/paiements/presentation/ecrans/recu_paiement_ecran.dart';
import '../../features/splash/presentation/ecrans/splash_ecran.dart';
import '../../features/tontines/presentation/ecrans/creer_tontine_ecran.dart';
import '../../features/tontines/presentation/ecrans/detail_tontine_ecran.dart';

/// Configuration centralisée des routes nommées de l'application.
class RoutesApp {
  RoutesApp._();

  static Map<String, WidgetBuilder> get routes => {
        // Onboarding & auth
        RoutesNoms.splash: (_) => const SplashEcran(),
        RoutesNoms.inscription: (_) => const InscriptionEcran(),
        RoutesNoms.verificationOtp: (_) => const VerificationOtpEcran(),
        RoutesNoms.creationProfil: (_) => const CreationProfilEcran(),
        RoutesNoms.connexion: (_) => const ConnexionEcran(),
        RoutesNoms.editionProfil: (_) => const EditionProfilEcran(),

        // Accueil
        RoutesNoms.accueilPrincipal: (_) => const AccueilPrincipalEcran(),

        // Tontines
        RoutesNoms.creerTontine: (_) => const CreerTontineEcran(),
        RoutesNoms.detailTontine: (_) => const DetailTontineEcran(),

        // Cotisations
        RoutesNoms.detailTour: (_) => const DetailTourEcran(),

        // Paiements Mobile Money
        RoutesNoms.choixOperateur: (_) => const ChoixOperateurEcran(),
        RoutesNoms.confirmationPaiement: (_) =>
            const ConfirmationPaiementEcran(),
        RoutesNoms.recuPaiement: (_) => const RecuPaiementEcran(),

        // Notifications
        RoutesNoms.notifications: (_) => const NotificationsEcran(),
      };
}
