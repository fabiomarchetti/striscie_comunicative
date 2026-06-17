import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/preview_chip.dart';
import '../widgets/step_label.dart';

/// Schermata 3 — "Abbina striscie ed attività" (flusso a 4 step).
class AbbinaScreen extends StatelessWidget {
  const AbbinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1 — Seleziona striscia
          const StepLabel(numero: 1, testo: 'Seleziona striscia'),
          SegnamiDropdown<int>(
            value: state.striscaSelId,
            hint: 'Seleziona…',
            width: 320,
            items: [
              for (final s in state.strisce)
                DropdownMenuItem(value: s.id, child: Text(s.nome)),
            ],
            onChanged: state.selezionaStriscia,
          ),
          const SizedBox(height: 22),

          // Step 2 — Anteprima striscia
          const StepLabel(numero: 2, testo: 'Anteprima striscia'),
          _AnteprimaBox(
            microLabel: 'Striscia selezionata',
            child: state.striscaSel == null
                ? const _Placeholder('Nessuna striscia selezionata')
                : PreviewChip(
                    testo: state.striscaSel!.nome,
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
          ),
          const SizedBox(height: 22),

          // Step 3 — Seleziona attività
          const StepLabel(numero: 3, testo: 'Seleziona attività'),
          SegnamiDropdown<int>(
            value: state.attivitaSelId,
            hint: 'Seleziona…',
            width: 320,
            items: [
              for (final a in state.attivita)
                DropdownMenuItem(value: a.id, child: Text(a.nome)),
            ],
            onChanged: state.selezionaAttivita,
          ),
          const SizedBox(height: 22),

          // Step 4 — Anteprima attività
          const StepLabel(numero: 4, testo: 'Anteprima attività'),
          _AnteprimaBox(
            microLabel: 'Attività selezionata',
            child: state.attivitaSel == null
                ? const _Placeholder('Nessuna attività selezionata')
                : PreviewChip(
                    testo: state.attivitaSel!.nome,
                    icon: Icons.checklist_rounded,
                    container: AppColors.complementoContainer,
                    onContainer: AppColors.onComplemento,
                  ),
          ),
          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              label: 'Salva in archivio',
              icon: Icons.save_rounded,
              height: 52,
              radius: AppRadii.innerBox,
              large: true,
              onPressed: () => state.salvaAbbinamento(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnteprimaBox extends StatelessWidget {
  final String microLabel;
  final Widget child;
  const _AnteprimaBox({required this.microLabel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.softSurfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.innerBox),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MicroLabel(microLabel),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: child),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String testo;
  const _Placeholder(this.testo);

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
    );
  }
}
