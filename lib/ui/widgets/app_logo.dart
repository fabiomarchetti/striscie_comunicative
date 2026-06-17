import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Logo brand "mano LIS": quadrato con gradiente e icona mano bianca.
/// (handoff: 44×44, radius 13, gradient 150° #C0432A→#9C4A2B, ombra morbida.)
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.logo),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd,
          ],
        ),
        boxShadow: AppShadows.logo,
      ),
      child: Icon(
        Icons.sign_language_rounded,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}
