import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/media_picker.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/media_drop_box.dart';
import '../widgets/media_thumb.dart';

/// Schermata 1 — "Crea / modifica striscie comunicative".
class ComunicazioniScreen extends StatelessWidget {
  const ComunicazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final immagini = state.bozzaStrisciaImmagini;
    final inModifica = state.inModificaStriscia;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
      child: ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CardBadge(inModifica ? state.bozzaStrisciaImmagini.length : 1),
                const SizedBox(width: 10),
                Text(
                  inModifica ? 'Modifica striscia' : 'Nuova striscia',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (inModifica) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                ],
              ],
            ),
            const SizedBox(height: 18),
            // Griglia immagini già aggiunte + drop box "Aggiungi immagine".
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < immagini.length; i++)
                  _StrisciaImmagineTile(
                    percorso: immagini[i],
                    onRemove: () => state.rimuoviImmagineStriscia(i),
                    onReplace: () async {
                      final path = await MediaPicker.instance.scegliImmagine();
                      if (path != null) {
                        state.sostituisciImmagineStriscia(i, path);
                      }
                    },
                  ),
                SizedBox(
                  width: 138,
                  height: 98,
                  child: MediaDropBox(
                    label: 'Aggiungi immagine',
                    onTap: () async {
                      final path = await MediaPicker.instance.scegliImmagine();
                      if (path != null) {
                        state.aggiungiImmagineStriscia(path);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (immagini.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Tocca un\'immagine per sostituirla, la × per rimuoverla.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StrisciaImmagineTile extends StatelessWidget {
  final String percorso;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _StrisciaImmagineTile({
    required this.percorso,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 98,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Tap sull'immagine → sostituzione.
          GestureDetector(
            onTap: onReplace,
            child: MediaThumb(percorsoRelativo: percorso),
          ),
          // Pulsante "sostituisci" in basso a destra.
          Positioned(
            bottom: 4,
            right: 4,
            child: _TileButton(
              icon: Icons.swap_horiz_rounded,
              onTap: onReplace,
            ),
          ),
          // Pulsante "rimuovi" in alto a destra.
          Positioned(
            top: 4,
            right: 4,
            child: _TileButton(icon: Icons.close_rounded, onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TileButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.snackbarBg.withValues(alpha: 0.78),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

/// Azioni della top bar per Comunicazioni: campo nome, scelta modifica,
/// e bottoni Salva/Aggiorna (più Annulla/Elimina in modifica).
class ComunicazioniTopBarActions extends StatefulWidget {
  const ComunicazioniTopBarActions({super.key});

  @override
  State<ComunicazioniTopBarActions> createState() =>
      _ComunicazioniTopBarActionsState();
}

class _ComunicazioniTopBarActionsState
    extends State<ComunicazioniTopBarActions> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AppState>().striscaNome,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confermaElimina(AppState state) async {
    final id = state.striscaInModificaId;
    if (id == null) return;
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare la striscia?'),
        content: Text('«${state.striscaNome}» verrà eliminata definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (conferma == true) {
      await state.eliminaStriscia(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Mantiene il controller allineato (load in modifica / reset dopo salva).
    if (state.striscaNome != _controller.text) {
      _controller.text = state.striscaNome;
    }
    final inModifica = state.inModificaStriscia;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Campo nome.
        Container(
          width: 220,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: const Color(0xFFDBC8BF)),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: state.setStriscaNome,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Nome della striscia…',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),

        if (inModifica) ...[
          // In modifica: Elimina + Annulla + Aggiorna.
          SecondaryButton(
            label: 'Elimina',
            icon: Icons.delete_outline_rounded,
            foreground: AppColors.verboAccent,
            onPressed: () => _confermaElimina(state),
          ),
          const SizedBox(width: 9),
          SecondaryButton(
            label: 'Annulla',
            icon: Icons.close_rounded,
            onPressed: state.nuovaStriscia,
          ),
          const SizedBox(width: 9),
          PrimaryButton(
            label: 'Aggiorna',
            icon: Icons.save_rounded,
            onPressed: () => state.salvaStriscia(),
          ),
        ] else ...[
          // In creazione: selettore "Modifica" (se ci sono strisce) + Salva.
          if (state.strisce.isNotEmpty) ...[
            _ModificaMenu(state: state),
            const SizedBox(width: 9),
          ],
          PrimaryButton(
            label: 'Salva',
            icon: Icons.save_rounded,
            onPressed: () => state.salvaStriscia(),
          ),
        ],
      ],
    );
  }
}

/// Menu a comparsa per scegliere una striscia salvata da modificare.
class _ModificaMenu extends StatelessWidget {
  final AppState state;
  const _ModificaMenu({required this.state});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Scegli una striscia da modificare',
      position: PopupMenuPosition.under,
      onSelected: (id) => state.iniziaModificaStriscia(id),
      itemBuilder: (context) => [
        for (final s in state.strisce)
          PopupMenuItem<int>(
            value: s.id,
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(s.nome),
              ],
            ),
          ),
      ],
      // IgnorePointer: il tap è gestito dal PopupMenuButton, non dal bottone.
      child: const IgnorePointer(
        child: SecondaryButton(
          label: 'Modifica',
          icon: Icons.edit_outlined,
          onPressed: _noop,
        ),
      ),
    );
  }
}

void _noop() {}
