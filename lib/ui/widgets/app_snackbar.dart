import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

/// Snackbar custom sovrapposta in basso al centro (handoff §Interactions).
/// Entra con traslazione dal basso + fade (~260ms) e si auto-dismette a 2600ms.
class AppSnackbar extends StatefulWidget {
  const AppSnackbar({super.key});

  @override
  State<AppSnackbar> createState() => _AppSnackbarState();
}

class _AppSnackbarState extends State<AppSnackbar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  int? _shownSeq;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handle(SnackMessage? snack) {
    if (snack == null) return;
    if (snack.seq == _shownSeq) return;
    _shownSeq = snack.seq;
    _controller.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      if (_shownSeq == snack.seq) {
        _controller.reverse();
        context.read<AppState>().chiudiSnack(snack.seq);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final snack = context.watch<AppState>().snack;
    WidgetsBinding.instance.addPostFrameCallback((_) => _handle(snack));

    if (snack == null && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.snackbarBg,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x47000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.snackbarIcon,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      snack?.testo ?? '',
                      style: const TextStyle(
                        color: AppColors.snackbarText,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
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
