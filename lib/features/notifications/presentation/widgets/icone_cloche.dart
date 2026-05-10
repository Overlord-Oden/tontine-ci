import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constantes/couleurs.dart';
import '../providers/notification_provider.dart';

/// Bouton cloche avec badge rouge montrant le nombre de notifications non lues.
class IconeCloche extends StatelessWidget {
  final VoidCallback onTap;

  const IconeCloche({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final nbNonLues = provider.nbNonLues;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            nbNonLues > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            color: nbNonLues > 0
                ? CouleursApp.orangePrincipal
                : CouleursApp.texteSecondaire,
          ),
          onPressed: onTap,
        ),
        if (nbNonLues > 0)
          Positioned(
            top: 8,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: CouleursApp.erreur,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CouleursApp.blanc, width: 1.5),
              ),
              child: Center(
                child: Text(
                  nbNonLues > 99 ? '99+' : '$nbNonLues',
                  style: const TextStyle(
                    color: CouleursApp.blanc,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
