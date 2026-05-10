import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constantes/chaines.dart';
import 'core/constantes/routes_noms.dart';
import 'core/routes/routes_app.dart';
import 'core/themes/theme_app.dart';
import 'features/authentification/data/repositories/auth_repository_demo.dart';
import 'features/authentification/domaine/contracts/auth_repository.dart';
import 'features/authentification/presentation/providers/auth_provider.dart';
import 'features/cotisations/data/repositories/cotisation_repository_demo.dart';
import 'features/cotisations/domaine/contracts/cotisation_repository.dart';
import 'features/cotisations/presentation/providers/cotisation_provider.dart';
import 'features/notifications/data/repositories/notification_repository_demo.dart';
import 'features/notifications/data/services/service_notifications_natives.dart';
import 'features/notifications/domaine/contracts/notification_repository.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/paiements/data/repositories/paiement_repository_demo.dart';
import 'features/paiements/domaine/contracts/paiement_repository.dart';
import 'features/paiements/presentation/providers/paiement_provider.dart';
import 'features/tontines/data/repositories/tontine_repository_demo.dart';
import 'features/tontines/domaine/contracts/tontine_repository.dart';
import 'features/tontines/presentation/providers/tontine_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('fr_FR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialise le service de notifications natives (best-effort)
  await ServiceNotificationsNatives().initialiser().catchError((_) {});

  // Couches de données
  final AuthRepository authRepository = AuthRepositoryDemo();
  final TontineRepository tontineRepository = TontineRepositoryDemo();
  final CotisationRepository cotisationRepository =
      CotisationRepositoryDemo();
  final PaiementRepository paiementRepository =
      PaiementRepositoryDemo(cotisationRepository);
  final NotificationRepository notificationRepository =
      NotificationRepositoryDemo();

  runApp(TontineApp(
    authRepository: authRepository,
    tontineRepository: tontineRepository,
    cotisationRepository: cotisationRepository,
    paiementRepository: paiementRepository,
    notificationRepository: notificationRepository,
  ));
}

class TontineApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TontineRepository tontineRepository;
  final CotisationRepository cotisationRepository;
  final PaiementRepository paiementRepository;
  final NotificationRepository notificationRepository;

  const TontineApp({
    super.key,
    required this.authRepository,
    required this.tontineRepository,
    required this.cotisationRepository,
    required this.paiementRepository,
    required this.notificationRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TontineProvider>(
          create: (_) => TontineProvider(tontineRepository),
          update: (_, auth, tontineProvider) {
            tontineProvider ??= TontineProvider(tontineRepository);
            final utilisateur = auth.utilisateur;
            if (utilisateur != null) {
              final repo = tontineRepository;
              if (repo is TontineRepositoryDemo) {
                // ignore: unawaited_futures
                () async {
                  await repo.initialiserSiNecessaire(
                    utilisateur.id,
                    utilisateur.nomComplet,
                  );
                  final cotRepo = cotisationRepository;
                  if (cotRepo is CotisationRepositoryDemo) {
                    final tontines = await repo.listerToutes();
                    for (final t in tontines) {
                      await cotRepo.genererSiNecessaire(
                        t,
                        idUtilisateurCourant: utilisateur.id,
                      );
                    }
                  }
                }();
              }
              if (tontineProvider.tontines.isEmpty &&
                  !tontineProvider.enChargement) {
                tontineProvider.chargerMesTontines(utilisateur.id);
              }
            }
            return tontineProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => CotisationProvider(cotisationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PaiementProvider(paiementRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationRepository),
        ),
      ],
      child: MaterialApp(
        title: ChainesApp.nomApp,
        debugShowCheckedModeBanner: false,
        theme: ThemeApp.themeClair,
        initialRoute: RoutesNoms.splash,
        routes: RoutesApp.routes,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('fr', 'FR'),
      ),
    );
  }
}
