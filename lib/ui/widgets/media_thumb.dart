import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// Miniatura di un'immagine salvata, risolvendo il percorso relativo in DB
/// nel percorso assoluto del filesystem app.
class MediaThumb extends StatelessWidget {
  final String percorsoRelativo;
  final double radius;
  final BoxFit fit;

  const MediaThumb({
    super.key,
    required this.percorsoRelativo,
    this.radius = AppRadii.dropBox,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final media = context.read<AppState>().media;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: FutureBuilder<String>(
        future: media.percorsoAssoluto(percorsoRelativo),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Container(color: AppColors.softSurface);
          }
          return Image.file(
            File(snap.data!),
            fit: fit,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.softSurface,
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }
}
