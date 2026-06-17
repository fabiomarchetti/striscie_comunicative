import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../screens/abbina_screen.dart';
import '../screens/al_lavoro_screen.dart';
import '../screens/attivita_screen.dart';
import '../screens/comunicazioni_screen.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_snackbar.dart';

/// Metadati di una schermata (titolo/sottotitolo della top bar).
class _ScreenMeta {
  final String titolo;
  final String sottotitolo;
  const _ScreenMeta(this.titolo, this.sottotitolo);
}

const _meta = {
  AppScreen.comunica: _ScreenMeta(
    'Comunicazioni',
    'Crea e gestisci le strisce comunicative.',
  ),
  AppScreen.attivita: _ScreenMeta('Crea attività', 'Crea e gestisci le attività.'),
  AppScreen.frasi: _ScreenMeta(
    'Abbina striscie ed attività',
    'Collega soggetto, verbo e complemento per creare una frase.',
  ),
  AppScreen.esplora: _ScreenMeta(
    'Esplora dati',
    'Consulta tutte le frasi salvate o l\'intera tabella componenti.',
  ),
};

/// Shell comune a tutte le schermate: NavigationRail + top bar + body.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final meta = _meta[state.screen]!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      // La tastiera non deve ridimensionare il layout (il campo nome è in alto):
      // evita l'overflow del NavigationRail quando la tastiera è aperta.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                const _NavRail(),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(meta: meta),
                      Expanded(child: _body(state.screen)),
                    ],
                  ),
                ),
              ],
            ),
            const AppSnackbar(),
          ],
        ),
      ),
    );
  }

  Widget _body(AppScreen screen) {
    switch (screen) {
      case AppScreen.comunica:
        return const ComunicazioniScreen();
      case AppScreen.attivita:
        return const AttivitaScreen();
      case AppScreen.frasi:
        return const AbbinaScreen();
      case AppScreen.esplora:
        return const AlLavoroScreen();
    }
  }
}

// -----------------------------------------------------------------------------
// NavigationRail custom (handoff §NavigationRail)
// -----------------------------------------------------------------------------

class _NavItem {
  final AppScreen screen;
  final IconData icon;
  final List<String> labelLines;
  const _NavItem(this.screen, this.icon, this.labelLines);
}

const _items = [
  _NavItem(AppScreen.comunica, Icons.chat_bubble_outline_rounded, [
    'Crea',
    'striscie',
    'comunicative',
  ]),
  _NavItem(AppScreen.attivita, Icons.checklist_rounded, ['Crea', 'attività']),
  _NavItem(AppScreen.frasi, Icons.article_outlined, [
    'Abbina',
    'striscie ed',
    'attività',
  ]),
  _NavItem(AppScreen.esplora, Icons.dashboard_outlined, ['Al', 'lavoro']),
];

class _NavRail extends StatelessWidget {
  const _NavRail();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Container(
      width: 96,
      color: AppColors.railSurface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const AppLogo(),
          const SizedBox(height: 22),
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _NavRailItem(
                item: item,
                active: state.screen == item.screen,
                onTap: () => state.vaiA(item.screen),
              ),
            ),
          const Spacer(),
          _DbCounter(total: state.dbTotal),
        ],
      ),
    );
  }
}

class _NavRailItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavRailItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            // Indicatore a pillola dietro l'icona.
            Container(
              width: 56,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.accentContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: active
                    ? AppColors.onAccentContainer
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.labelLines.join('\n'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DbCounter extends StatelessWidget {
  final int total;
  const _DbCounter({required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.storage_rounded, size: 20, color: AppColors.textMutedAlt),
        const SizedBox(height: 4),
        Text(
          '$total righe',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMutedAlt,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Top bar (handoff §Top bar) + slot azioni contestuali
// -----------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  final _ScreenMeta meta;
  const _TopBar({required this.meta});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.titolo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta.sottotitolo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _TopBarActions(screen: state.screen),
        ],
      ),
    );
  }
}

/// Azioni contestuali della top bar, diverse per schermata.
class _TopBarActions extends StatelessWidget {
  final AppScreen screen;
  const _TopBarActions({required this.screen});

  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case AppScreen.comunica:
        return const ComunicazioniTopBarActions();
      case AppScreen.esplora:
        return const AlLavoroTopBarActions();
      case AppScreen.attivita:
      case AppScreen.frasi:
        return const SizedBox.shrink();
    }
  }
}
