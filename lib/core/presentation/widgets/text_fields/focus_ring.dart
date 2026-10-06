import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';

/// Paints the app's focus ring (primary, 1.5 — [RoundedField]'s style) over
/// [child] while any field inside it has focus.
///
/// For fields whose pill is a decorated container around a borderless
/// [TextField], where `InputDecoration.focusedBorder` can't reach. Drawn as a
/// foreground decoration, so gaining focus never shifts the layout.
class FocusRing extends StatelessWidget {
  const FocusRing({super.key, required this.borderRadius, required this.child});

  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Builder(
        // Always a DecoratedBox (never a Container whose foreground box comes
        // and goes): changing the tree shape on focus would re-create the
        // field below and drop its focus and text.
        builder: (BuildContext context) => DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: Focus.of(context).hasFocus
              ? BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: context.colors.primary500Main,
                    width: 1.5,
                  ),
                )
              : const BoxDecoration(),
          child: child,
        ),
      ),
    );
  }
}
