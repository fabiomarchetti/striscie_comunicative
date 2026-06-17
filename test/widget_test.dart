// Smoke test base dell'app Segnami.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:striscie_comunicative/state/app_state.dart';
import 'package:striscie_comunicative/theme/app_theme.dart';
import 'package:striscie_comunicative/ui/shell/app_shell.dart';

void main() {
  testWidgets('La shell mostra titolo e voci del NavigationRail', (
    tester,
  ) async {
    // Simula un tablet 10" landscape (1280×800).
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(theme: AppTheme.build(), home: const AppShell()),
      ),
    );

    // La schermata iniziale è "Comunicazioni".
    expect(find.text('Comunicazioni'), findsOneWidget);
    expect(find.text('Al\nlavoro'), findsOneWidget);
  });
}
