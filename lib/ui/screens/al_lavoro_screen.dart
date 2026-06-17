import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/striscia.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/media_thumb.dart';

/// Schermata 4 — "Al lavoro" (consultazione a runtime di una striscia).
class AlLavoroScreen extends StatelessWidget {
  const AlLavoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final id = state.striscaSelId;

    if (id == null) {
      return const _MessaggioVuoto(
        icon: Icons.dashboard_outlined,
        testo: 'Seleziona una striscia dalla barra in alto per consultarla.',
      );
    }

    return FutureBuilder<Striscia?>(
      // La striscia completa di immagini viene caricata dal DB su richiesta.
      key: ValueKey(id),
      future: state.strisceRepo.conImmagini(id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final striscia = snap.data;
        if (striscia == null || striscia.immagini.isEmpty) {
          return const _MessaggioVuoto(
            icon: Icons.image_not_supported_outlined,
            testo: 'Questa striscia non contiene immagini.',
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Sequenza a piena pagina, ottimizzata per la lettura a distanza.
              final n = striscia.immagini.length;
              final crossAxis = n <= 2
                  ? n
                  : (constraints.maxWidth ~/ 220).clamp(2, 5);
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxis,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: n,
                itemBuilder: (context, i) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadii.innerBox),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.card,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: MediaThumb(
                      percorsoRelativo: striscia.immagini[i].percorso,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MessaggioVuoto extends StatelessWidget {
  final IconData icon;
  final String testo;
  const _MessaggioVuoto({required this.icon, required this.testo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 14),
          Text(
            testo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Azioni della top bar per "Al lavoro": dropdown selezione striscia.
class AlLavoroTopBarActions extends StatelessWidget {
  const AlLavoroTopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SegnamiDropdown<int>(
      value: state.striscaSelId,
      hint: 'Seleziona striscia',
      width: 280,
      height: 44,
      radius: AppRadii.pill,
      items: [
        for (final s in state.strisce)
          DropdownMenuItem(value: s.id, child: Text(s.nome)),
      ],
      onChanged: state.selezionaStriscia,
    );
  }
}
