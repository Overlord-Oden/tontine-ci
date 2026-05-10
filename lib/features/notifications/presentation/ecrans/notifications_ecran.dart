import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../providers/notification_provider.dart';
import '../widgets/ligne_notification.dart';

/// Écran centre de notifications.
class NotificationsEcran extends StatefulWidget {
  const NotificationsEcran({super.key});

  @override
  State<NotificationsEcran> createState() => _NotificationsEcranState();
}

class _NotificationsEcranState extends State<NotificationsEcran> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().charger();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: CouleursApp.fondPrincipal,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.aDesNonLues)
            TextButton(
              onPressed: () =>
                  context.read<NotificationProvider>().marquerToutesLues(),
              child: const Text('Tout marquer lu'),
            ),
          PopupMenuButton<String>(
            onSelected: (valeur) async {
              if (valeur == 'effacer') {
                final confirme = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Effacer les notifications ?'),
                    content: const Text(
                      'Toutes les notifications seront supprimées définitivement.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: CouleursApp.erreur,
                        ),
                        child: const Text('Effacer'),
                      ),
                    ],
                  ),
                );
                if (confirme == true && context.mounted) {
                  await context.read<NotificationProvider>().effacerTout();
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'effacer',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined,
                        color: CouleursApp.erreur),
                    SizedBox(width: TaillesApp.espacement8),
                    Text('Tout effacer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _ListeVide()
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<NotificationProvider>().charger(),
              color: CouleursApp.orangePrincipal,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (_, i) {
                  final n = notifications[i];
                  return LigneNotification(
                    notification: n,
                    onTap: () =>
                        context.read<NotificationProvider>().marquerLue(n.id),
                    onSupprimer: () =>
                        context.read<NotificationProvider>().supprimer(n.id),
                  );
                },
              ),
            ),
    );
  }
}

class _ListeVide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TaillesApp.espacement32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: CouleursApp.orangeSurface,
                borderRadius: BorderRadius.circular(TaillesApp.rayonGrand),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 56,
                color: CouleursApp.orangePrincipal,
              ),
            ),
            const SizedBox(height: TaillesApp.espacement24),
            const Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: TaillesApp.texteGrand,
                fontWeight: FontWeight.w600,
                color: CouleursApp.textePrincipal,
              ),
            ),
            const SizedBox(height: TaillesApp.espacement8),
            const Text(
              'Vous serez averti(e) ici dès qu\'il se passera\n'
              'quelque chose dans vos tontines.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: TaillesApp.textePetit,
                color: CouleursApp.texteSecondaire,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
