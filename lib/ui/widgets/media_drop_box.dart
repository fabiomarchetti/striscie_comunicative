import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'dashed_border.dart';

/// Box tratteggiato "+ aggiungi" usato per immagini/video.
/// Cerchio primario con "+" bianco + label sotto.
class MediaDropBox extends StatefulWidget {
  final String label;
  final IconData icon;
  final double circleSize;
  final VoidCallback onTap;
  final double radius;

  const MediaDropBox({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.add,
    this.circleSize = 46,
    this.radius = AppRadii.dropBox,
  });

  @override
  State<MediaDropBox> createState() => _MediaDropBoxState();
}

class _MediaDropBoxState extends State<MediaDropBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    // Hover/pressed: sfondo #F7E6DC, bordo #9C4A2B.
    final bg = _hover ? const Color(0xFFF7E6DC) : AppColors.softSurface;
    final borderColor = _hover ? AppColors.primary : AppColors.dashedBorder;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: DashedBorder(
          color: borderColor,
          radius: widget.radius,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            padding: const EdgeInsets.all(8),
            // FittedBox: su slot piccoli (es. griglia attività) il contenuto
            // si riduce invece di andare in overflow.
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widget.circleSize,
                      height: widget.circleSize,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.plusCircle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.circleSize * 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
