import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/media_picker.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dashed_border.dart';
import '../widgets/media_drop_box.dart';
import '../widgets/media_thumb.dart';
import '../widgets/media_video.dart';

/// Schermata 2 — "Crea attività".
class AttivitaScreen extends StatelessWidget {
  const AttivitaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 30),
      child: Column(
        children: [
          for (var i = 0; i < state.bozzeAttivita.length; i++) ...[
            _AttivitaCard(cardIndex: i),
            const SizedBox(height: 16),
          ],
          _AggiungiAttivitaBanner(onTap: state.aggiungiCardAttivita),
        ],
      ),
    );
  }
}

class _AttivitaCard extends StatelessWidget {
  final int cardIndex;
  const _AttivitaCard({required this.cardIndex});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bozza = state.bozzeAttivita[cardIndex];

    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardBadge(cardIndex + 1),
              const SizedBox(width: 10),
              Text(
                'Attività ${cardIndex + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Salva',
                icon: Icons.save_rounded,
                onPressed: () => state.salvaAttivita(cardIndex),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Coppia di box ridotta: occupa il 70% della larghezza della card,
          // allineata a sinistra (riduce anche l'altezza del box Video 16/9).
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BoxImmagini(cardIndex: cardIndex, bozza: bozza),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _BoxVideo(cardIndex: cardIndex, bozza: bozza)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenitore soft con header icona + titolo.
class _SoftBox extends StatelessWidget {
  final IconData icon;
  final String titolo;
  final Widget child;

  const _SoftBox({
    required this.icon,
    required this.titolo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadii.innerBox),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                titolo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BoxImmagini extends StatelessWidget {
  final int cardIndex;
  final BozzaAttivita bozza;
  const _BoxImmagini({required this.cardIndex, required this.bozza});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final dropBox = MediaDropBox(
      label: 'Aggiungi immagine',
      circleSize: 38,
      onTap: () async {
        final path = await MediaPicker.instance.scegliImmagine();
        if (path != null) {
          state.aggiungiImmagineAttivita(cardIndex, path);
        }
      },
    );
    return _SoftBox(
      icon: Icons.photo_outlined,
      titolo: 'Immagini',
      // Senza immagini, il box "Aggiungi immagine" è centrato nel contenitore;
      // con immagini presenti torna l'ultima cella della griglia 3 colonne.
      child: bozza.immagini.isEmpty
          ? Center(
              child: SizedBox(width: 120, height: 120, child: dropBox),
            )
          : GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final percorso in bozza.immagini)
                  MediaThumb(percorsoRelativo: percorso),
                dropBox,
              ],
            ),
    );
  }
}

class _BoxVideo extends StatelessWidget {
  final int cardIndex;
  final BozzaAttivita bozza;
  const _BoxVideo({required this.cardIndex, required this.bozza});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return _SoftBox(
      icon: Icons.play_circle_outline_rounded,
      titolo: 'Video',
      child: bozza.video == null
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: MediaDropBox(
                label: 'Carica video',
                circleSize: 48,
                onTap: () async {
                  final path = await MediaPicker.instance.scegliVideo();
                  if (path != null) {
                    state.setVideoAttivita(cardIndex, path);
                  }
                },
              ),
            )
          : _VideoCaricato(percorso: bozza.video!),
    );
  }
}

class _VideoCaricato extends StatelessWidget {
  final String percorso;
  const _VideoCaricato({required this.percorso});

  @override
  Widget build(BuildContext context) {
    // Box compatto: larghezza massima ridotta, altezza dal rapporto del video.
    // Tocca il video per riprodurlo/metterlo in pausa.
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: DashedBorder(
          color: AppColors.primary,
          radius: AppRadii.dropBox,
          child: MediaVideo(
            percorsoRelativo: percorso,
            radius: AppRadii.dropBox,
          ),
        ),
      ),
    );
  }
}

/// Banner "Aggiungi attività" sotto la card.
class _AggiungiAttivitaBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AggiungiAttivitaBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        color: AppColors.dashedBorder,
        radius: AppRadii.innerBox,
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.softSurface,
            borderRadius: BorderRadius.circular(AppRadii.innerBox),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.plusCircle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aggiungi attività',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
