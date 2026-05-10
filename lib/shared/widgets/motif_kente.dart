import 'package:flutter/material.dart';

import '../../core/constantes/couleurs.dart';

/// Motif décoratif inspiré du Kente, pour fond du Splash et écrans d'accueil.
///
/// Dessine une grille géométrique de losanges et de carrés,
/// dans des nuances d'orange et de vert harmonisées avec le drapeau.
class MotifKente extends StatelessWidget {
  final double opacite;

  const MotifKente({super.key, this.opacite = 0.12});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacite,
      child: CustomPaint(
        painter: _MotifKentePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _MotifKentePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final peintureOrange = Paint()
      ..color = CouleursApp.orangePrincipal
      ..style = PaintingStyle.fill;

    final peintureVert = Paint()
      ..color = CouleursApp.vertPrincipal
      ..style = PaintingStyle.fill;

    final peintureContour = Paint()
      ..color = CouleursApp.textePrincipal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double cote = 40;
    int rangee = 0;
    for (double y = 0; y < size.height; y += cote) {
      int colonne = 0;
      for (double x = 0; x < size.width; x += cote) {
        final cellulePaire = (rangee + colonne) % 2 == 0;
        final peinture = cellulePaire ? peintureOrange : peintureVert;

        // Carré de fond
        canvas.drawRect(
          Rect.fromLTWH(x, y, cote, cote),
          peinture,
        );

        // Losange contrasté au centre
        final centreX = x + cote / 2;
        final centreY = y + cote / 2;
        final losange = Path()
          ..moveTo(centreX, y + 4)
          ..lineTo(x + cote - 4, centreY)
          ..lineTo(centreX, y + cote - 4)
          ..lineTo(x + 4, centreY)
          ..close();

        canvas.drawPath(
          losange,
          cellulePaire ? peintureVert : peintureOrange,
        );
        canvas.drawPath(losange, peintureContour);

        colonne++;
      }
      rangee++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
