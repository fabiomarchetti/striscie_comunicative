import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// Anteprima riproducibile di un video salvato (percorso relativo in DB).
///
/// Risolve il percorso relativo nel percorso assoluto del filesystem app,
/// inizializza il [VideoPlayerController] e mostra il video con overlay
/// play/pausa (tap) e barra di avanzamento scrubabile.
class MediaVideo extends StatefulWidget {
  final String percorsoRelativo;
  final double radius;

  const MediaVideo({
    super.key,
    required this.percorsoRelativo,
    this.radius = AppRadii.dropBox,
  });

  @override
  State<MediaVideo> createState() => _MediaVideoState();
}

class _MediaVideoState extends State<MediaVideo> {
  VideoPlayerController? _controller;
  bool _errore = false;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  @override
  void didUpdateWidget(MediaVideo old) {
    super.didUpdateWidget(old);
    // Cambiato il file: ricrea il controller.
    if (old.percorsoRelativo != widget.percorsoRelativo) {
      _controller?.dispose();
      _controller = null;
      _errore = false;
      _carica();
    }
  }

  Future<void> _carica() async {
    try {
      final media = context.read<AppState>().media;
      final assoluto = await media.percorsoAssoluto(widget.percorsoRelativo);
      final c = VideoPlayerController.file(File(assoluto));
      await c.initialize();
      await c.setLooping(true);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _controller = c);
    } catch (_) {
      if (mounted) setState(() => _errore = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() => c.value.isPlaying ? c.pause() : c.play());
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    // Stato di caricamento/errore: rapporto neutro 16/9 finché non si conosce
    // quello reale del video.
    if (_errore) {
      return _wrap(
        16 / 9,
        Container(
          color: AppColors.softSurface,
          alignment: Alignment.center,
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.textMuted,
            size: 32,
          ),
        ),
      );
    }
    if (c == null || !c.value.isInitialized) {
      return _wrap(
        16 / 9,
        Container(
          color: AppColors.softSurface,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    // Video pronto: il box assume il rapporto d'aspetto reale del video.
    return _wrap(
      c.value.aspectRatio,
      GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(c),
            // Overlay play quando in pausa.
            if (!c.value.isPlaying)
              Container(
                color: Colors.black.withValues(alpha: 0.18),
                alignment: Alignment.center,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.plusCircle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            // Barra di avanzamento in basso.
            Align(
              alignment: Alignment.bottomCenter,
              child: VideoProgressIndicator(
                c,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Applica il rapporto d'aspetto e gli angoli arrotondati al contenuto.
  Widget _wrap(double aspectRatio, Widget child) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: child,
      ),
    );
  }
}
