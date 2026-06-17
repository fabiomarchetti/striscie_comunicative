import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Chip con icona usato nelle anteprime (Abbina) e per i componenti tipizzati.
class PreviewChip extends StatelessWidget {
  final String testo;
  final IconData icon;
  final Color container;
  final Color onContainer;

  const PreviewChip({
    super.key,
    required this.testo,
    required this.icon,
    this.container = AppColors.accentContainer,
    this.onContainer = AppColors.onAccentContainer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: container,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: onContainer),
          const SizedBox(width: 8),
          Text(
            testo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: onContainer,
            ),
          ),
        ],
      ),
    );
  }
}
