import 'package:flutter/material.dart';

import '../../../../core/constantes/couleurs.dart';
import '../../../../core/constantes/tailles.dart';
import '../../domaine/entites/notification_app.dart';

/// Ligne affichant une notification dans la liste.
class LigneNotification extends StatelessWidget {
  final NotificationApp notification;
  final VoidCallback onTap;
  final VoidCallback onSupprimer;

  const LigneNotification({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onSupprimer,
  });

  IconData get _icone {
    switch (notification.type) {
      case TypeNotification.cotisationValidee:
        return Icons.verified;
      case TypeNotification.paiementReussi:
        return Icons.payments;
      case TypeNotification.paiementEchoue:
        return Icons.error_outline;
      case TypeNotification.tourClotureProchaine:
        return Icons.access_time;
      case TypeNotification.tourCloture:
        return Icons.celebration;
      case TypeNotification.nouveauMembre:
        return Icons.person_add;
      case TypeNotification.tontineActivee:
        return Icons.rocket_launch;
      case TypeNotification.rappel:
        return Icons.notifications_active;
      case TypeNotification.systeme:
        return Icons.info_outline;
    }
  }

  Color get _couleur {
    switch (notification.type) {
      case TypeNotification.cotisationValidee:
      case TypeNotification.paiementReussi:
      case TypeNotification.tourCloture:
      case TypeNotification.tontineActivee:
        return CouleursApp.vertPrincipal;
      case TypeNotification.paiementEchoue:
        return CouleursApp.erreur;
      case TypeNotification.tourClotureProchaine:
      case TypeNotification.rappel:
        return CouleursApp.avertissement;
      case TypeNotification.nouveauMembre:
        return CouleursApp.orangePrincipal;
      case TypeNotification.systeme:
        return CouleursApp.information;
    }
  }

  String get _tempsRelatif {
    final diff = DateTime.now().difference(notification.dateCreation);
    if (diff.inSeconds < 60) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return 'il y a ${(diff.inDays / 7).floor()} sem';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: TaillesApp.espacement20),
        color: CouleursApp.erreur,
        child: const Icon(
          Icons.delete_outline,
          color: CouleursApp.blanc,
        ),
      ),
      onDismissed: (_) => onSupprimer(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(TaillesApp.espacement16),
          decoration: BoxDecoration(
            color: notification.lue
                ? CouleursApp.fondCarte
                : CouleursApp.orangeSurface.withValues(alpha: 0.3),
            border: const Border(
              bottom: BorderSide(color: CouleursApp.bordure, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône colorée
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _couleur.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icone, color: _couleur, size: 22),
              ),
              const SizedBox(width: TaillesApp.espacement12),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: TextStyle(
                              fontSize: TaillesApp.textePetit,
                              fontWeight: notification.lue
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: CouleursApp.textePrincipal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.lue)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: CouleursApp.orangePrincipal,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: TaillesApp.texteTresPetit,
                        color: CouleursApp.texteSecondaire,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tempsRelatif,
                      style: const TextStyle(
                        fontSize: TaillesApp.texteMicro,
                        color: CouleursApp.texteDesactive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
