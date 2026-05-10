import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tontineapp/features/authentification/data/repositories/auth_repository_demo.dart';
import 'package:tontineapp/main.dart';

void main() {
  testWidgets('Démarrage de la TontineApp affiche le splash', (tester) async {
    await tester.pumpWidget(
      TontineApp(authRepository: AuthRepositoryDemo()),
    );

    // Au premier rendu, on doit voir le nom de l'app sur le splash
    expect(find.text('TontineApp'), findsOneWidget);
    expect(find.text('La tontine, version moderne'), findsOneWidget);

    // Et l'indicateur de chargement
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
