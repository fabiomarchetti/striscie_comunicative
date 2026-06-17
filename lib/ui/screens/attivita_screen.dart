import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/media_picker.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dashed_border.dart';
import '../widgets/media_drop_box.dart';
import '../widgets/media_thumb.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _BoxImmagini(cardIndex: cardIndex, bozza: bozza)),
              const SizedBox(width: 16),
              Expanded(child: _BoxVideo(cardIndex: cardIndex, bozza: bozza)),
            ],
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
    return _SoftBox(
      icon: Icons.photo_outlined,
      titolo: 'Immagini',
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final percorso in bozza.immagini)
            MediaThumb(percorsoRelativo: percorso),
          MediaDropBox(
            label: 'Aggiungi immagine',
            circleSize: 38,
            onTap: () async {
              final path = await MediaPicker.instance.scegliImmagine();
              if (path != null) {
                state.aggiungiImmagineAttivita(cardIndex, path);
              }
            },
          ),
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
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: bozza.video == null
            ? MediaDropBox(
                label: 'Carica video',
                circleSize: 48,
                onTap: () async {
                  final path = await MediaPicker.instance.scegliVideo();
                  if (path != null) {
                    state.setVideoAttivita(cardIndex, path);
                  }
                },
              )
            : _VideoCaricato(percorso: bozza.video!),
      ),
    );
  }
}

class _VideoCaricato extends StatelessWidget {
  final String percorso;
  const _VideoCaricato({required this.percorso});

  @override
  Widget build(BuildContext context) {
    final nome = percorso.split('/').last;
    return DashedBorder(
      color: AppColors.primary,
      radius: AppRadii.dropBox,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.softSurface,
          borderRadius: BorderRadius.circular(AppRadii.dropBox),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 36,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              nome,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryAlt,
              ),
            ),
          ],
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
