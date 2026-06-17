import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Etichetta di sezione "N · Titolo" (handoff: 13 bold #6E5F57).
class StepLabel extends StatelessWidget {
  final int numero;
  final String testo;

  const StepLabel({super.key, required this.numero, required this.testo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$numero · $testo',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Micro-label uppercase (es. "STRISCIA SELEZIONATA").
class MicroLabel extends StatelessWidget {
  final String testo;
  const MicroLabel(this.testo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      testo.toUpperCase(),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    );
  }
}
