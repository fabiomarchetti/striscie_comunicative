import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'ui/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tablet 10": forza l'orientamento landscape (handoff §Target).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final appState = AppState();
  await appState.inizializza();

  runApp(
    ChangeNotifierProvider.value(value: appState, child: const SegnamiApp()),
  );
}

class SegnamiApp extends StatelessWidget {
  const SegnamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Segnami',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}
