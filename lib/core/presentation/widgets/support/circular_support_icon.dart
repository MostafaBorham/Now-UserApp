import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';

/// Shows a spinner in place of the icon while [onTap]'s future runs, and
/// ignores taps until it completes.
class CircularSupportIcon extends StatefulWidget {
  const CircularSupportIcon({super.key, this.size, this.onTap});
  final double? size;
  final AsyncCallback? onTap;

  @override
  State<CircularSupportIcon> createState() => _CircularSupportIconState();
}

class _CircularSupportIconState extends State<CircularSupportIcon> {
  bool _busy = false;

  Future<void> _onTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onTap?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final double size = widget.size ?? 25;
    return InkWell(
      onTap: _onTap,
      customBorder: const CircleBorder(),
      child: CircleAvatar(
        backgroundColor: colors.white,
        radius: size,
        child: Center(
          child: _busy
              ? SizedBox.square(
                  dimension: size * 0.8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.black,
                  ),
                )
              : Assets.media.images.svg.supportCallIcon.svg(
                  fit: BoxFit.contain,
                  width: size,
                  colorFilter: ColorFilter.mode(colors.black, BlendMode.srcIn),
                ),
        ),
      ),
    );
  }
}
